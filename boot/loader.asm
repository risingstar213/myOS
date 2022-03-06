; 将kernel加载进内存，并进入保护模式
org 0100h


    jmp LABEL_START

%include "load.inc"
%include "fat12hdr.inc"
%include "pm.inc"
; GDT
LABEL_GDT:  Descriptor 0,  0,  0
LABEL_DESC_FLAT_C: Descriptor 0, 0fffffh, DA_CR|DA_32|DA_LIMIT_4K
LABEL_DESC_FLAT_RW: Descriptor 0,      0fffffh, DA_DRW|DA_32|DA_LIMIT_4K
LABEL_DESC_VIDEO:   Descriptor 0B8000h, 0ffffh, DA_DRW|DA_DPL3

GdtLen equ $ - LABEL_GDT
GdtPtr dw GdtLen - 1
        dd BaseOfLoaderPhyAddr + LABEL_GDT

SelectorFlatC  equ LABEL_DESC_FLAT_C - LABEL_GDT
selectorFlatRW equ LABEL_DESC_FLAT_RW - LABEL_GDT
SelectorVideo equ LABEL_DESC_VIDEO - LABEL_GDT

BaseOfStack	equ	0100h
PageDirBase equ 100000h
PageTblBase equ 101000h

LABEL_START:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, BaseOfStack
    
	mov	dh, 0			; "Loading  "
	call	DispStrRealMode			; 显示字符串
	
    mov ebx, 0
    mov di, _MemChkBuf
.MemChkLoop:

    mov	eax, 0E820h		; eax = 0000E820h
	mov	ecx, 20			; ecx = 地址范围描述符结构的大小
	mov	edx, 0534D4150h		; edx = 'SMAP'
	int	15h			; int 15h
	jc	.MemChkFail
	add	di, 20
	inc	dword [_dwMCRNumber]	; dwMCRNumber = ARDS 的个数
	cmp	ebx, 0
	jne	.MemChkLoop
	jmp	.MemChkOK
.MemChkFail:
	mov	dword [_dwMCRNumber], 0
.MemChkOK:

    xor ah, ah
    xor dl, dl
    int 13h  ; 软驱复位

    ; 查找 LOADER.BIN
    mov word [wSectorNo], SectorNoOfRootDirectory ; 根目录起始扇区
LABEL_SEARCH_IN_ROOT_DIR_BEGIN:
    cmp word [wRootDirSizeForLoop], 0 ; 是否读完根目录
    jz LABEL_NO_KERNELBIN ; 读完
    dec word [wRootDirSizeForLoop] ; 读完一个扇区减一
    mov ax, BaseOfKernelFile
    mov es, ax ; Loader目的基址
    mov bx, OffsetOfKernelFile ; Loader目的偏移量
    mov ax, [wSectorNo] ;
    mov cl, 1
    call ReadSector

    mov si, KernelFileName
    mov di, OffsetOfKernelFile
    cld
    mov dx, 10h
LABEL_SEARCH_FOR_KERNELBIN:
    cmp dx, 0
    jz LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR
    dec dx
    mov cx, 11
LABEL_CMP_FILENAME:
    cmp cx, 0
    jz LABEL_FILENAME_FOUND
    dec cx
    lodsb
    cmp al, byte [es:di]
    jz LABEL_GO_ON
    jmp LABEL_DIFFERENT
LABEL_GO_ON:
    inc di
    jmp LABEL_CMP_FILENAME

LABEL_DIFFERENT:
	and	di, 0FFE0h ; 回到条目开头
	add	di, 20h ; 下一个条目
	mov	si, KernelFileName
	jmp	LABEL_SEARCH_FOR_KERNELBIN

LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR:
    add word [wSectorNo], 1
    jmp LABEL_SEARCH_IN_ROOT_DIR_BEGIN

LABEL_NO_KERNELBIN:
    mov dh, 2
    call DispStrRealMode
