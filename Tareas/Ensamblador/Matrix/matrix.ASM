; --------------------------------------------------------------------
;| Proyecto     : Matrix											  |	
;| Elaborado por: Kevin Hernandez Rostran                             |
;| Curso        : Arquitectura - Instituto Tecnologico de Costa Rica  |
; --------------------------------------------------------------------

Pila Segment Stack 'Stack'
	dw 2048 dup(?)
Pila Ends

Datos Segment
        FIL DB 0
        COL DB 0
        PAUSA1 dw 100
        PAUSA2 dw 100 ; pausa
		CONTAR_F DB 0
		CAMB_BG DB 0
		FLAG DB 0
		MSG DB 10,10,  '-------------------------------------------------------------------------------',10
		MSG1 DB        'Proyecto     : Matrix',10
		MSG2 DB        'Elaborado por: Kevin Hernandez Rostran',10
		MSG3 DB        'Curso        : Arquitectura - Instituto Tecnologico de Costa Rica',10
		MSG4 DB        'Este programa consiste en mostrar la animacion mostrada en la pelicula Matrix.',10
		MSG5 DB        'Se utiliza el modo texto para representar cada caracter.',10
		MSG6 DB        'Su implementacion es muy simple y utiliza los siguientes comandos:',10
		MSG7 DB        'matrix     => muestra la visualizacion en consola.',10
		MSG8 DB        'matrix /h => muestra la ayuda del programa.',10
		MSG9 DB        '**Para salir del programa solamente presione la tecla ESC**',10
		MSG20 DB       '-------------------------------------------------------------------------------', 10,10,'$'
		MSGInvalido DB 10,10, 'Invalido', 10,10,'$'
Datos Ends

Codigo Segment
	Assume DS:Datos,CS:Codigo,SS:Pila

Inicio:
		
;--------------------------------------Ayuda		
		Xor Bx, Bx ;para usarlo como apuntador del PSP
		Mov SI, 82h ; para usarlo como apuntador del PSP
		MOV BL, BYTE PTR [SI]-2; Esto es por que no es permitido pasarla direccion al DI directamente
		Xor Bh, Bh ;para limpiar la parte alta del registro
		
		CMP BX,0 ;Compara si no hay ningun parametro
		JE SEGUIRRUN
		; CMP BX,3      para parametros a mas de 3 char
		; JNE INVALIDO
		XOR BX,BX
		MOV BX,82h
		MOV DX,[BX]
		CMP DH,68h ;Es el caracter después del slash
		JE IMPRIMIR_AYUDA
		JMP INVALIDO
IMPRIMIR_AYUDA:
		XOR AX,AX
		MOV AX,DATOS
        MOV DS,AX
		LEA DX,MSG
		MOV AH,09h
		INT 21h
		JMP Salir2
		
INVALIDO:
		XOR AX,AX
		MOV AX,DATOS
        MOV DS,AX
		LEA DX,MSGInvalido ; carga mensaje
		MOV AH,09h
		INT 21h
		JMP Salir2

;--------------------------------------------
SEGUIRRUN:
		XOR AX,AX
		MOV AX,DATOS
        MOV DS,AX
        MOV AX,PILA
        MOV SS,AX
	 MOV AX,0B800H
		; --Clear Screen 
        MOV ES,AX
		mov ax,0B800h 
		mov es,ax 
		xor di,di 
		xor ax,ax 
		mov cx,2000d 
		cld 
		rep stosw 
		
	CALL MOVIMIENTO
Salir2:
        MOV AX, 4C00h
        INT 21h

MOVIMIENTO PROC NEAR ;se realizan todas las acciones de los caracteres
  
DESPLEGAR:
			XOR AX,AX
			MOV AL,160
	        MUL FIL ; calculo de filas
	        XOR BH, BH
			CMP CONTAR_F,12
			JE contar
			JMP contar2
contar:
			MOV CONTAR_F,0
	        MOV BL, DL ;Columna 
			MOV CL,DL
			AND CL,0111110b ;Color del caracter
			ADD COL,CL
			MOV CL,DL
			AND CL,00001110b
			
			MOV FIL,CL
			JMP DESPLEGAR
			JE seguir2
contar2:
			MOV BL, COL
			INC CONTAR_F
			JMP seguir2
   
seguir2:
		SHL BX,1
	    ADD BX,AX
		CMP FIL,3
		JE CONTINUAR
		JMP CONTINUAR2
CONTINUAR:
		MOV AH,08Fh
		JE SEGUIR
CONTINUAR2:
		MOV AH,00FH
        
SEGUIR:
		XOR CX,CX
		
		
		MOV WORD PTR ES:[BX],AX     ; Ponemos el caracter en pantalla
        MOV CX, PAUSA1       ;Pausa de movimiento
P1:     PUSH CX
        MOV CX, PAUSA2
P2:     NOP
        LOOP P2
        POP CX
        LOOP P1
		
		;MOV DH,001010b ; Cambia el Background del char que queda impreso, a verde con OAh 
					   ;otra forma: MOV DH,00001111b B-RGB-I-RGB; con B= blinking I= intensidad
		MOV AL,DL
		AND AL,00001010b
		CMP AL,0b
		JE CONTINUAR3
		JMP CONTINUAR4
CONTINUAR3:
		MOV DH,00001110b
		JE SEGUIR3
CONTINUAR4:
		MOV DH,00001110b
SEGUIR3:
        MOV WORD PTR ES:[BX],DX    ; Borra el caracter


   
salecolor:		


		;INTERRUPCION DE TECLADO
		MOV AH,01H
		INT 16H
		JZ CUATRO
		JMP HAYTECLA

;MUEVE EL caracter
CUATRO: CMP FIL,24
        JE CD4A   
        INC FIL
		;RANDOM
		mov ah, 2ch  ; Se obtiene la fecha del sistema
		int 21h       
		mov ax, dx   ; DH=segundos, DL=milisegundos
		and ax, 0Fh  ; mantiene los ultimos 4 digitos necesarios para el random
		XOR AX,AX
varMenor:
		;FIN RANDOM
        CMP COL,79
        JE CD4B   
        JMP REPETIR
CD4A:   ADD COL,1
		MOV FIL,0
        JMP REPETIR
CD4B:   MOV COL, 0
		JMP REPETIR

;------------------------------------------------------------------------		
;PROCESA LA TECLA DE FUNCION EXTENDIDA
HAYTECLA:	        XOR AH,AH
			INT 16H
			CMP AL,27	;SI ES ESC
			JZ SALIR	
			
REPETIR: JMP DESPLEGAR

SALIR:  RET

MOVIMIENTO ENDP

Codigo ENDS
END Inicio
