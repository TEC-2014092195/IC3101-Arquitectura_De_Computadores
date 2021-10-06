datos segment
	mensaje db "Presione cualquier tecla para conocer su codigo ascii, en hexadecimal y decimal",10,13,"$" ;Para imprimir $ pongo el ascii 24h
	tablahex db "ABCDEF"
	var2 db ?
datos EndS

codigo Segment
comienceaqui:
	Assume cs:codigo, ds:datos
	
	xor ax,ax
	mov ax,Datos
	mov Ds,Ax
	
	xor dx, dx
	
	mov dx,offset mensaje 
	mov ah,09h
	int 21h
	
	mov ah,01h
	int 21h
	mov var2,al
	
	mov dl,' '
	mov ah,02h
	int 21h
	mov dl,'-'
	mov ah,02h
	int 21h
	mov dl,'>'
	mov ah,02h
	int 21h
	mov dl,' '
	mov ah,02h
	int 21h
	
	mov dl,var2
	and dl,11110000b
	shr dl,4
	cmp dl,09h
	jg hex1
	add dl,30h
  v1: 
	mov ah,02h
	int 21h
	mov dl,var2
	and dl,00001111b
	cmp dl,09h
	jg hex2
	or dl,30h
  v2:
	mov ah,02h
	int 21h
	;Se repite la jugada de arriba, yo sè que se puede hacer por un proceso o una macro, pero no me acuerdo.
	mov dl,' '
	mov ah,02h
	int 21h
	mov dl,'-'
	mov ah,02h
	int 21h
	mov dl,'>'
	mov ah,02h
	int 21h
	mov dl,' '
	mov ah,02h
	int 21h
	;Se termina de repetir.
	mov cx, 3
  Deci_1:
	xor ax, ax
	xor bx, bx
	mov al, var2
	mov bl, 10
	div bl
	mov dl, ah
	add dl, 30h
	mov ah, 02h
	int 21h
	mov var2, al
	loop Deci_1
	
	
	
	mov ax,4c00h
	int 21h
  hex1:
	xor si,si
	mov si,dx
	sub si,0ah
	mov dl,tablahex[si]
	jmp short v1
  hex2:
	xor si,si
	mov si,dx
	sub si,0ah
	mov dl,tablahex[si]
	jmp short v2
	
	
	MOV AX,0B800H
    MOV ES,AX
	
	
	
	mov ax,4c00h
	int 21h
	
codigo EndS
End comienceaqui