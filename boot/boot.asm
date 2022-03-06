
%ifdef _BOOT_DEBUG_
    org 0100h
%else 
    org 07c00h
%endif

%ifdef _BOOT_DEBUG_
BaseOfStack  equ 0100h
%else
BaseOfStack equ 07c00h
%endif


    jmp short LABEL_START
    nop

%include "fat12hdr.inc"
%include "load.inc"

LABEL_START:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, BaseOfStack
    
    ; 清屏
	mov	ax, 0600h		; AH = 6,  AL = 0h
	mov	bx, 0700h		; 黑底白字(BL = 07h)
	mov	cx, 0			; 左上角: (0, 0)
	mov	dx, 0184fh		; 右下角: (80, 50)
	int	10h			; int 10h

	mov	dh, 0			; "Booting  "
	call	DispStr			; 显示字符串
	

    xor ah, ah
    xor dl, dl
    int 13h  ; 软驱复位

; 查找 LOADER.BIN
    mov word [wSectorNo], SectorNoOfRootDirectory ; 根目录起始扇区
LABEL_SEARCH_IN_ROOT_DIR_BEGIN:
    cmp word [wRootDirSizeForLoop], 0 ; 是否读完根目录
    jz LABEL_NO_LOADERBIN ; 读完
    dec word [wRootDirSizeForLoop] ; 读完一个扇区减一
    mov ax, BaseOfLoader
    mov es, ax ; Loader目的基址
    mov bx, OffsetOfLoader ; Loader目的偏移量
    mov ax, [wSectorNo] ;
    mov cl, 1
    call ReadSector

    mov si, LoaderFileName
    mov di, OffsetOfLoader
    cld
    mov dx, 10h
LABEL_SEARCH_FOR_LOADERBIN:
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
	mov	si, LoaderFileName
	jmp	LABEL_SEARCH_FOR_LOADERBIN

LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR:
    add word [wSectorNo], 1
    jmp LABEL_SEARCH_IN_ROOT_DIR_BEGIN

LABEL_NO_LOADERBIN:
    mov dh, 2
    call DispStr
%ifdef _BOOT_DEBUG_
    mov ax, 4c00h
    int 21h
%else
    jmp $
%endif

LABEL_FILENAME_FOUND:
    mov ax, RootDirSectors
    and di, 0FFE0h ; 32字节一个entry
    add di, 01Ah ; DIR_FstClus所在地址
    mov cx, word [es:di] ; 簇号
    push cx
    add cx, ax
    add cx, DeltaSectorNo
    mov	ax, BaseOfLoader
    mov es, ax
    mov bx, OffsetOfLoader
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
    mov dh, 1
    call DispStr

; 最终
    jmp	BaseOfLoader:OffsetOfLoader


wRootDirSizeForLoop	dw	RootDirSectors	; Root Directory 占用的扇区数，
						; 在循环中会递减至零
wSectorNo		dw	0		; 要读取的扇区号
bOdd			db	0		; 奇数还是偶数
LoaderFileName		db	"LOADER  BIN", 0 ; LOADER.BIN 之文件名
; 为简化代码, 下面每个字符串的长度均为 MessageLength
MessageLength		equ	9

; 输出字符串（加载结果）
BootMessage:		db	"Booting  "
Message1 db "Ready.   "
Message2 db "No LOADER"

DispStr:
    mov ax, MessageLength
    mul dh
    add ax, BootMessage ; 计算起始地址
    mov	bp, ax
    mov ax, ds
    mov es, ax          ; es:bp 源串起始地址
	mov	cx, MessageLength
	mov	ax, 01301h
	mov	bx, 0007h		; 页号为0(BH = 0) 黑底白字(BL = 07h,高亮)
	mov	dl, 0
	int	10h			; int 10h， 输出
	ret

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
    mov ax, BaseOfLoader
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


times 	510-($-$$)	db	0	; 填充剩下的空间，使生成的二进制代码恰好为512字节
dw 	0xaa55				; 结束标志