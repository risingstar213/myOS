[SECTION .text]

global memcpy
global memset

memcpy:
    push	ebp
	mov	ebp, esp

	push	esi
	push	edi
	push	ecx

	mov	edi, [ebp + 8]	; Destination
	mov	esi, [ebp + 12]	; Source
	mov	ecx, [ebp + 16]	; Counter
.1:
	cmp	ecx, 0		; 判断计数器
	jz	.2		; 计数器为零时跳出

	mov	al, [ds:esi]		; ┓
	inc	esi			; ┃
					; ┣ 逐字节移动
	mov	byte [es:edi], al	; ┃
	inc	edi			; ┛

	dec	ecx		; 计数器减一
	jmp	.1		; 循环
.2:
	mov	eax, [ebp + 8]	; 返回值

	pop	ecx
	pop	edi
	pop	esi
	mov	esp, ebp
	pop	ebp

	ret			; 函数结束，返回
; memcpy 结束-------------------------------------------------------------

memset:
	push ebp
	mov ebp, esp

	push edi
	push edx
	push ecx

	mov edi, [ebp + 8] ; array
	mov edx, [ebp + 12] ; number
	mov ecx, [ebp + 16] ; counter
.1:
	cmp ecx, 0
	jz .2
	mov byte[esi], dl
	inc edi
	dec	ecx	
	jmp .1
.2:
	pop ecx
	pop edx
	pop edi

	mov esp, ebp
	pop ebp

	ret