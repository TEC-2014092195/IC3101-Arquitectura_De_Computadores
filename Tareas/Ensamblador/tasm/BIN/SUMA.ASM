Pila Segment 
	Dw 64 Dup(0) 
Pila EndS

Datos Segment
	Num1 db 5 dup (0),10,13 ;99999
	Num2 db 5 dup (0),10,13,'$'
	Res  db 6 dup (0),10,13,'$'
	Acerca	db "    Instituto Tecnologico     ",10,13
			db "        de Costa Rica         ",10,13
			db "   Michael Salazar Alvarez    ",10,13
			db " Arquitectura de Computadores ",10,13
			db "  Profesor: Carlos Benavides  ",10,13
			db "          II S 2009           ",10,13,'$'
	Ayuda	db " Los valores que se van a sumar",10,13
			db "  deben de ser valores con un  ",10,13
			db "         de 0 a 99999          ",10,13,'$'
Datos EndS

  ;extrn GuardarPila:Far
  ;Include Macro.cbc	

Codigo Segment 
Include Macro.cbc


Start:
Assume DS:Datos, CS:Codigo, SS:Pila

 
; CARGA LOS REGISTROS CON LAS DIRECCIONES PERTINENTES PARA INVERTID LOS NUMEROS
	Xor Bx, Bx ;para usarlo como apuntador del PSP
	
	Mov SI, 82h; para usarlo como apuntador del PSP
	
	MOV BL, BYTE PTR [SI]-2; Esto es por que no es permitido pasarla direccion al DI directamente
	Xor Bh, Bh ;para limpiar la parte alta del registro
	
	CMP Bx, 0 ; estas 2 instrucciones me permiten salir si no se introdujeron parametros en la linea de comandos
		;(DEBE DE SER MOSTRAR EL AYUDA NO SALIR), Ademas falta que tire la ayuda si el numero de parametros
		;es superior a lo permitido osea mas de 12
	JE Paso_Salir  ; si no se insertan parametros en la linea de comandos
	CMP Bx, 0Ch ; me permite saber si el numero de caracteres es mas de los permitidos en el psp
	JG Paso_Salir ; si es igual me lo envia a Salir por que el numero de parametros es mayor de los permitidos (_99999_99999)
	; debe de ser en lugar de Salir tirar el ayuda
	
	Mov DI, Bx 
	Mov Dx, 10 
	Mov [DI+81h],Dx 
	Mov Dx, 13 
	Mov [DI+82h],Dx 
	Mov Dx, 24h ;valor ASCII del dolar en hexadecimal
	Mov [DI+83h],Dx ; pone en la ultima posicion del psp el valor del ASCII $
	
	Mov Dx, 82h ; pone la direccion apartir de la cual la funcion 09 empezara a imprimir
	Mov Ah, 09 ; imprime de la posicion 82h hasta la posicio donde encuentre el valor ASCII del $
	Int 21h
	
	JMP Fin_Paso_salir
	
	
	
;TERMINA  DE IMPRIMIR LOS NUMEROS NORMALES Y DE CARGAR
;-------------------------------------------------------------------------------------------------------------------------------
Paso_Salir:
	JMP Salir
;_______________________________________________________________________________
;Ciclo que me invierte los parametros introducidos en el psp
	; Este requiere que se ternga el numero de caracteres introducidos por la linea de comandos en el Registro DI
	;Ademas de que se debe de tener guardado en el SI la posicion 82h
	; Descripcion:
		; Toma a SI y DI como punteros de inico de caracteres y fin de carateres en el psp
		;Cambia sus valores hasta que el DI sea menor o igual a SI
	
Fin_Paso_salir:
	Add DI, 80h ;para almacenar la ultima posicion del psp
	Mov Bx, DI ;para guardar el final del psp
	
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
	Mov DI, Bx ; para recordar la direccion del final del psp
	Mov Dx, 82h ; pone la direccion apartir de la cual la funcion 09 empezara a imprimir
	Mov Ah, 09 ; imprime de la posicion 82h hasta la posicio donde encuentre el valor ASCII del $
	Int 21h
	

;_______________________________________________________________________________
	Mov Ax, Datos
	Mov DS, Ax ; se establece el segmento de datos
	;pop DI; para guardar en la pila el DI que es el final del psp, por si se requiere emplear mas
	
	Mov Bx, 0 ; para el contador
	Xor Dx, Dx ;para limpiar o setear el registro
	Mov Cx, 4 ; para que el loop carge la cantidad que tiene que cargar
	Mov SI, 4

