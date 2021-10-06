; ***************************************************
; Asterisco rebotador en la pantalla
; ***************************************************

Pila Segment Stack 'Stack'
	dw 2048 dup(?)
Pila Ends

Datos Segment
        FIL DB 0
        COL DB 0
        DIR DB 4
        ASTERIX DB '*'   ; Fondo negro y asterisco verde CLARO ->0AH
        PAUSA1 dw 300
        PAUSA2 dw 300 ; En total hace de pausa 10000x2000=20 000 000 de nops
Datos Ends

Codigo Segment
	Assume DS:Datos,CS:Codigo,SS:Pila

Inicio: MOV AX,DATOS
        MOV DS,AX
        MOV AX,PILA
        MOV SS,AX
		
	MOV AX,0B800H
		;Clear Screen 
        MOV ES,AX
		mov ax,0B800h 
		mov es,ax 
		xor di,di 
		xor ax,ax 
		mov cx,2000d 
		cld 
		rep stosw 
		
	CALL MOVIMIENTO
        MOV AX, 4C00h
        INT 21h

MOVIMIENTO PROC NEAR
; Este procedimiento pone el asterisco, hace una pasua y lo mueve un campo
  
DESPLEGAR:
			XOR AX,AX
			MOV AL,160           ; Calculamos BX = FIL*160+Col*2 
	        MUL FIL
	        XOR BH, BH
	        MOV BL, COL
	        SHL BX,1
	        ADD BX,AX
			


		;MOV DX,WORD PTR ES:[BX]     ; Salvamos lo que hay en la pantalla
		
		
		MOV AL,ASTERIX
		CMP FIL,3
		JE CONTINUAR
		JMP CONTINUAR2
CONTINUAR:
		MOV AH,08Fh
		JE SEGUIR
CONTINUAR2:
		MOV AH,00FH
        
SEGUIR:
		MOV WORD PTR ES:[BX],AX     ; Ponemos el asterisco en pantalla
        MOV CX, PAUSA1       ; Hacemos una pausa de 100 x 1000 nops
P1:     PUSH CX
        MOV CX, PAUSA2
P2:     NOP
        LOOP P2
        POP CX
        LOOP P1
		
		MOV DH,0Ah ; Cambia el Background del char que queda impreso a verde con OAh
        MOV WORD PTR ES:[BX],DX    ; Borramos el asterisco


   cmp asterix+1,15
   je ponecolor0
   jmp salecolor   
ponecolor0: mov asterix+1, 0
salecolor:		


		;INTERRUPCION DE TECLADO
		MOV AH,01H
		INT 16H
		JZ CUATRO
		JMP HAYTECLA

;----------------------------MUEVE EL ASTERISCO---------------------------

CUATRO: CMP FIL,24
        JE CD4A   ; Cambio la direccion a 5
        INC FIL
		;RANDOM
		mov ah, 2ch  ; Set function code
		int 21h      ; get time from MS-DOS
		mov ax, dx   ; DH=seconds, DL=hundredths of second
		and ax, 0Fh  ; keep only the 4 last bits of the hundredth of seconds
		MOV ASTERIX,DL
		XOR AX,AX
		CMP ASTERIX,126
		jl varMenor ;If ASTERIX < 126 
		;ELSE
		
		
varMenor:
		;FIN RANDOM
        CMP COL,79
        JE CD4B   ; Cambio la direccion a 7
        JMP REPETIR
CD4A:   ADD COL,1
		MOV FIL,0
		MOV ASTERIX,0FH
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
