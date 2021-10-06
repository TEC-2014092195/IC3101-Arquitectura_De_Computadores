extrn Delay1:Far,delay2:Far

Pila Segment
	db 64 Dup(' Pila ')
Pila EndS

Datos Segment
	VRAM dw 0B800h

Datos EndS

Codigo Segment
Assume cs:codigo, ds:datos, ss:pila
		



Inicio:
	xor cx,cx
	mov cx,Datos
	mov Ds,cx
	
	mov cx,7
	call delay1
	mov cx,7
	push cx
	call delay2
	
	mov ah,01h
	int 21h
	
	mov ax,4c00h
	int 21h
	
Codigo EndS
	End Inicio