%ifdef _LOADER_DEBUG_
    mov ax, 4c00h
    int 21h
%else
    jmp $
%endif


LABEL_FILENAME_FOUND:
    mov	ax, RootDirSectors
    and	di, 0FFE0h ; 0FFE0h 0FFF0h 均可， name字段在前16字节，效果相同
    
    push eax
    mov eax, [es:di + 01Ch]
    mov dword [dwKernelSize], eax ; 保存文件大小
    pop eax
    
    add di, 01Ah ; DIR_FstClus所在地址
    mov cx, word [es:di] ; 簇号
    push cx
    add cx, ax
    add cx, DeltaSectorNo
    mov	ax, BaseOfKernelFile
    mov es, ax
    mov bx, OffsetOfKernelFile
    mov ax, cx

LABEL_GOON_LOADING_FILE:
    push ax
    push bx
    mov	ah, 0Eh
	mov	al, '.'
	mov	bl, 0Fh		; 每读一个扇区打一个点
    int 10h
    pop bx
    pop ax

    mov cl, 1 ;读一个扇区
    call ReadSector
    pop ax
    call GetFATEntry
    cmp ax, 0FFFh
    jz LABEL_FILE_LOADED
    push ax ; 保存当前序号
    mov dx, RootDirSectors
    add	ax, dx
	add	ax, DeltaSectorNo
    add bx, [BPB_BytsPerSec]
    jmp LABEL_GOON_LOADING_FILE

LABEL_FILE_LOADED:
    call KillMotor
    mov dh, 1
    call DispStrRealMode

    lgdt [GdtPtr]

    cli

    in al, 92h
    or al, 00000010b
    out 92h, al

    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp dword  SelectorFlatC:(BaseOfLoaderPhyAddr+Label_PM_START)

    jmp $

; end of function (main)
wRootDirSizeForLoop	dw	RootDirSectors	; Root Directory 占用的扇区数，
						; 在循环中会递减至零
wSectorNo		dw	0		; 要读取的扇区号
bOdd			db	0		; 奇数还是偶数
dwKernelSize		dd	0
KernelFileName		db	"KERNEL  BIN", 0 ; LOADER.BIN 之文件名
; 为简化代码, 下面每个字符串的长度均为 MessageLength
MessageLength		equ	9

; 输出字符串（加载结果）
LoadMessage:		db	"Loading  "
Message1 db "Ready.   "
Message2 db "No KERNEL"

; function DispStrRealMode
DispStrRealMode:
    mov ax, MessageLength
    mul dh
    add ax, LoadMessage ; 计算起始地址
    mov	bp, ax
    mov ax, ds
    mov es, ax          ; es:bp 源串起始地址
	mov	cx, MessageLength
	mov	ax, 01301h
	mov	bx, 0007h		; 页号为0(BH = 0) 黑底白字(BL = 07h,高亮)
	mov	dl, 0
    add	dh, 3
	int	10h			; int 10h， 输出
	ret
; end of function

; function ReadSector
; 用于读扇区（支持连续扇区读取）
ReadSector:
    push bp ; 调用者保留寄存器
    mov bp, sp
    sub esp, 2

    mov byte [bp - 2], cl
    push bx
    mov bl, [BPB_SecPerTrk]
    div bl
    inc ah  ; 余数
    mov cl, ah ; 起始扇区号
    mov dh, al
    shr al, 1
    mov ch, al
    and dh, 01h
    pop bx       ; bx为缓冲区偏移量

    mov dl, [BS_DrvNum]
.GoOnReading:
    mov ah, 2
    mov al, byte[bp-2]
    int 13h
    jc .GoOnReading ; 读取错误时CF = 1，需要重读

    add esp, 2
    pop bp

    ret
; end of function

