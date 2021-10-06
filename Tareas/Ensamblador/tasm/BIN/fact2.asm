Extrn factorial:Far

Pila Segment
	db 64 Dup (' Pila ')
Pila EndS

Datos Segment
	var db 3
Datos EndS


Codigo Segment
	Assume CS: Codigo, DS:Datos, SS:Pila
	
	Inicio:
		xor cx,cx
		mov cx,Datos
		mov DS,cx
		 
		push 3
		call factorial
		
		mov dl,bl
		add dl,26h
		
		mov ah, 02h			;se imprime en consola
		int 21h	
		
		
		mov ax,4c00h
		int 21h
Codigo EndS
	End Inicio
