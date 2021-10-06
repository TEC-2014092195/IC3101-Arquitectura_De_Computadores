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
     
SData EndS

   Include macros.cbc		;Llama la lib de macros...


CSeg Segment para public 'Code'  ;Define el segmento de código para tasm.
   
     Col db 0
     Fil db 0
 
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