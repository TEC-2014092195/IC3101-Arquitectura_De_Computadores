;-------------------------------------------;
;Estructura de un programa en ensamblador,  ;
;para arquitectura 8086/8088/80306 mips     ;
;Creado por: Ing. Carlos Benavides C. MsC.  ;
;Prop�sito: Docente, acad�mico, ejemplo.    ;
;Forma de compilaci�n:                      ;
;  Usando el turbo assembler de borland 4.  ;
;    tasm /zi /l priemro[.asm]              ;
;    tlink /v primero[.oobj]                ;
;                                           ;
; y si lo quiere depurar turbo debuger      ;
;                                           ;
;      td primero[.exe]                     ;
; FUM: Mayo 16, 2003.                       ;
;-------------------------------------------;

SSeg Segment para Stack 'Stack'

     db 64 Dup ('SegStack ')
     
SSeg EndS

SData Segment para 'Data'
     
     Mensaje  db 'Hola Mundo $'
     Mensaje2 db 'El resultado es: $'    
	 Mensaje4 db 'Veamos si ya regresamos donde debiamos... jejeje!!$'
SData EndS

PushHA Macro 
  push dx  
  push ax
  push bx
  push cx
EndM

PopHA Macro 
  pop cx  
  pop bx
  pop ax
  pop dx
EndM


CSeg Segment para public 'Code'	;Define el segmento de c�digo para tasm.
   Assume CS:CSeg, SS:SSeg	;Asignaci�n de los segmentos a los registro de segmentos del CPU.


ImprimirString Proc Near 
       mov  ah,09h
       int 21h	   
       ret			;Retorna el control al SO.      
ImprimirString EndP	

SumaPorValor Proc Near
       push ax
	   push bx
	   push bp


	   mov ax,2h
	   mov bp,sp	    ;Bp apunta al top o tope de la pila.
	   mov bx,bp[+08h]    ;saca el par�metro de la pila y coloca en el bx.
       xor bx,bx
	   mov bx,[bp+08h]
	   xor bx,bx
	   add bp,08h
	   mov bx,[bp]
	   xor bx,bx
	   mov bp,sp
	   add bp,2*4
	   mov bx,[bp]
	   
	   add ax,bx	    ;suma de precisi�n en 16bits por el paso de par�metros en la pila.
       
	   pop bp
	   pop bx
	   pop ax
	   
	   ret 2
SumaPorValor EndP

ImprimeStringPorReferencia Proc Near
       push bp
	   mov bp,sp
	   mov dx,4[bp]
	   mov ah,09h
	   int 21h
	   mov bp,sp	   
	   jmp 2[bp]	;equivalente al ret
ImprimeStringPorReferencia EndP        

ImprimeStringConSeg Proc Near
       push bp
	   push ds
	   mov bp,sp
	   mov dx,6[bp]
	   mov ax,8[bp]
	   mov ds,ax
	   mov ah,09h
	   int 21h
	   mov bp,sp	   
	   call 4[bp]	;equivalente al ret
ImprimeStringConSeg EndP		
		
		mensaje3  db 'esto es inaudito!!! yo en el seg de c�digo.... NOOOOOOO!!!!$'
Inicio:
       xor    ax,ax		;Pone en cero al reg ax.
       push   ax		;Guarda el desplazamiento cero en la pila.
       mov    ax,SData		;Mueve la posici�n de SData al reg ax.
       mov    DS,ax		;Mueve la posici�n de ax (SData) al reg DS.
       mov    ax,SSeg
	   mov    SS,ax
       
       ;aqui va el c�digo de instrucciones
       ;del programa.

	   mov dx,offset mensaje	;Paso de par�metros por registro.
	   call ImprimirString
	   
	   mov ax,5					;Tipo de par�metro por valor es decir lo que se env�a es el valor.
	   push ax 					;Paso de par�metros por pila.
	   call SumaPorValor
	   
	   lea ax,mensaje2
	   push ax
	   call ImprimeStringPorReferencia
	   add sp,6   ;falta sacar todo de la pila... que metio el procedimiento...
	   
	   mov ax,seg mensaje3
	   push ax
	   mov ax,offset mensaje3
	   push ax
	   call ImprimeStringConSeg
	   
	   mov dx,offset mensaje4
	   mov ah,09h
	   int 21h
	   
	   popf				;saca cualquier valor de la pila ya que pop no se puede usar sin par�metro...
	   pop ds			;as� debio salir del proc...
	   add sp,08h		;restaurando el ds a datos y el sp a su estado original...
	   
	   mov dx,offset mensaje4
	   mov ah,09h
	   int 21h
	   
	   mov ax,4c00h
	   int 21h
	   
	   
 		;Fin del procedimiento principal main.
CSeg EndS 			;Fin del segmento de c�digo.
     End Inicio			;Fin del programa la etiqueta al final dice en que punto debe comenzar el programa.
	 