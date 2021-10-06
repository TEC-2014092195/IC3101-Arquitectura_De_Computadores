Datos Segment 
     
Datos EndS

Delay Macro Param, Num
	mov cx,Num
Param: 
	push cx
	pop cx
	loop Param
EndM     
            

Codigo Segment 
comienceaqui:
	Assume cs:codigo, ds:datos
	
	xor ax,ax
	mov ax,Datos
	mov Ds,Ax
	
    Delay A,5
	
	
	mov ax,4c00h
	int 21h
 
Codigo EndS 			
End comienceaqui