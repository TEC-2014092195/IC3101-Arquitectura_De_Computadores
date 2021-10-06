Datos Segment 
    myWord dw 0102h 
Datos EndS

Codigo Segment 

comienceaqui:
	Assume cs:codigo, ds:datos
	
	xor ax,ax
	mov ax,Datos
	mov Ds,Ax
	
	xor ax,ax
	mov ax,myWord
	mov myWord,bx
	mov [di],bx
	mov [bx+2],ax
	mov [bx+si],ax
	mov word ptr[bx+di+2],1234h
	
	
	mov ax,4c00h
	int 21h
 
Codigo EndS 			
End comienceaqui			