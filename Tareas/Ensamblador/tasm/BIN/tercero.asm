;-------------------------------------------;
;Estructura de un programa en ensamblador,  ;
;para arquitectura 8086/8088/80306 mips     ;
;Creado por: Ing. Carlos Benavides C. MsC.  ;
;Propósito: Docente, académico, ejemplo.    ;
;Forma de compilación:                      ;
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
     
     Message db 'Hola Mundo $'
     
SData EndS

CSeg Segment para public 'Code'	;Define el segmento de código para tasm.
 Begin:
      Assume CS:CSeg, SS:SSeg	;Asignación de los segmentos a los registro de segmentos del CPU.
       
								;Va a reservar la dirección del PSP en el ES.       
       xor    ax,ax				;Pone en cero al reg ax.
       push   ax					;Guarda el desplazamiento cero en la pila.
       mov    ax,SData			;Mueve la posición de SData al reg ax.
       mov    DS,ax				;Mueve la posición de ax (SData) al reg DS.
  
       push   ax		 			;Guarda los reg ax, bx, cx, dx para usar con la int. 10h/07h.
       push   bx		 			;Preparación para limpiar la pantalla mediante el BIOS.
       push   cx		 			;Se limpiará mediante el desplazamiento de la...
       push   dx		 			;...ventana hacia abajo, dependiendo de sus parámetros. 
       mov    ah,07		 		;Prepara servicio 07 para la int 10h. (desplazamiento de ventana hacia abajo).
       mov    al,25		 		;Número de líneas por desplazar en este caso total de filas 25.
       mov    bh,01		 		;Atributo con que se va a desplazar; es decir; color. 00 = negro.
       mov    ch,00		 		;En donde comienza: fila de la esquina superior izquierda.
       mov    cl,00		 		;En donde comienza: columna de la esquina superior izquierda.
       mov    dh,25		 		;En donde termina:  fila de la esquina inferior derecha.
       mov    dl,80		 		;En donde termina:  columna de la esquina inferior derecha.
       int    10h		 		;ejecute la int 10h/ servicio 07h, desplaze la ventana hacia abajo.
       pop    dx		 			;Equilibre la pila antes de seguir.
       pop    cx		 			;Saque primero el último dato metido en la pila dx luego el cx...
       pop    bx		 			;...y así sucesivamente hasta equilibrar toda la pila.
       pop    ax		 			;puede continuar ejecutando el programa... esta instrucción y la siguiente se pueden omitir 
								;pues ya antes se ha guardado el valor del ax. Sin embargo, aqui se pone para efectos académicos.  
	  
	  
       push   ax              	;Guarda el valor del ax para ser usado por la int.
       xor    ax,ax            	;limpia el valor del ax y lo prepara para la interrupción.
       lea    dx,Message      	;Coloca la dirección del desplazamiento de la etiqueta DS:Message 
       mov   ah,09          		;parámetro 09 del servicio de int 21 (imprimir en pantalla cadena terminada en $)
       int    21h            	;ejecute la interrupción, e imprima en pantalla.
       pop    ax             	;equilibre la pila, saque y restaure al ax.

       xor ax,ax					;Limpia el al y prepara el ah para la salida.
       mov ax,4c00h 				;Servicio AH=4c int 21h para salir del programa.
       int 21h	   				;Llamada al DOS. Termine el programa.
CSeg EndS 						;Fin del segmento de código.
     End Begin					;Fin del programa la etiqueta al final dice en que punto debe comenzar el programa. 