;----------------------------------------------------------------------------
; 函数名: GetFATEntry
;----------------------------------------------------------------------------
; 作用:
;	找到序号为 ax 的 Sector 在 FAT 中的条目, 结果放在 ax 中
;	需要注意的是, 中间需要读 FAT 的扇区到 es:bx 处, 所以函数一开始保存了 es 和 bx
GetFATEntry:
    push es
    push bx
    push ax
    mov ax, BaseOfKernelFile
    sub ax, 0100h
    mov es, ax
    pop ax
    mov byte [bOdd], 0
    mov bx, 3
    mul bx
    mov bx, 2
    div bx
    cmp dx, 0
    jz LABEL_EVEN
    mov byte [bOdd], 1
LABEL_EVEN:
    xor dx, dx
    mov bx, [BPB_BytsPerSec]
    div bx ; ax 表示在第几个扇区

    push dx
    mov bx, 0
    add ax, SectorNoOfFAT1
    mov cl, 2
    call ReadSector

    pop dx ; 防止混淆， 被调用者保存
    add bx, dx
    mov ax, [es:bx]
    cmp byte [bOdd], 1
    jnz LABEL_EVEN_2
    shr ax, 4
LABEL_EVEN_2:
    and ax, 0FFFh

LABEL_GET_FAT_ENRY_OK:

    pop bx
    pop es
    ret
; end of function


; 关闭软驱马达
; function KillMotor
KillMotor:
    push dx
    mov dx, 03F2H
    mov al, 0
    out dx, al
    pop dx
    ret
; end of function

[SECTION .s32]

ALIGN 32

[BITS 32]
; 
Label_PM_START:
    mov ax, SelectorVideo
    mov gs, ax

    mov ax, selectorFlatRW
    mov ds, ax
    mov	es, ax
	mov	fs, ax
	mov	ss, ax
	mov	esp, TopOfStack

    push	szMemChkTitle
	call	DispStr
	add	esp, 4

	call	DispMemInfo
	call	SetupPaging


    ; mov ah, 0Fh
    ; mov al, 'P'
    ; mov [gs:((80 * 0 + 39) * 2)], ax
    call InitKernel

    jmp	SelectorFlatC:KernelEntryPointPhyAddr ; 跳入内核程序

; end of function

%include "lib.inc"
; function DispMemInfo

DispMemInfo:
    ; push
    push	esi
	push	edi
	push	ecx

    mov esi, MemChkBuf
    mov ecx, [dwMCRNumber]
.loop:
    mov edx, 5
    mov edi, ARDStruct
.1:
    push dword[esi]
    call DispInt
    pop eax
    stosd
    add	esi, 4		  ;
	dec	edx		  ;
	cmp	edx, 0		  ;
	jnz	.1		  ;  }
	call	DispReturn	  ;  printf("\n");
	cmp	dword [dwType], 1 ;  if(Type == AddressRangeMemory)
	jne	.2		  ;  {
	mov	eax, [dwBaseAddrLow];
	add	eax, [dwLengthLow];
	cmp	eax, [dwMemSize]  ;    if(BaseAddrLow + LengthLow > MemSize)
	jb	.2		  ;
	mov	[dwMemSize], eax  ;    MemSize = BaseAddrLow + LengthLow;
.2:				  ;  }
	loop	.loop		  ;}
				  ;
	call	DispReturn	  ;printf("\n");
	push	szRAMSize	  ; 常量
	call	DispStr		  ;printf("RAM size:");
	add	esp, 4		  ;
				  ;
	push	dword [dwMemSize] ;
	call	DispInt		  ;DispInt(MemSize);
	add	esp, 4		  ;

	pop	ecx
	pop	edi
	pop	esi
	ret
; end of function

; function of SetupPaging
; 根据内存大小获取PDE和页表
SetupPaging:

    xor edx, edx
    mov eax, dwMemSize
    mov ebx, 400000h ; 4096(页大小) * 1024(页表条目数)
    div ebx
    mov ecx, eax
    test edx, edx
    jz .no_remainder
    inc ecx
