
include c:\tasm\suma\macro.cbc



Pila Segment 
	Dw 64 Dup(0) 
Pila EndS

Datos Segment
   ha db 'hola mundo$'
Datos EndS

	

Codigo Segment 
 


inicio:
Assume CS:Codigo, SS:Pila

	xor ax,ax
	mov ax, datos
	mov ds,ax
 
        PushAll
        
        mov ah,09h
        lea dx,ha
	int 21h       

        PopAll
	xor ax,ax
	mov ax,4c00h
	int 21h 

	
Codigo Ends
  
END inicio