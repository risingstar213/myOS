
%include "sconst.inc"

extern disp_pos

[SECTION .text]

global disp_str
global disp_color_str
global out_byte
global in_byte
global disable_irq
global enable_irq
global disable_int
global enable_int


disp_str:
    push	ebp
	mov	ebp, esp
	push	ebx
	push	esi
	push	edi

	mov	esi, [ebp + 8]	; pszInfo
	mov	edi, [disp_pos]
	mov	ah, 0Fh
.1:
	lodsb
	test	al, al
	jz	.2
	cmp	al, 0Ah	; 是回车吗?
	jnz	.3
	push	eax
	mov	eax, edi
	mov	bl, 160
	div	bl
	and	eax, 0FFh
	inc	eax
	mov	bl, 160
	mul	bl
	mov	edi, eax
	pop	eax
	jmp	.1
.3:
	mov	[gs:edi], ax
	add	edi, 2
	jmp	.1

.2:
	mov	[disp_pos], edi

	pop	edi
	pop	esi
	pop	ebx
	pop	ebp
	ret
; disp_str 结束------------------------------------------------------------

; function of disp_color_str
disp_color_str:
    push	ebp
	mov	ebp, esp
	push	ebx
	push	esi
	push	edi

	mov	esi, [ebp + 8]	; pszInfo
	mov	edi, [disp_pos]
	mov	ah, [ebp + 12]
.1:
	lodsb
	test	al, al
	jz	.2
	cmp	al, 0Ah	; 是回车吗?
	jnz	.3
	push	eax
	mov	eax, edi
	mov	bl, 160
	div	bl
	and	eax, 0FFh
	inc	eax
	mov	bl, 160
	mul	bl
	mov	edi, eax
	pop	eax
	jmp	.1
.3:
	mov	[gs:edi], ax
	add	edi, 2
	jmp	.1

.2:
	mov	[disp_pos], edi

	pop	edi
	pop	esi
	pop	ebx
	pop	ebp
	ret

; end of function

out_byte:
	mov edx, [esp + 4] ; port
	mov al, [esp + 8] ; value
	out dx, al
	nop ; 延迟
	nop
	ret

in_byte:
	mov edx, [esp + 4] ; port
	xor eax, eax
	in al, dx
	nop
	nop
	ret


enable_irq:
	mov ecx, [esp + 4]
	pushf
	cli
	mov ah, ~1
	rol ah, cl 
	cmp cl, 8
	jae enable_8
enable_0:
	in al, INT_M_CTLMASK
	and al, ah
	out INT_M_CTLMASK, al
	popf
	ret
enable_8:
	in al, INT_S_CTLMASK
	and al, ah
	out INT_S_CTLMASK, al
	popf
	ret

disable_irq:
	mov ecx, [esp + 4]
	pushf
	cli
	mov ah, 1
	rol ah, cl 
	cmp cl, 8
	jae disable_8
disable_0:
	in al, INT_M_CTLMASK
	test al, ah
	jnz dis_already 
	or al, ah
	out INT_M_CTLMASK, al
	popf
	mov eax, 1 ; return 1
	ret
disable_8:
	in al, INT_S_CTLMASK
	test al, ah
	jnz dis_already 
	or al, ah
	out INT_S_CTLMASK, al
	popf
	mov eax, 1 ; return 1
	ret
dis_already:
	popf
	xor eax, eax ; return 0
	ret

disable_int:
	cli
	ret

enable_int:
	sti
	ret
