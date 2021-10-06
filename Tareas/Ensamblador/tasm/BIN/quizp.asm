Pila Segment Stack 'Stack'
	dw 2048 dup(?)
Pila Ends

Datos Segment
               
Datos Ends
	
Codigo Segment
	Assume DS:Datos,CS:Codigo,SS:Pila

inicio:
  
  mov ax,0013h
  int 10h
  mov ax, 0A000h
  mov ds, ax  

  
  mov cx,0C800h ; 
  xor dx,dx     
  xor di,di
 
 mov cx,10h
  columnas:
  
  mov [di], dx 
  inc di
  inc dx
  
  inc di
  inc di
  inc di
  inc di
  
  ;add di,0040h ; saltar al inicio de siguiente fila
  ;xor dx,dx    ; reiniciar columnas y color
  
  loop columnas

  

  ; esperar por tecla
  mov ah,10h
  int 16h

  ; regresar a modo texto
  mov ax,0003h
  int 10h
  
  ; finalizar el programa
  mov ax,4c00h
  int 21h
  
Codigo ENDS
END Inicio
