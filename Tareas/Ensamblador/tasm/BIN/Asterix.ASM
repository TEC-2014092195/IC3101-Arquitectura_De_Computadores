; ***************************************************
; Asterisco rebotador en la pantalla
; ***************************************************

Pila Segment Stack 'Stack'
	dw 2048 dup(?)
Pila Ends

Datos Segment
        FIL DB 20
        COL DB 50
        DIR DB 4
        ASTERIX DB '*',0AH   ; Fondo negro y asterisco verde CLARO
        PAUSA1 dw 1000
        PAUSA2 dw 1000 ; En total hace de pausa 10000x2000=20 000 000 de nops
Datos Ends

Codigo Segment
	Assume DS:Datos,CS:Codigo,SS:Pila

Inicio: MOV AX,DATOS
        MOV DS,AX
        MOV AX,PILA
        MOV SS,AX
       
;	MOV AX, 3                          
;	INT 10H 	;Interrupcion de pantalla (BIOS)
		
	MOV AX,0B800H
        MOV ES,AX
	CALL MOVIMIENTO
        MOV AX, 4C00h
        INT 21h

MOVIMIENTO PROC NEAR
; Este procedimiento pone el asterisco, hace una pasua y lo mueve un campo
  
DESPLEGAR:	MOV AL,160           ; Calculamos BX = FIL*160+Col*2 
	        MUL FIL
	        XOR BH, BH
	        MOV BL, COL
	        SHL BX,1
	        ADD BX,AX



        MOV DX,WORD PTR ES:[BX]     ; Salvamos lo que hay en la pantalla
        MOV AX,WORD PTR ASTERIX     ; Movemos al AX el asterisco
        MOV WORD PTR ES:[BX],AX     ; Ponemos el asterisco en pantalla


        MOV CX, PAUSA1       ; Hacemos una pausa de 100 x 1000 nops
P1:     PUSH CX
        MOV CX, PAUSA2
P2:     NOP
        LOOP P2
        POP CX
        LOOP P1

        MOV WORD PTR ES:[BX],DX    ; Borramos el asterisco


   cmp asterix+1,15
   je ponecolor0
   jmp salecolor   
ponecolor0: mov asterix+1, 0
salecolor:		


		;INTERRUPCION DE TECLADO
		MOV AH,01H
		INT 16H
		JZ ALGOR
		JMP HAYTECLA

;----------------------------MUEVE EL ASTERISCO---------------------------
ALGOR:     CMP DIR, 4      ; Con saltos de conejo pues ya da fuera de rango
           JNE PREGUNTE5
           JMP CUATRO
PREGUNTE5: CMP DIR, 5
           JNE PREGUNTE6
           JMP CINCO
PREGUNTE6: CMP DIR, 6
           JNE SIETE
           JMP SEIS

SIETE:  CMP FIL,0
        JE CD7A   ; Cambio la direccion a 6
        DEC FIL
        CMP COL,79
        JE CD7B   ; Cambio la direccion a 4
        INC COL
        JMP REPETIR
CD7A:   MOV DIR, 6
        JMP REPETIR
CD7B:   MOV DIR, 4
        JMP REPETIR

SEIS:   CMP FIL,24
        JE CD6A   ; Cambio la direccion a 7
        INC FIL
        CMP COL,79
        JE CD6B   ; Cambio la direccion a 5
        INC COL
        JMP REPETIR
CD6A:   MOV DIR, 7
        JMP REPETIR
CD6B:   MOV DIR, 5
        JMP REPETIR

CINCO:  CMP FIL,24
        JE CD5A   ; Cambio la direccion a 4
        INC FIL
        CMP COL,0
        JE CD5B   ; Cambio la direccion a 6
        DEC COL
        JMP REPETIR
CD5A:   MOV DIR, 4
        JMP REPETIR
CD5B:   MOV DIR, 6
        JMP REPETIR

CUATRO: CMP FIL,0
        JE CD4A   ; Cambio la direccion a 5
        DEC FIL
        CMP COL,0
        JE CD4B   ; Cambio la direccion a 7
        DEC COL
        JMP REPETIR
CD4A:   MOV DIR, 5
        JMP REPETIR
CD4B:   MOV DIR, 7
		JMP REPETIR

;------------------------------------------------------------------------		
;PROCESA LA TECLA DE FUNCION EXTENDIDA
HAYTECLA:	        XOR AH,AH
			INT 16H
			CMP AL,27	;SI ES ESC
			JZ SALIR
			
			CMP AL,0
			JZ REVISE_DIR
			JMP ALGOR
			
REVISE_DIR:	CMP AH,47H	;SI ES HOME
			JNE S1 
			MOV DIR,4
			JMP DESPLEGAR
		S1:	CMP AH,49H	;SI ES PG UP
			JNZ S2
			MOV DIR,7
			JMP DESPLEGAR
		S2:	CMP AH,4FH	;SI ES END
			JNZ S3
			MOV DIR,5
			JMP DESPLEGAR
		S3:	CMP AH,51H	;SI ES PG DN
			JE S4
			JMP ALGOR
		S4:	MOV DIR,6		
			
REPETIR: JMP DESPLEGAR

SALIR:  RET

MOVIMIENTO ENDP

Codigo ENDS
END Inicio