Ciclo_Save_N2:
	Xor Dx, DX ; esto se hace por que si se ingresa un valor incorrecto, que puede afectar el Xh
	CMP Bx, 5 ; para saber si se han indexado mas de 5 caracteres del psp sin ningun espacio, osea que si el numero es mayor a 99999
	JE Paso_Salir ; esto por que no se introdujeron los numero corectamente, DEBE DE SER PARA LLAMAR AL AYUDA
	Inc Bx ; para saber cuantos valores se han introducido o indexado en Num2 en el segmento de datos
    Mov Dl, byte ptr ES:[DI]
	CMP Dx, 20h ; para saber
	JE Continuar_Save_N1
	Sub Dl, 30h
	Mov DS:[Num2+SI],Dl ; mueve al segmento de datos  el valor en el indice SI
	Dec DI ; Para bajar la posicion en el psp en la que voy a buscar el siguiente valor
	Dec SI ; para manejar la posicion donde voy a poner el valor
	Dec cx
	;para hacer el loop que no me funciono
	CMP cx, 0
	JE Continuar_Save_N1
	JMP Ciclo_Save_N2
	;loop ciclo_Save_N2 ; para repetir el ciclo si no se a terminado de guardar los parametros;NO FUNCIONO

Continuar_Save_N1:	
	Dec DI ; para saltar el espacio en blanco
	Mov Cx, 4 ; para que el loop establesca las posiciones que tiene que cargar
	Mov SI, 4 ; Para saver el indice en el que se va a poner el valor que estoy ingresando
	Mov Bx, 0 ; para el contador
	Xor Dx, Dx ;para limpiar o setear el registro


Ciclo_Save_N1:
	Xor Dx, DX ; esto se hace por que si se ingresa un valor incorrecto, que puede afectar el Xh
	CMP Bx, 5 ; para saber si se han indexado mas de 5 caracteres del psp sin ningun espacio, osea que si el numero es mayor a 99999
	JE Paso_Salir ; esto por que no se introdujeron los numero corectamente, DEBE DE SER PARA LLAMAR AL AYUDA
	Inc Bx ; para saber cuantos valores se han introducido o indexado en Num2 en el segmento de datos
    Mov Dl, byte ptr Es:[DI]
	CMP Dx, 20h ; para saber si el indice sigieunte es un espacion en blanco
	JE Salir_Ciclo_Save ;para salir de guardar los numeros
	Sub Dl,30h
	Mov DS:[Num1+SI],Dl ; Permite guardar en orden inverso
	Dec DI
	Dec SI
	Dec Cx
	; para hacer el loop que no funciono
	Cmp cx,0
	JE Salir_Ciclo_Save
	JMP Ciclo_Save_N1
	
	;loop ciclo_Save_N1 ; pNO FUNCIONO
	
Salir_Ciclo_Save:

;Ciclo para sumar
	Xor dx,dx ; para limpiar el registro
	Xor Bx,Bx ;para limpiar el registro
	Mov SI,4 ; para saber el indice que voy sumando
	Mov Cx,5 ;para el loop o el ciclo de de sumado
	Xor Ax,AX; para limpiar el registro que voy a usar para carry
	
Mover:	
	Mov Dl,Byte PTR Num1[SI]; muevo el valor de la posicion del numero 1 que voy sumando
	Add Dl,Byte PTR Num2[SI]; Suma el valor de la aposicion del seguno numero que voy sumando 
	Add Dl,Al ; para sumar el carry de la suma anterior
	Xor Al,Al ; para borrar el carry
	CMP Dl, 0Ah; comparo para saber si el valor sumado es mayor de 10, para restarle un A y que me de el valor en base 10 que debo de sumar
	JL No_restar ; si es menor no le resto los A para pasar el resultado a 
	Sub Dl,0Ah ; para hacer la resta
	Inc Al; para establecer el carry
	No_restar:
	Mov res[SI+1], Dl ; guarda el resultado de la suma
	Dec Cx ;para saber que cumpli un ciclo de gardado
	Dec SI
	CMP CX,0 ;para saber si y se termino el ciclo
	JE Salir_Sumar
	JMP Mover ; para repetir el ciclo. No use el loop por que no me estaba funcionando
Salir_Sumar:
	Mov res[0],Al; para guardar un posible ultimo carry, se hace esto en lugar de comparar por que requiere menos procesos
;_______________________________________________________________________________
	Xor Dx,Dx ; para limpiar la parte alta
	Xor Ax,Ax ; para usarlo como contador para saber cunatos espacios estan en blanco en el resultado
	Mov Bx,0 ; para usarlo como indice dentro de res
; se ponen espacios (20h) al inicio del resultado, y se aumenta ax para saber cuantos espacios hay 

Poner_espacios: 
	Mov Dl,res[Bx]
	CMP Dx,0
	JNE Res_Ascii
	Add Dl,20h
	Mov res[Bx],Dl
	Inc Bx ;para aumenta el indice
	Inc Ax ; para amentar el contador
	JMP Poner_espacios
	
;Convierto los valores numericos a caracteres ascci para imprimirlos
Res_Ascii:	
	Mov Dl,res[Bx]
	add Dl,30h
	Mov res[Bx],Dl
	Inc Bx ;no emplear un loop es por que si lo hago a como esta el bx me sirbe como indice
	CMP bx,06
	JE Imprimir
	JMP Res_Ascii

	
Imprimir:
	Mov Dx,offset res
	Add Dx,Ax
	Mov ah,09
	Int 21h
;________________________________________________________________________

Salir:	
	Mov Ax,4C00h
	Int 21h
	
Codigo Ends
  
END Start ; termina en este punto e inicia en la etiqueta Start

