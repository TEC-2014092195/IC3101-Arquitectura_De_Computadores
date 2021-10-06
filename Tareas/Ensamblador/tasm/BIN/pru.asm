Pila Segment PARA Stack 'stack'
	db 20 Dup(?)
Pila EndS

Datos Segment PARA 'data'
	num1 db 0000000000 ;99999
	num2 db 0000000000 ;99999
Datos EndS


Codigo Segment PARA 'code'

Start:
Assume DS:Datos,CS:Codigo,SS:Pila
 
; CARGA LOS REGISTROS CON LAS DIRECCIONES PERTINENTES PARA INVERTID LOS NUMEROS
	Xor Bx, Bx ;para usarlo como apuntador del PSP
	Mov SI, 82h ; para usarlo como apuntador del PSP
	MOV BL, BYTE PTR [SI]-2; Esto es por que no es permitido pasarla direccion al DI directamente
	Xor Bh, Bh ;para limpiar la parte alta del registro
	
	CMP Bx, 0 ; estas 2 instrucciones me permiten salir si no se introdujeron parametros en la linea de comandos
		;(DEBE DE SER MOSTRAR EL AYUDA NO SALIR), Ademas falta que tire la ayuda si el numero de parametros
		;es superior a lo permitido osea mas de 12
	JE CS:Salir  ; si no se insertan parametros en la linea de comandos
	CMP Bx, 0Ch ; me permite saber si el numero de caracteres es mas de los permitidos en el psp
	JE CS:Salir ; si es igual me lo envia a Salir por que el numero de parametros es mayor de los permitidos (_99999_99999)
				; debe de ser en lugar de Salir tirar el ayuda
	
	Mov DI, Bx ; para guardar la posicion del final del PSP y liberar el retgistro BX para otras operaciones
	Mov Dx, 24h ;valor ASCII del dolar en hexadecimal
	Mov [DI+81h],Dx ; pone en la ultima posicion del psp el valor del ASCII $
	
	;Mov Dx, 82h ; pone la direccion apartir de la cual la funcion 09 empezara a imprimir
	;Mov Ah, 09 ; imprime de la posicion 82h hasta la posicio donde encuentre el valor ASCII del $
	;Int 21h
	
;TERMINA  DE IMPRIMIR LOS NUMEROS NORMALES Y DE CARGAR
;-------------------------------------------------------------------------------------------------------------------------------

;_______________________________________________________________________________
;Ciclo que me invierte los parametros introducidos en el psp
	; Este requiere que se ternga el numero de caracteres introducidos por la linea de comandos en el Registro DI
	;Ademas de que se debe de tener guardado en el SI la posicion 82h
	; Descripcion:
		; Toma a SI y DI como punteros de inico de caracteres y fin de carateres en el psp
		;Cambia sus valores hasta que el DI sea menor o igual a SI
	Add DI, 80h ;para almacenar la ultima posicion del psp
	
	Ciclo_Invertir:
		CMP DI, SI
		JLE invertidos
		Mov Cl,Byte PTR[SI]
		Mov Dl, Byte PTR[DI]
		Mov [DI], Cl
		Mov [SI], Dl
		Inc SI
		Dec DI
		JMP Ciclo_Invertir
	Invertidos:
	Mov Dx, 82h ; pone la direccion apartir de la cual la funcion 09 empezara a imprimir
	Mov Ah, 09 ; imprime de la posicion 82h hasta la posicio donde encuentre el valor ASCII del $
	Int 21h
	
;Ciclo que me invierte los parametros introducidos en el psp
;_______________________________________________________________________________

;_______________________________________________________________________________


Salir:	
	Mov Ax,4C00h
	Int 21h
	
Codigo Ends
END Start ; termina en este punto e inicia en la etiqueta Start

; llamare a un macro  que me convierta los valores num1  y num2 a hexadecimal


;Mov CS, Ax ;para inicializar el puntero del segmento de codigo
	;Mov Dh, 00;Byte PTR[SI]