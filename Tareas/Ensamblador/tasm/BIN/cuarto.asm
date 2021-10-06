;-------------------------------------------;
;Estructura de un programa en ensamblador,  ;
;para arquitectura 8086/8088/80306 mips     ;
;Creado por: Ing. Carlos Benavides C. MsC.  ;
;Propósito: Docente, académico, ejemplo.    ;
;Forma de compilación:                      ;
;  Usando el turbo assembler de borland 4.  ;
;    tasm /zi /l cuarto[.asm]              ;
;    tlink /v cuarto[.oobj]                ;
;                                           ;
; y si lo quiere depurar turbo debuger      ;
;                                           ;
;      td cuarto[.exe]                     ;
; FUM: Mayo 16, 2003.                       ;
;-------------------------------------------;

SSeg Segment para Stack 'Stack'

     db 64 Dup ('SegStack ')
     
SSeg EndS

SData Segment para 'Data'
     
     Message db 'Hola Mundo',10,13,'$'
	 Col db 0
     Fil db 0
     
SData EndS

;-------------------------------;
;     Definición de Macros		;
;(afuera del segmento de código);
;-------------------------------;

PushA Macro 
       push      ax							;Guarda los todos los registro en... 
       push      bx							;...la pila del programa.
       push      cx							;Preparación para rutinas
       push      dx							;Debe tener cuidado de llamar a la...
       push      si							;...siguiente macro (PopAllRegs) para...
       push      di							;poner equilibrar la pila...
       push      bp							;...sino lo hace el programa se cae...
       push      sp							;...y da un error.
       push      ds							;Note que el último elemento del pushallregs...
       push      es							;...es el primer elemento en salir en popallregs.
       push      ss
       pushf									;Guarda el registro de banderas en la pila.
EndM										;Su contra parte es la macro siguiente. 

PopA Macro
       popf		        ;...la pila del programa.
       pop       ss	        ;Esto se hace después de la llamada a una rutina
       pop       es	        ;Debe tener cuidado de llamar a esta...
       pop       ds	        ;...macro (PopAllRegs) para...
       pop       sp	        ;poner equilibrar la pila...
       pop       bp		;...solamente después de haber...
       pop       di		;...llamado antes a pushallregs.
       pop       si		; Sino se produce un error en el programa.
       pop       dx
       pop       cx
       pop       bx
       pop       ax
EndM
   
ClearScreen Macro TextColor
       PushA
       mov       ah,07		;Prepara servicio 07 para la int 10h. (desplazamiento de ventana hacia abajo).
       mov       al,25		;Número de líneas por desplazar en este caso total de filas 25.
       mov       bh,TextColor	;Atributo con que se va a desplazar; es decir; color. 00 = negro.
       mov       ch,00		;En donde comienza: fila de la esquina superior izquierda.
       mov       cl,00		;En donde comienza: columna de la esquina superior izquierda.
       mov       dh,25		;En donde termina:  fila de la esquina inferior derecha.
       mov       dl,80		;En donde termina:  columna de la esquina inferior derecha.
       int       10h		;ejecute la int 10h/ servicio 07h, desplaze la ventana hacia abajo.
       PopA
EndM

PrintfS Macro String
       lea       dx,String      ;Coloca la dirección del desplazamiento de la etiqueta DS:Message 
       mov       ah,09          ;parámetro 09 del servicio de int 21 (imprimir en pantalla cadena terminada en $)
       int       21h            ;ejecute la interrupción, e imprima en pantalla.
EndM

PrintfC Macro Caracter, Atributo
       PushA     	        ;Guarde todos los registros.
       mov       ah,09          ;Servicio de int 21h / 02 imprimir un caracter en pantalla.
       mov       dl,Caracter    ;Caracter Ascii a imprimir.
       mov       bh,00
       mov       bl,Atributo
       and       bl,00001111b
       mov	 cx,1
       int       10h            ;ejecute la interrupción, e imprima en pantalla.
       PopA     	    	;Saque todos los registros.
EndM

GotoXY Macro X,Y
       PushA
       mov       ah,02
       mov	 bh,00
       mov	 dl,X
       mov	 dh,Y
       int 	 10h
       PopA
EndM

WhereXY Macro 
       PushA
       mov	 ah,03
       mov	 bh,00
       int	 10h
       mov	 Col,dl
       mov	 Fil,dh
       PopA
EndM

PrintHex Macro Numero
       local     hex, exit
       PushA
       mov       al,Numero
       cmp       al,09h
       jnle      hex 
       add       al,48
       PrintfC   al,Numero
       jmp short exit 
  hex: add       al,55  
       PrintfC   al,Numero
 exit: PopA
EndM

CSeg Segment para public 'Code'  ;Define el segmento de código para tasm.
   

 
 main Proc Far                   ;Procedimiento principal como main{ } en C.
      Assume CS:CSeg, SS:SSeg    ;Asignación de los segmentos a los registro de segmentos del CPU.
       
        push     DS              ;Guardar posición del reg DS en la pila.
        xor      ax,ax           ;Pone en cero al reg ax.
        push     ax              ;Guarda el desplazamiento cero en la pila.
        mov      ax,SData        ;Mueve la posición de SData al reg ax.
        mov      DS,ax           ;Mueve la posición de ax (SData) al reg DS.
        mov      ES,ax           ;Mueve la posición de ax (SData) al reg ES.
     
        PushA    		 ;guardar el estado del CPU.
        ClearScreen 0fh    	 ;limpiar la pantalla y preparar el color del texto.
        mov      cl,00           ;imprimir 15 veces hola mundo.
ciclo1: inc      cl		 ;disminuya el ciclo.
        mov      dl,cl		 ;preserve el ciclo.
	PrintHex dl		 ;conviertalo a ascii.
        WhereXY
        inc      Col  
        GotoXY   Col,Fil
        PrintfC  255,00          ;imprime un espacio en blanco.
        WhereXY
        inc      Col  
        GotoXY   Col,Fil
        PrintfS  Message         ;imprimir Message terminada por el caracter $.
        cmp      cl,0fh          ;todos los colores? 
    jl  salto1			 ;no se puede mandar directamente a ciclo1.
        PopA      		 ;Saque todos los registros.

        ret                      ;Retorna el control al SO.      
salto1: jmp ciclo1		 ;salto extensivo a ciclo1. fuera del código está bajo el ret al SO.
 main EndP                       ;Fin del procedimiento principal main.
CSeg EndS                        ;Fin del segmento de código.
     End main                    ;Fin del programa la etiqueta al final dice en que punto debe comenzar el programa.