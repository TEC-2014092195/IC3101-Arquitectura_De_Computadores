;-------------------------------------------;
;Estructura de un programa en ensamblador,  ;
;para arquitectura 8086/8088/80306 mips     ;
;Creado por: Ing. Carlos Benavides C. MsC.  ;
;Prop�sito: Docente, acad�mico, ejemplo.    ;
;Forma de compilaci�n:                      ;
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
;     Definici�n de Macros	;
;(afuera del segmento de c�digo);
;-------------------------------;

PushA Macro 
       push      ax		;Guarda los todos los registro en... 
       push      bx		;...la pila del programa.
       push      cx		;Preparaci�n para rutinas
       push      dx		;Debe tener cuidado de llamar a la...
       push      si		;...siguiente macro (PopAllRegs) para...
       push      di		;poner equilibrar la pila...
       push      bp		;...sino lo hace el programa se cae...
       push      sp		;...y da un error.
       push      ds		;Note que el �ltimo elemento del pushallregs...
       push      es		;...es el primer elemento en salir en popallregs.
       push      ss
       pushf			;Guarda el registro de banderas en la pila.
EndM				;Su contra parte es la macro siguiente. 

PopA Macro
       popf		        ;...la pila del programa.
       pop       ss	        ;Esto se hace despu�s de la llamada a una rutina
       pop       es	        ;Debe tener cuidado de llamar a esta...
       pop       ds	        ;...macro (PopAllRegs) para...
       pop       sp	        ;poner equilibrar la pila...
       pop       bp		;...solamente despu�s de haber...
       pop       di		;...llamado antes a pushallregs.
       pop       si		; Sino se produce un error en el programa.
       pop       dx
       pop       cx
       pop       bx
       pop       ax
EndM      

CSeg Segment para public 'Code'  ;Define el segmento de c�digo para tasm.
 
 main Proc Far                   ;Procedimiento principal como main{ } en C.
      Assume CS:CSeg, SS:SSeg    ;Asignaci�n de los segmentos a los registro de segmentos del CPU.
       
        push     DS              ;Guardar posici�n del reg DS en la pila.
        xor      ax,ax           ;Pone en cero al reg ax.
        push     ax              ;Guarda el desplazamiento cero en la pila.
        mov      ax,SData        ;Mueve la posici�n de SData al reg ax.
        mov      DS,ax           ;Mueve la posici�n de ax (SData) al reg DS.
        mov      ES,ax           ;Mueve la posici�n de ax (SData) al reg ES.
     
        PushA		 ;guardar el estado del CPU.

        PushA

        mov      al,25		 ;N�mero de l�neas por desplazar en este caso total de filas 25.
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



CSeg EndS                        ;Fin del segmento de c�digo.
     End main                    ;Fin del programa la etiqueta al final dice en que punto debe comenzar el programa.