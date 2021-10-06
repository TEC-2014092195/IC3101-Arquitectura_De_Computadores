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

SPila Segment para Stack 'Stack'

     db 64 Dup ('SegStack ')
     
SPila EndS

SDato Segment para public'Data'
	Message     db	'Hola Mundo',10,13,'$'
	Textcolor	db	01h
      Fila        db    0h
      Columna     db    0h
      LineCommand db    0FFh Dup (?)
      Param1      db    0FFh Dup (?)
      Param2      db    0FFh Dup (?)
      Param3      db    0FFh Dup (?)
      Param4      db    0FFh Dup (?)
      Param5      db    0FFh Dup (?)
      Param6      db    0FFh Dup (?)
      Param7      db    0FFh Dup (?)
SDato EndS

;-------------------------------;
;	Definici�n de Macros		;
;(afuera del segmento de c�digo);
;-------------------------------;

      ListPush  Macro lista
            IRP i,<lista>
               Push i
            EndM
      EndM

      ListPop  Macro lista
            IRP i,<lista>
               Pop i
            EndM
      EndM
      
	PushA Macro 
            ListPush <Ax, Bx, Cx, Dx, Si, Di, Bp, Sp>
      EndM										;Su contra parte es la macro siguiente. 

	PopA Macro
            	 								;...la pila del programa.
            Pop   Sp									;poner equilibrar la pila...
            Pop   Bp									;...solamente despu�s de haber...
            Pop   Di									;...llamado antes a pushallregs.
            Pop   Si									;Sino se produce un error en el programa.
            Pop   Dx
            Pop   Cx
            Pop   Bx
            Pop   Ax
	EndM
      
