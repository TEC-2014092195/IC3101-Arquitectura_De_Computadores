;-------------------------------------------;
;Estructura de un programa en ensamblador,  ;
;para arquitectura 8086/8088/80306 mips     ;
;Creado por: Ing. Carlos Benavides C. MsC.  ;
;Propósito: Docente, académico, ejemplo.    ;
;Forma de compilación:                      ;
;  Usando el turbo assembler de borland 4.  ;
;    tasm /zi /l quinto[.asm]               ;
;    tlink /v quinto[.oobj]                 ;
;                                           ;
; y si lo quiere depurar turbo debuger      ;
;                                           ;
;      td quinto[.exe]                      ;
; FUM: Mayo 16, 2003.                       ;
;-------------------------------------------;

SSeg Segment para Stack 'Stack'

     db 64 Dup ('SegStack ')
     
SSeg EndS

SData Segment para 'Data'
     
     Message db 'Hola Mundo',10,13,'$'
     
SData EndS

  extrn ClearScreen:Far,PrintfS:Far,PrintfC:Far
  extrn GotoXY:Far,WhereXY:Far,PrintHex:Far
  
;-------------------------------;
;     Definición de Macros	;
;(afuera del segmento de código);
;-------------------------------;

PushA Macro 
       push      ax		;Guarda los todos los registro en... 
       push      bx		;...la pila del programa.
       push      cx		;Preparación para rutinas
       push      dx		;Debe tener cuidado de llamar a la...
       push      si		;...siguiente macro (PopAllRegs) para...
       push      di		;poner equilibrar la pila...
       push      bp		;...sino lo hace el programa se cae...
       push      sp		;...y da un error.
       push      ds		;Note que el último elemento del pushallregs...
       push      es		;...es el primer elemento en salir en popallregs.
       push      ss
       pushf			;Guarda el registro de banderas en la pila.
EndM				;Su contra parte es la macro siguiente. 

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

CSeg Segment para public 'Code'  ;Define el segmento de código para tasm.
 
 main Proc Far                   ;Procedimiento principal como main{ } en C.
      Assume CS:CSeg, SS:SSeg    ;Asignación de los segmentos a los registro de segmentos del CPU.
       
        push     DS              ;Guardar posición del reg DS en la pila.
        xor      ax,ax           ;Pone en cero al reg ax.
        push     ax              ;Guarda el desplazamiento cero en la pila.
        mov      ax,SData        ;Mueve la posición de SData al reg ax.
        mov      DS,ax           ;Mueve la posición de ax (SData) al reg DS.
        mov      ES,ax           ;Mueve la posición de ax (SData) al reg ES.
     
        PushA		 ;guardar el estado del CPU.

        PushA

        mov      al,25		 ;Número de líneas por desplazar en este caso total de filas 25.
        mov      bh,0fh  	 ;Atributo con que se va a desplazar; es decir; color. 00 = negro.
        mov      ch,00		 ;En donde comienza: fila de la esquina superior izquierda.
        mov      cl,00	  	 ;En donde comienza: columna de la esquina superior izquierda.
        mov      dh,25		 ;En donde termina:  fila de la esquina inferior derecha.
        mov      dl,80		 ;En donde termina:  columna de la esquina inferior derecha.
        call     ClearScreen     ;limpiar la pantalla y preparar el color del texto.
        PopA
        
        mov      cl,00           ;imprimir 15 veces hola mundo.
ciclo1: inc      cl		 ;disminuya el ciclo.
	PushA

        mov      al,cl		 ;preserve el ciclo. al con el caracter a imprimir.
	call     PrintHex 	 ;conviertalo a ascii.
	call     WhereXY
	xor      bh,bh		 ;pagina actualmente desplegada.
	inc      dl 		 ;incremente la columna.
	call     GotoXY  
	xor      bl,bl           ;pagina actualmente desplegada.
	mov      dl,255          ;espacion en blanco.
        call 	 PrintfC         ;imprime un espacio en blanco.
        call     WhereXY
        inc      dl  
        call     GotoXY   
        lea	 dx,Message
        call 	 PrintfS         ;imprimir Message terminada por el caracter $.
        PopA
        
        cmp      cl,0fh          ;todos los colores? 
    jl  ciclo1			 ;salto directamente a ciclo1.
        PopA  		 ;Saque todos los registros.

        ret                      ;Retorna el control al SO.      
 main EndP                       ;Fin del procedimiento principal main.



CSeg EndS                        ;Fin del segmento de código.
     End main                    ;Fin del programa la etiqueta al final dice en que punto debe comenzar el programa.