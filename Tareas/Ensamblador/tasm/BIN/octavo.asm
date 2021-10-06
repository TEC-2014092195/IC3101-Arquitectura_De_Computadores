

.model small
.stack 100h
.data
Mensaje Db 'Hola Mundo $'

.code
Principal PROC
	MOV AX, @data
	MOV DS, AX
	CALL Imprimir
	MOV AH, 4Ch
	INT 21h
Principal ENDP

Imprimir PROC


	MOV AH, 09
	MOV DX, OFFSET Mensaje
	INT 21h
	MOV DL, 13 ; imprime salto de linea
	INT 21h
	MOV DL, 10
	INT 21h
	RET
Imprimir ENDP

END Principal


