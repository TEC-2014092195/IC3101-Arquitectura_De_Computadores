Pila Segment 

     db 64 Dup ('Pila')
     
Pila EndS

Datos Segment 
     
     Mensaje   db 'Hola Mundo'
	 Mensaje2  db 'fenomeno dia... $'
	 repitalo db 10,10,13,13,'Digite algo o s p/salir... ',10,13,'$'
	 var1	   db 5
	 var2	   db 2
	 var3	   db ?
	 tecla	   db ?
	 vectorAscii db 255 dup(?) 
     
Datos EndS


include libmac.khr
Codigo Segment 
 Inicio:
      Assume CS:Codigo, DS:Datos, SS:Pila	
       
			      
       xor    cx,cx		
       mov    cx,Datos	
       mov    DS,cx	
      
       ;aqui va el código de instrucciones
       ;del programa.
	   
	   ;
	   Limpiar 0eh,255,255 ;Macro Limpiar
	   
	   mov ah, 09h	;Mostar lo que tiene mensaje en ventana
	   mov dx, offset mensaje
	   add dx,0bh  ;siempre empieza con 0 y termina en h por la h de hexadecimal o sea va a agregar una B a dx
	   int 21h
	   
	   ;----------Interrupcion de una tecla
	   mov ah,00h
	   int 16h
	   ;----------Limpiar pantalla
	   Limpiar 0eh,040h,060h ;Macro Limpiar
		
	   mov var1,ah
	   
	   xor ax,ax		;prepara el ah y al para la int 21h 4c00h.
       mov ax,4c00h	;int 21h ah=4ch al=00h
       int 21h			;ejecute DOS. (termine el programa con codigo 00).
Codigo EndS			
     End Inicio 