.no_remainder:
    push ecx ; 页表个数

    mov ax, selectorFlatRW
    mov es, ax
    mov edi, PageDirBase
    xor eax, eax
    mov eax, PageTblBase | PG_P | PG_USU | PG_RWW
.1:
    stosd
    add eax, 4096
    loop .1

    pop eax ; 页表个数
    mov ebx, 1024; 每个页表1024个PTE
    mul ebx
    mov ecx, eax ; 页个数
    mov edi, PageTblBase
    xor eax, eax
    mov eax, PG_P  | PG_USU | PG_RWW

.2:
    stosd
    add eax, 4096
    loop .2
    
    ; 打开分页机制
    mov eax, PageDirBase
    mov cr3, eax

    mov eax, cr0
    or	eax, 80000000h
	mov	cr0, eax
	jmp	short .3
.3:
    nop

    ret

; end of function

; function InitKernel
InitKernel:
    xor esi, esi
    mov cx, word [BaseOfKernelFilePhyAddr+2Ch]
    movzx ecx, cx ; 段的个数
    mov esi, [BaseOfKernelFilePhyAddr + 1Ch] ;program header起始地址
    add esi, BaseOfKernelFilePhyAddr
.Begin:
    mov eax, [esi + 0]
    cmp eax, 0
    jz .NoAction
    push dword [esi + 010h] ; size
    mov eax, [esi + 04h] ; offset
    add eax, BaseOfKernelFilePhyAddr ; 段首字节
    push eax
    push  dword [esi + 08h] ; 实际位置
    call  MemCpy
    add   esp, 12                     ;/
.NoAction:
    add   esi, 020h ; 下一个
    dec   ecx
    jnz   .Begin

    ret
; end of function

[SECTION .data]
ALIGN 32

LABEL_DATA:

_szMemChkTitle:	db "BaseAddrL BaseAddrH LengthLow LengthHigh   Type", 0Ah, 0
_szRAMSize:	db "RAM size:", 0
_szReturn:	db 0Ah, 0
;; 变量
_dwMCRNumber:	dd 0	; Memory Check Result
_dwDispPos:	dd (80 * 6 + 0) * 2	; 屏幕第 6 行, 第 0 列
_dwMemSize:	dd 0
_ARDStruct:	; Address Range Descriptor Structure
  _dwBaseAddrLow:		dd	0
  _dwBaseAddrHigh:		dd	0
  _dwLengthLow:			dd	0
  _dwLengthHigh:		dd	0
  _dwType:			dd	0
_MemChkBuf:	times	256	db	0
;
;; 保护模式下使用这些符号
szMemChkTitle		equ	BaseOfLoaderPhyAddr + _szMemChkTitle
szRAMSize		equ	BaseOfLoaderPhyAddr + _szRAMSize
szReturn		equ	BaseOfLoaderPhyAddr + _szReturn
dwDispPos		equ	BaseOfLoaderPhyAddr + _dwDispPos
dwMemSize		equ	BaseOfLoaderPhyAddr + _dwMemSize
dwMCRNumber		equ	BaseOfLoaderPhyAddr + _dwMCRNumber
ARDStruct		equ	BaseOfLoaderPhyAddr + _ARDStruct
	dwBaseAddrLow	equ	BaseOfLoaderPhyAddr + _dwBaseAddrLow
	dwBaseAddrHigh	equ	BaseOfLoaderPhyAddr + _dwBaseAddrHigh
	dwLengthLow	equ	BaseOfLoaderPhyAddr + _dwLengthLow
	dwLengthHigh	equ	BaseOfLoaderPhyAddr + _dwLengthHigh
	dwType		equ	BaseOfLoaderPhyAddr + _dwType
MemChkBuf		equ	BaseOfLoaderPhyAddr + _MemChkBuf



StackSpace: times 1024 db 0
TopOfStack equ BaseOfLoaderPhyAddr + $
