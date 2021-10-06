Pila Segment 

     db 64 Dup ('Pila')
     
Pila EndS

Datos Segment 
     
     Mensaje   db 'Hola Mundo'
	 Mensaje2  db 'fenomeno dia... $'
	 var1	   db 5
	 var2	   db 2
	 var3      db ?
     
Datos EndS

Codigo Segment 
 Inicio:
      Assume CS:Codigo, DS:Datos, SS:Pila	
       
                              
       xor    cx,cx		
       mov    cx,Datos	
       mov    DS,cx	
      
       ;aqui va el código de instrucciones
       ;del programa.
	   
	   mov ah,var1
	   xor bx,bx
	   mov bl, offset mensaje
	   add bl,28
	   xor si,si
	   mov si,bx
	   mov al,Byte ptr [si]
	   add ah,al    ;se guarda el resultado en el primer operando
	   mov var3,ah
	   
	   mov ah, 09h  ;Mostar lo que tiene mensaje en ventana
	   mov dx, offset mensaje
	   add dx,0bh ; siempre empieza con 0 y termina en h por la h de hexadecimal o sea va a agregar una B a dx
	   int 21h
	   

	   xor ax,ax		;prepara el ah y al para la int 21h 4c00h.
       mov ax,4c00h 	;int 21h ah=4ch al=00h
       int 21h	   		;ejecute DOS. (termine el programa con codigo 00).
Codigo EndS 			
     End Inicio			