SCodigo Segment para public 'Code'					;Define el segmento de c�digo para tasm.
	Assume CS:SCodigo, SS:SPila, DS:SDato					;Asignaci�n de los segmentos a los registro de segmentos del CPU.

	;---------------------------------------;
	;	 Definici�n de Procedimientos     ;
	; (dentro del segmento de c�digo)       ;
	; (pero afuera de la l�nea de ejecuci�n ;
	; pero debe estar asumido el segmento   ;
	; de c�digo para los procedimientos     ;
	; pues son de tipo near.		    ;
	;---------------------------------------;

	;------------------------------------------------------;
	;                Par�metros de entrada                 ;
	;------------------------------------------------------;
	;       Al,N�mero de l�neas por desplazar.             ;
	;       Bh,Atributo. Pero este atributo se le pasa     ;
      ;       como par�metro mediante una variable gobal     ;
      ;       llamada TextColor.
	;       Ch,Fila de la esquina superior izquierda.      ;
	;       Cl,Columna de la esquina superior izquierda.   ; 
	;       Dh,Fila de la esquina inferior derecha.        ;
	;       Dl,Columna de la esquina inferior derecha.     ;
	;------------------------------------------------------;
	;                 Par�metros de salida                 ;
	;------------------------------------------------------;
	;       				                         ;
	;         		Ninguno				       ; 
	;						       		 ;
	;------------------------------------------------------;  
      ClearScreen Proc Far
            PushA
            Mov   Ah,07								;Prepara servicio 07 para la Pop 10h. (desplazamiento de ventana hacia abajo).
            Mov   Al,25								;N�mero de l�neas por desplazar en este caso total de filas 25.
            Mov   Bh,OffSet Ds:TextColor                           ;A modo de ejemplo para ver el efecto de no ponerle que transfiera un byte...
            Mov   Bh,Byte Ptr OffSet Ds:TextColor			;Atributo con que se va a desplazar; es decir; color. 00 = negro.
            Mov   Ch,00								;En donde comienza: fila de la esquina superior izquierda.
            Mov   Cl,00								;En donde comienza: columna de la esquina superior izquierda.
            Mov   Dh,25								;En donde termina:  fila de la esquina inferior derecha.
            Mov   Dl,80								;En donde termina:  columna de la esquina inferior derecha.
            Int   10h								;ejecute la Pop 10h/ servicio 07h, desplaze la ventana hacia abajo.
            PopA
            RetF        								;Se debe retornar o el programa se queda pegado.
      ClearScreen EndP
	
	
	;------------------------------------------------------;
	;                Par�metros de entrada                 ;
	;------------------------------------------------------;
	;  Dx, Debe contener el OffSet del texto a desplegar.  ;
	;------------------------------------------------------;
	;                 Par�metros de salida                 ;
	;------------------------------------------------------;
	;       				                         ;
	;         		Ninguno			       	 ; 
	;						       		 ;
	;------------------------------------------------------;
      PrintfS Proc Near
            PushA
            ;Lea  Dx,String						;Este par�metro debe ser pasado afuera. 
            Mov   Ah,09							;par�metro 09 del servicio de Pop 21 (imprimir en pantalla cadena terminada en $)
            Int   21h							;ejecute la interrupci�n, e imprima en pantalla.
            PopA
            Ret
      PrintfS EndP


	;------------------------------------------------------;
	;                Par�metros de entrada                 ;
	;------------------------------------------------------;
	;       Bl,Atributo o color con que se despliega.      ;
	;       Dl,Caracter a desplegar.                       ;
	;------------------------------------------------------;
	;                 Par�metros de salida                 ;
	;------------------------------------------------------;
	;       				                         ;
	;         		Ninguno			             ; 
	;						      		 ;
	;------------------------------------------------------;
      PrintfC Proc Near
            PushA
            Mov   Ah,02							;Servicio de Pop 21h / 02 imprimir un caracter en pantalla.
            ;Mov  Al,Caracter						;Este par�metro debe ser pasado afuera.
            Mov   Bh,00
            ;Mov  Bl,Atributo						;Este par�metro debe ser pasado afuera.
            Int   10h							;ejecute la interrupci�n, e imprima en pantalla.
            PopA
            Ret
      PrintfC EndP

	
	;------------------------------------------------------;
	;                Par�metros de entrada                 ;
	;------------------------------------------------------;
	;       Bh,Pagina de video a mandar.                   ;
	;       Dh,Fila. 				      		 ;
	;       Dl,Columna.				     		 ;
	;------------------------------------------------------;
	;                 Par�metros de salida                 ;
	;------------------------------------------------------;
	;       				         			 ;
	;         		Ninguno			   		 ; 
	;						      		 ;
	;------------------------------------------------------;	
      GotoXY Proc Far
            Push  Dx
            Push  Bp
            Mov   Bp,Sp
            Mov   Dx,[Bp+08h]
            ;Mov  Dl,Col tiene la columna
            ;Mov  Dh,Fil tiene la fila
            Mov   Ah,02h
            Mov   Bh,00h
            Int   10h
            Pop   Bp
            Pop   Dx
            RetF
      GotoXY EndP

	;------------------------------------------------------;
	;                Par�metros de entrada                 ;
	;------------------------------------------------------;
	;       Bh,Atributo.                                   ;
	;------------------------------------------------------;
	;                 Par�metros de salida                 ;
	;------------------------------------------------------;
	;       Dh,Fila.                                       ;
	;       Dl,Columna.                                    ;
	;------------------------------------------------------;
      WhereXY Proc Far
            Push  Ds      
            Push  Dx
            Push  Bp
            Mov   Bp,Sp
            ;Mov  Col,Dl tiene la columna
            ;Mov  Fil,Dh tiene la fila
            Mov   Ah,03
            Mov   Bh,00
            Int   10h
            Mov   Di,10[Bp]
            Mov   Ax,12[Bp]
            Mov   Ds,Ax
            Mov   Byte Ptr Ds:[Di],Dl
            Mov   Di,14[Bp]
            Mov   Ax,16[Bp]
            Mov   Ds,Ax
            Mov   Byte Ptr Ds:[Di],Dh
            Pop   Bp
            Pop   Dx
            Pop   Ds
            RetF  8
      WhereXY EndP

	;------------------------------------------------------;
	;                Par�metros de entrada                 ;
	;------------------------------------------------------;
	;       Al contiene el n�mero Ascii a convertir.       ;
      ;       Sin embargo se pasa como un par�metro por      ;
      ;       valor mediante el registro Ax v�a la pila.     ;
	;------------------------------------------------------;
	;                 Par�metros de salida                 ;
	;------------------------------------------------------;
	;       				                         ;
	;         		Ninguno			       	 ; 
	;						      		 ;
	;------------------------------------------------------;	
      PrintHex Proc Near
            Push  Ax                                  ;Se salvan los registro que se utilizaran.
            Push  Bx                                  ;todo por precauci�n y no dejar en mal estado al cpu.
            Push  Bp                                  ;incluyendo el puntero base auxiliar en la pila                 
            Mov  Bp,Sp                               ;hacemos apuntar al puntero base a la cima de la pila...
            Mov  Ax,[BP+08h]                         ;sacamos el par�metro sumando 2 por cada push realizado... por eso se le suman 10...
            cmp  Al,09h                              ;empieza el cuerpo del procedimiento...
            jnle  hex 
            Mov   Bl,Al
            add   Al,48
            Call  PrintfC
            jmp short exit 
      hex: 
            Mov   Bl,Al
            add   Al,55
            Call  PrintfC
      exit:                                         ;termina el cuerpo del procedimiento... 
            Pop   Bp                                 ;y se prepara para la salidad del mismo restaurando y equilibrando la pila nuevamente...
            Pop   Bx                                 ;empezando por la restauraci�n de la cima de la pila...
            Pop   Ax
            Ret 2                                    ;retorne al programa principal y mueva el tope de la pila sin el par�metro metido por el ax...
      PrintHex EndP                                 ;as� la pila se equilibra y contin�a el programa como si nada hubiera sucedido...
	
      ;------------------------------------------------------;
	;                Par�metros de entrada                 ;
	;------------------------------------------------------;
	;       Bh,Atributo.                                   ;
	;------------------------------------------------------;
	;                 Par�metros de salida                 ;
	;------------------------------------------------------;
	;       Dh,Fila.                                       ;
	;       Dl,Columna.                                    ;
	;------------------------------------------------------;
      GetCommanderLine Proc Near
            LongLC    EQU   80h
            ListPush  <Es, Di, Si, Cx, Bp>      
            Mov   Bp,Sp 
            Mov   Ax,Es
            Mov   Ds,Ax
            Mov   Di,12[Bp]
            Mov   Ax,14[Bp]
            Mov   Es,Ax
            Xor   Cx,Cx
            Mov   Cl,Byte Ptr Ds:[LongLC]
            Mov   Si,2[LongLC]                        ;dos = uno por la posici�n 81h y uno m�s por el espacio en blanco.
            Rep   Movsb
            ListPop <Bp, Bx, Si, Di, Es>
            Ret   14
      GetCommanderLine EndP
	
      ;------------------------------------------------------;
	;                Par�metros de entrada                 ;
	;------------------------------------------------------;
	;       Bh,Atributo.                                   ;
	;------------------------------------------------------;
	;                 Par�metros de salida                 ;
	;------------------------------------------------------;
	;       Dh,Fila.                                       ;
	;       Dl,Columna.                                    ;
	;------------------------------------------------------;
      EvalCommanderLine Proc Near
        Jmp Short BeginPro1                                ;permite la declaraci�n de variables locales.
            TempoLongLC DB    0h                           ;variable local, no se puede iniciar ac� porque detiene el c�digo pues no es una instrucci�n.
        BeginPro1:
            LonguitudLC EQU   80h
            ListPush  <Es, Di, Si, Cx, Bp>      
            Mov   Bp,Sp 
            Mov   Di,12[Bp]
            Mov   Ax,14[Bp]
            Mov   Ds,Ax
            Mov   Cx,Di
            Push  Cx
            Mov   Cl,(Byte Ptr Es:[LonguitudLC])
            Dec   Cl                                        ;quite el espacio en el blanco en
            Mov   TempoLongLC,Cl
            Mov   Si,OffSet Ds:LineCommand
            Mov   Es,Ax 
            OtroParam:
                  Xor   Ch,Ch
                  Mov   Cl,TempoLongLC
                  Mov   Al,20h                                    ;espacio en blanco.
                  Dec   Cx
                  ClD
                  RepNE ScasB
                  
                  Mov   Di,OffSet Ds:Param1
                  Rep   Movsb
            Loop OtroParam
            ListPop <Bp, Bx, Si, Di, Es>
            Ret   14
      EvalCommanderLine EndP
;------------------------------------------------------;
;                Programa Principal                    ;
;------------------------------------------------------;
Begin:
      PushA											;Procedimiento principal como main{ } en C.
      Xor   Ax,Ax										;Pone en cero Al reg Ax.
      Mov   Ax,SDato									;Mueve la posici�n de SData Al reg Ax.
      Mov   DS,Ax							       		;Mueve la posici�n de Ax (SData) Al reg DS.
      Xor   Ax,Ax
      Mov   Ax,SPila
      Mov   SS,Ax								            ;guardar el estado del CPU.
      Call  ClearScreen								      ;limpiar la pantalla y preparar el color del texto.
      Mov   Ax,Seg LineCommand
      Push  Ax
      Lea   Ax,LineCommand
      Push  Ax
      Call  GetCommanderLine
      
      Mov   Ax,Seg LineCommand
      Push  Ax
      Lea   Ax,LineCommand
      Push  Ax
      Call  EvalCommanderLine
      
      Xor   Cx,Cx									;imprimir 15 veces hola mundo.
      ciclo:
            Inc   Cl								;disminuya el ciclo.                                                ;Prepare el CPU para la llamada de procedimiento.
            Xor   Ax,Ax                                            ;Limpie el valor del Ax para la preparaci�n del paso de par�metro por valor v�a la Pila.
            Mov   Al,Cl								;preserve el ciclo. Al con el caracter a imprimir.                                              ;Pase el par�metro pr valor a la pila...
            Call  PrintHex 							;conviertalo a ascii.
            Mov   Ax,Seg Fila
            Push  Ax
            Lea   Ax,Fila
            Push  Ax
            Mov   Ax,Seg Columna
            Push  Ax
            Lea   Ax,Columna
            Push  Ax
            Call  WhereXY
            Push  Ax
            Xor   Bh,Bh								;pagina actualmente desplegada.
            Mov   Dl,Columna 								;incremente la columna.
            Mov   Dh,Fila
            Xor   Ax,Ax
            Mov   Ax,Dx
            Push  Ax
            Call  GotoXY
            Add   Sp,4
            Xor   Bl,Bl								;pagina actualmente desplegada.
            Mov   Al,255								;espacion en blanco.
            Call  PrintfC							;imprime un espacio en blanco.
            Mov   Ax,Seg Fila
            Push  Ax
            Lea   Ax,Fila
            Push  Ax
            Mov   Ax,Seg Columna
            Push  Ax
            Lea   Ax,Columna
            Push  Ax
            Call  WhereXY
            Mov   Dl,Columna
            Inc   Dl
            Mov   Dh,Fila
            Mov   Ax,Dx
            Push  Ax
            Call  GotoXY
            Add   Sp,4
            Lea   Dx,Message
            Call  PrintfS								;imprimir message terminada por el caracter $.
            cmp   Cl,0fh								;todos los colores? 
      Jl  Puente			 						;salto directamente a ciclo1.		
      PopA
      Mov   Ax,4c00h                                              ;Saque todos los registros.
      Int   21h
      
     Puente: 
        Inc Fila
        Mov   Dl,Columna
        Mov   Dh,Fila
        Mov   Ax,Dx
        Push  Ax
        Call  GotoXY
        Add   Sp,4
        Jmp Ciclo
SCodigo EndS										;Fin del segmento de c�digo.
      End Begin									;Fin del programa la etiqueta Al final dice en que punto debe comenzar el programa.