
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								PROGRAMA CREADO JOSE MANUEL AGUILAR
;									PROFESOR: CARLOS BENAVIDES
;								INSTITUTO TECNOLÓGICO DE COSTA RICA
;				ESTRUCTURA DE UN PROGRAMA EN ENSAMBLADOR PARA ARQUITECTURA 8086/8088/80306 MIPS   
;					 FORMA DE COMPILACIÓN: USANDO EL TURBO ASSEMBLER DE BORLAND 4
;								   TASM/ZI/L LEERBMP[.ASM] 
;									TLINK /V LEERBMP[.OBJ]              
;							SI SE QUIERE DEPURAR TD LEERBMP[.EXE]      
;          			PROPÓSITO:LEER UN ARCHIVO BMP, MOSTRARLO EN PANTALLA Y GENERAR EN ASCII UN .TXT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;INICIO DEL SEGMENTO DE PILA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SSeg Segment para Stack 'Stack'

     db 64 Dup ('SegStack ')
     
SSeg EndS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;FIN DEL SEGMENTO DE PILA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INICIO DEL SEGMENTO DE DATOS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SData Segment para 'Data'   ;Declaración del segmento   

;Variables para ser utilizadas a la hora de leer el archivo

 tamanoMaximo db 255 ;se establece el tamano maximo
 tamanoReal db ? ;guarda el tamano real del archivo
 nombreArchivo db 255 dup (?) , '$' ; aquí se guardará el nombre del archivo
 buffer db 100 dup (?), '$' ;el buffer para leer el archivo bmp
 handleBmp dw ? ;guarda el file handle del archivo leído
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;Mensajes de error 
 msjError db '----ERROR**Ese archivo no existe**ERROR---','$' 
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
 ;Mensaje para el usuario 
 prompt db 'Nombre del archivo', '$'
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
 ;Variables para saber en qué lugar dibujar el bmp
 columna equ 5 ;constante para saber donde dibujar al inicio de cada fila
 tempColumna dw 5 ;varía conforme se van agregando más colores
 fila dw 190 ;se empieza a dibujar desde abajo
 ancho db ? ;es el ancho de la imagen
 alto db 0 ;el alto de la imagen
 tamanoLinea dw ? ;el tamaño de cada línea para dibujarla correctamente
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
 ;Variables para guardar datos del archivo a ser escrito 
 handleNuevo dw ? ;guarda el file handle del nuevo archivo
 archivo db 'bmpEnAscii.txt',0 ;nombre del archivo a ser generado
 escritura db 5000 dup(?) ;variable que almacena los caracteres a ser escritos
 contadorbx dw 0 ;lleva la cuenta del bx
 contadorsi dw 0 ;lleva la cuenta del si para moverse por la variable escritura
 parsersi dw ? ;se usa para saber el valor que contenía el si antes de ser modificado
 hayAscii dw 0 ;Valor boolean para saber si el usuario desea generar un .txt
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;Guarda la posición del caracter
 indice dw 0
 varSi  dw 0
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;Mensaje de Ayuda
 msjAyuda db "*****************BMP2Asc********************"
	db 10,13
	db "Este programa recibe el nombre de un archivo .bmp y lo muestra en pantalla"
	db 10,13
    db "Si se escribe bmp2asc /h mostrara esta ayuda que esta viendo"
	db 10,13
	db "Si se escribe solo bmp2asc se mostrara el dibujo en pantalla"
	db 10,13
	db "Si se escribe bmp2asc /a le creara un archivo en la carpeta tasm/bin llamado bmpEnAscii.txt"
	db 10,13
	db "Solo dibuja bien archivos menores a los 4 kb"
	db 10,13
	db "*****************BMP2Asc********************"
	db 10,13,'$'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Mensaje para parámetro inválido
 msjInvalido db "*******Parametro Invalido*********",'$'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Línea vacía
 linea db 10,13,'$';linea para imprimir un enter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 SData EndS 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;FIN DEL SEGMENTO DE DATOS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INICIO MACROS DEL PROGRAMA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Imprime una línea en blanco
espacio Macro 
	mov ah,09h
	mov dx,offset linea
	int 21h 
endM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;PARAMETRO = UN COLOR EN BINARIO
;AL = EL COLOR A DIBUJAR
;CX = COLUMNA
;DX = FILA
;AH = IMPRIMIR CARACTER
pixel Macro color
	mov al, color
	mov cx, tempColumna
	mov dx, fila 
	mov ah, 0ch
	int 10h 
	inc tempColumna ;se mueve una columna a la derecha
	jmp ciclo ;se devuelve al ciclo a seguir leyendo datos
endM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;FIN DE MACROS DEL PROGRAMA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INICIO DEL SEGMENTO DE CODIGO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CSeg Segment para public 'Code'	;Define el segmento de código

;INICIO DEL PROGRAMA
 Begin:
      Assume CS:CSeg, SS:SSeg, DS:SData ;SE 
	
   push   ax		
   mov    ax,SData		;hace el segmento de datos igual al DS
   mov    DS,ax		
	
   xor ax,ax ;se limpia el ax
   xor dx,dx ;se limpia el dx
   
   ;VERIFICACION DE EXISTENCIA DE PARAMETROS
   mov SI, 80h ;el psp
   mov Al, byte ptr ES:[Si] ;apunta el parámetro
   mov dl, Al ;mueve el primer caracter del parametro al dl
   add si,2 ;se mueve al caracter despues del espacio
   cmp dx, 0 ;compara si hay parámetros
   je inicio ;si no hay entonces solo dibuja el bmp
   cmp byte ptr ES:[Si],'/' ;compara si hay un / después del espacio
   je compara ;si lo hay entonces compara si es ayuda o ascii
   jmp parametroNoValido ;si el parámetro es diferente a / entonces no hace nada y muestra un mensaje
  
  ;COMPARA SI EL PARAMETRO ES VALIDO, SI LO ES ENTONCES VERIFICA CUAL ES DE LOS 2 POSIBLES
  Compara:
	inc si ;se mueve al siguiente caracter del parametro
	cmp byte ptr ES:[Si],'a' ;compara el parametro con una a
	je ascii ;si es una a entonces va a generar un ascii
	cmp byte ptr ES:[Si],'h' ;compara el parametro con una h
	je ayuda ;si es una h muestra el mensaje de ayuda
	jmp parametroNoValido ;si no era ninguno de los anteriores muestra un msj
	
	;AFIRMA QUE SE ENCONTRO LA OPCION DEL ASCII
	Ascii:
		mov hayascii,1 ;establece que sí hay un ascii
		jmp inicio
	
	;MUESTRA UN MENSAJE DE AYUDA Y NO EJECUTA EL PROGRAMA
	Ayuda:
		mov ah,09h
		lea dx,msjayuda ;despliega el mensaje de ayuda
		int 21h
		jmp stop ;termina el programa
	
	;MUESTRA UN MENSAJE DE PARAMETRO INVALIDO Y NO EJECUTA EL PROGRAMA	
	ParametroNoValido: 
		mov ah,09h
		lea dx,msjInvalido ;muestra el mensaje de parametro invalido
		int 21h
		jmp stop ;termina el programa
	
	;SE DEJA DE REVISAR Y EMPIEZA A LEER EL ARCHIVO	
	Inicio:
	  xor si,si ;limpia el si que fue usado anteriormente
	  mov ah, 09h
	  mov dx, offset prompt ;despliega el mensaje de bienvenida
	  int 21h
  
  espacio ;macro que muestra una línea en blanco
  
  ;LEE EL INPUT DEL USUARIO  
  xor dx,dx
  mov ah, 0ah ;lee el input del usuario
  lea dx, tamanoMaximo ;lo guarda en en el dx
  int 21h
	
  ;SE OBTIENE EL NOMBRE DEL ARCHIVO		
  mov al, tamanoReal ;mueve el tamano real al al
  xor ah, ah
  mov si, ax ;mueve lo de ax a si para que apunte al lado corecto del dx
  mov nombreArchivo[si],0 ;mueve lo ingresado por el usuario a la variable

  ;ABRE EL ARCHIVO
  mov ah, 3dh ;abre el archivo
  mov al, 0 ;modo de lectura
  lea dx, nombreArchivo ;se le da al dx el nombre del archivo
  int 21h ;ejecuta la interrupcion para abrir el archivo  
  jc MostrarError ;en caso de error muestra un msj y termina el programa 
  mov handlebmp,ax;mueve el file handle a la variable

  mov bx, ax ; mueve el file handle al bx antes de ser usado   
  mov di,0;el di se usa como contador
  xor si,si ;limpia el si
  
  
  ;SE SALTA EL HEADER HASTA LLEGAR AL ANCHO DEL DIBUJO
  MoverAAnchura:
	  cmp di,19 ;se salta 19 bytes
	  je ObtenerAnchura	;si lo logra salta	  
	  mov ah, 3fh ;abre el archivo cx=numero de bytes,  bx=file handle, ax=número de bytes
	  mov cx, 1 ;se quiere que lea 1 byte
	  lea dx, buffer ;usa los datos del buffer   
	  int 21h ;ejecuta la interrupcion para abrir el archivo
	  inc di ;incrementa el contador
	  jmp moveraanchura
    
	;MUESTRA UN MENSAJE DE ERROR SI LO HAY Y TERMINA EL PROGRAMA
	MostrarError:
		mov ah,09
		lea dx,msjerror
		int 21h
		jmp stop
  
  ;OBTIENE EL ANCHO DEL DIBUJO  
  ObtenerAnchura:	    
	  mov al,ancho ;mueve un 0 al AL
	  mov bh,buffer[si] ;mueve el word del ancho del dibujo
	  add al,bh	 ;suma el word del ancho con 0
	  mov bh,2 ;le mueve un 2 al bh
	  idiv bh ;divide el AL en 2 porque los datos vienen duplicados
	  add al,4 ;le suma cuatro para obtener el verdadero ancho
	  mov ancho,al ;lo guarda en la variable
	  mov al,ancho ;mueve el ancho al AL
	  add al,1 ;al=ancho+5 porque la columna empieza en 5
	  xor ah,ah ;limpia el ah que fue utilizado
	  mov tamanoLinea,ax ;el tamaño de línea es del ancho+5
	  mov dl,ancho ;mueve el ancho al dl para restarle 5 y obtener el verdadero ancho de la imagen
	  sub dl,5
	  mov ax,5000 ;se le suma 5000 para llegar a la última fila del archivo de texto	  
	  xor dh,dh ;se limpia el dh para la resta próxima
	  sub ax,dx ;se resta 5000 con el ancho y se obtiene el lugar del inicio de la última fila del archivo
	  mov indice,ax  ;lo mueve al indice
	  
	  ;SE LLENA EL ARCHIVO PARA LLEGAR AL FINAL DE EL Y EMPEZAR A ESCRIBRLE
	  xor si,si ;limpia el si
	  mov bx,0
	  mov cx,5000 ;escribe 5000 caracteres	  
	  llegarFinArchivo:
	  mov al,' ' ;se llena con espacios en blanco
	  mov escritura[bx+si],al ;mueve el espacio en blanco a la variable	
	  inc si ;se mueve por la variable hacia adelante		
	  loop llegarFinArchivo ;continua
	  mov varSi,si ;guarda la cantidad ingresada
	  mov si,0 ;reestablece el valor original del si	
	  jmp finlectura	  
	  
  ;SE SALTA INFORMACION INNECESARIA PARA LLEGAR A LO IMPORTANTE DEL ARCHIVO (LOS COLORES)
  FinLectura:
	  mov di,5000 ; lee 5000 (sería el tamaño máximo) 	
	  mov bx,handlebmp ;mueve el file handle al bx
	  mov ah, 3fh ;abre el archivo cx=numero de bytes, bx=file handle, ax=número de bytes
	  mov cx, 101 ;se quiere que lea 101 bytes
	  lea dx, buffer ;pasa la información al buffer  
	  int 21h ;ejecuta la interrupción
	  dec indice ;decrementa en 2 para escribir un enter(nueva línea)
	  dec indice
	  mov si,indice ;lo mueve al si para pasarselo al varsi
	  mov varSi,si ;varSi=indice
	  
	  ;CREA UNA NUEVA LINEA EN EL ARCHIVO (LA PRIMERA ABAJO)
	  dec indice;se salta el primer enter
	  dec indice ;se salta el primer enter
	  mov si,indice
	  mov varSi,si ;varSi=indice
	  mov si,varSi ;
		;-Escribe la nueva línea
	  mov al,10
	  mov escritura[bx+si],al
	  dec si ;se mueve en la variable
	  mov al,13 ;primero el 10 y después el 13 porque van al reves
	  mov escritura[bx+si],al
	  mov varSi,si ; si=varsi para saber por donde va escribiendo
	  inc varSi ;se salta los enters
	  inc varSi ;se salta los enters
	  mov si,0
	 ;;;;;;;;
	 
	  ;PONE EN MODO GRAFICO
	  mov al, 13h ;modo gráfico
	  mov ah, 0 
	  int 10h 
	  
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;INICIO DE CICLO PRINCIPAL
  ;CICLO QUE OBTIENE TODOS LOS COLORES DEL DIBUJO
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  CICLO:
  
	;VERIFICACION DE TERMINACION
	cmp di,0 ;cuando sea 0 es que ya ha leido todo el archivo
	jg continue1 ;si no salte
	jmp comprueba ;si terminó entonces salte a otra parte
	
	;REVISA SI EL USUARIO ESCOGIO LA OPCION DEL ASCII
	;---------------------------------------------------------------------------
	Comprueba:
		cmp hayascii,0 ;se comprueba si el ascii fue escogido
		je stop
		
		;CREA EL ARCHIVO
		mov ah,3ch
		lea dx,archivo ;nombre del archivo
		mov al,0 ;crear archivo
		mov cx,0 ;atributos
		int 21h ;crea el archivo 
	
		mov handlenuevo,ax ;mueve el file handle del nuevo archivo a su variable correspondiente
		
		;ESCRIBE EN EL ARCHIVO
		mov ah,40h ;escribe 
		mov bx,handlenuevo ;pasa el file handle correcto
		lea dx,escritura ;mueve la variable escritura que contiene todo el texto al dx
		mov cx,5000 ;número máximo de bytes a escribir
		int 21h	;ejecuta la interrupción
		
		;CIERRA EL ARCHIVO
		mov ah,3eh;cierra el archivo
		int 21h			
		
		jmp stop ; llama al final del programa
	;---------------------------------------------------------------------------

	;FINALIZAR EL PROGRAMA
	;---------------------------------------------------------------------------
	stop:
		mov ax, 4c00h
		int 21h
	;---------------------------------------------------------------------------
	
	;REVISA SI SIGUE UNA NUEVA FILA
	;---------------------------------------------------------------------------
	Continue1:
		dec di ;decrementa la variable contadora
		mov al,ancho
		xor ah,ah	
		cmp tempColumna,ax ;compara el número de columnas a escribir con el ancho
		jne continue2 ;no sigue cambio de fila	
		je nuevaFila ;hay un cambio de fila
	;---------------------------------------------------------------------------
	
	;SE DECREMENTA LA FILA PARA DIBUJAR EN UNA NUEVA Y ESCRIBIRLA EN LA VARIABLE 
	;---------------------------------------------------------------------------
	 nuevaFila:
		;-ESCRITURA
		 ;Crea una nueva línea en el archivo	
		 ;guarda el si en una variable para que su valor se pueda recuperar
		dec indice;se salta el primer enter
		dec indice;se salta el primer enter
		mov si,indice
		mov varSi,si ;varSi=indice (para saber donde está apuntando en la variable)
		mov si,varSi ;lo mueve al si para escribir
			;ESCRIBE UN ENTER (al reves(10,13) porque se escribe al reves)
			mov al,10
			mov escritura[bx+si],al
			dec si	;avanza en el indice de la variable
			mov al,13
			mov escritura[bx+si],al
			;los añade a la variable
		mov varSi,si ;varSi es igual al indice que lleva la variable		
		inc varSi ;se salta los enters (10)
		inc varSi ;se salta los enters (13)
		mov si,0 ;se reestablece el valor original del si
		;-DIBUJO
		dec fila ;se mueve una fila para arriba
		mov ax,columna 
		mov tempColumna,ax	;se reestablece la el valor original de la columna(5)	
		sub di,tamanoLinea ;le resta al contador los caracteres saltados (innecesarios)
		mov bx,handlebmp ;mueve a bx el file handle
		mov ah, 3fh ;abre el archivo cx=numero de bytes, bx=file handle, ax=número de bytes
		mov cx, tamanoLinea ;se quiere que lea lo innecesario
		lea dx, buffer ;mueve lka información al buffer   
		int 21h	
		jmp ciclo ;se regresa al ciclo
		;---------------------------------------------------------------------------
		
	;LEE EL SIGUIENTE BYTE DEL ARCHIVO Y COMPRUEBA SI ES UN COLOR VERDE
	;---------------------------------------------------------------------------
	Continue2: ;si es negro no se dibuja nada
		xor ax,ax
		mov bx,handlebmp ;mueve el file handle al bx
		mov ah, 3fh ;abre el archivo cx=numero de bytes, bx=file handle, ax=número de bytes
		mov cx, 1 ;se quiere que lea 1 byte 
		lea dx, buffer ;mueve la info al buffer
		int 21h	 ;ejecuta la interrupción
		cmp buffer[si], 102	;compara el número del verde
		jne Color1 ;no es
		je verde;si es
	;---------------------------------------------------------------------------
	;								VERDE
	;1: Se apunta al valor indice en el que va la variable
	;2: se escribe un caracter
    ;3: Se escribe el símbolo que representa el color
	;4: Pasa el símbolo a la variable
	;5: Se mueve en el indice
	;6: Aumenta el indice de la variable
	;7: Se reestablece el valor de SI
	;8: Pinta el color en pantalla	
	Verde:		
		mov si,varSi
		mov cx,1		
		mov al,'$'
		mov escritura[bx+si],al		
		dec indice	;devuelvo el indice 10 más abajo para próxima línea	
		inc varSi	
		mov si,0
		pixel 0010b
	;---------------------------------------------------------------------------
	;compara el siguiente color con su correspondiente símbolo, si no es no lo dibuja y sigue 
	Color1: 
		cmp buffer[si], 119
		jne Color2
		je gris
	;---------------------------------------------------------------------------
	;								Gris
	;1: Se apunta al valor indice en el que va la variable
	;2: se escribe un caracter
    ;3: Se escribe el símbolo que representa el color
	;4: Pasa el símbolo a la variable
	;5: Se mueve en el indice
	;6: Aumenta el indice de la variable
	;7: Se reestablece el valor de SI
	;8: Pinta el color en pantalla		
	Gris:
		
		mov si,varSi
		mov cx,1		
		mov al,'w'
		mov escritura[bx+si],al		
		dec indice	;devuelvo el indice 10 más abajo para próxima línea				
		inc varSi		
		mov si,0
		pixel 1000b
	;---------------------------------------------------------------------------
	
	;compara el siguiente color con su correspondiente símbolo, si no es no lo dibuja y sigue 
	Color2:	
		cmp buffer[si], 153
		jne Color3
		je rojo
		
	;---------------------------------------------------------------------------	
	;								ROJO
	;1: Se apunta al valor indice en el que va la variable
	;2: se escribe un caracter
    ;3: Se escribe el símbolo que representa el color
	;4: Pasa el símbolo a la variable
	;5: Se mueve en el indice
	;6: Aumenta el indice de la variable
	;7: Se reestablece el valor de SI
	;8: Pinta el color en pantalla		
	Rojo:
		
		mov si,varSi
		mov cx,1		
		mov al,'%'
		mov escritura[bx+si],al		
		dec indice	;devuelvo el indice 10 más abajo para próxima línea
		inc varSi	
		mov si,0
		pixel 0100b
	;---------------------------------------------------------------------------

	;compara el siguiente color con su correspondiente símbolo, si no es no lo dibuja y sigue 	
	Color3:	
		cmp buffer[si], 204
		jne Color4
		je azul
		
	;---------------------------------------------------------------------------	
	;							AZUL
	;1: Se apunta al valor indice en el que va la variable
	;2: se escribe un caracter
    ;3: Se escribe el símbolo que representa el color
	;4: Pasa el símbolo a la variable
	;5: Se mueve en el indice
	;6: Aumenta el indice de la variable
	;7: Se reestablece el valor de SI
	;8: Pinta el color en pantalla	
	Azul:
		
		mov si,varSi
		mov cx,1		
		mov al,'#'
		mov escritura[bx+si],al		
		dec indice	;devuelvo el indice 10 más abajo para próxima línea	
		inc varSi	
		mov si,0
		pixel 0001b
	;---------------------------------------------------------------------------
	
	;compara el siguiente color con su correspondiente símbolo, si no es no lo dibuja y sigue 
	Color4:	
		cmp buffer[si], 255
		jne Color5
		je blanco
		
	;---------------------------------------------------------------------------
	;									BLANCO
	;1: Se apunta al valor indice en el que va la variable
	;2: se escribe un caracter
    ;3: Se escribe el símbolo que representa el color
	;4: Pasa el símbolo a la variable
	;5: Se mueve en el indice
	;6: Aumenta el indice de la variable
	;7: Se reestablece el valor de SI
	;8: Pinta el color en pantalla		
    Blanco:
		
		mov si,varSi		
		mov cx,1		
		mov al,'.'
		mov escritura[bx+si],al
		dec indice	
		inc varSi
		mov si,0
		pixel 1111b
	;---------------------------------------------------------------------------
	
	;compara el siguiente color con su correspondiente símbolo, si no es no lo dibuja y sigue 
	Color5:		
		cmp buffer[si], 187
		jne Color6
		je amarillo
		
	;---------------------------------------------------------------------------
	;								AMARILLO
	;1: Se apunta al valor indice en el que va la variable
	;2: se escribe un caracter
    ;3: Se escribe el símbolo que representa el color
	;4: Pasa el símbolo a la variable
	;5: Se mueve en el indice
	;6: Aumenta el indice de la variable
	;7: Se reestablece el valor de SI
	;8: Pinta el color en pantalla	
	Amarillo:
		
		mov si,varSi
		mov cx,1		
		mov al,'='
		mov escritura[bx+si],al		
		dec indice	;devuelvo el indice 10 más abajo para próxima línea		
		mov si,0
		inc varSi
		pixel 1110b
	;---------------------------------------------------------------------------
	
	;compara el siguiente color con su correspondiente símbolo, si no es no lo dibuja y sigue 
	Color6:
		cmp buffer[si], 136
		jne Color7
		je celeste
		
	;---------------------------------------------------------------------------	
	;								CELESTE
	;1: Se apunta al valor indice en el que va la variable
	;2: se escribe un caracter
    ;3: Se escribe el símbolo que representa el color
	;4: Pasa el símbolo a la variable
	;5: Se mueve en el indice
	;6: Aumenta el indice de la variable
	;7: Se reestablece el valor de SI
	;8: Pinta el color en pantalla	
	Celeste:
		
		mov si,varSi
		mov cx,1		
		mov al,'!'
		mov escritura[bx+si],al		
		dec indice	;devuelvo el indice 10 más abajo para próxima línea		
		mov si,0
		inc varSi
		pixel 1001b
	;---------------------------------------------------------------------------
	
	;compara el siguiente color con su correspondiente símbolo, si no es no lo dibuja y sigue 
	Color7:
		cmp buffer[si], 221
		jne Color8
		je magenta
	;---------------------------------------------------------------------------	
	;							MAGENTA
	;1: Se apunta al valor indice en el que va la variable
	;2: se escribe un caracter
    ;3: Se escribe el símbolo que representa el color
	;4: Pasa el símbolo a la variable
	;5: Se mueve en el indice
	;6: Aumenta el indice de la variable
	;7: Se reestablece el valor de SI
	;8: Pinta el color en pantalla	
	Magenta:
		
		mov si,varSi
		mov cx,1		
		mov al,'?'
		mov escritura[bx+si],al		
		dec indice	;devuelvo el indice 10 más abajo para próxima línea		
		mov si,0
		inc varSi
		pixel 0101b
	;---------------------------------------------------------------------------
	
	;compara el siguiente color con su correspondiente símbolo, si no es no lo dibuja y sigue 
	Color8:
		cmp buffer[si], 238
		jne Color9
		je cyan
	;---------------------------------------------------------------------------
	;								CYAN
	;1: Se apunta al valor indice en el que va la variable
	;2: se escribe un caracter
    ;3: Se escribe el símbolo que representa el color
	;4: Pasa el símbolo a la variable
	;5: Se mueve en el indice
	;6: Aumenta el indice de la variable
	;7: Se reestablece el valor de SI
	;8: Pinta el color en pantalla	
	Cyan:
		
		mov si,varSi
		mov cx,1		
		mov al,'+'
		mov escritura[bx+si],al		
		dec indice	;devuelvo el indice 10 más abajo para próxima línea		
		mov si,0
		inc varSi
		pixel 0011b
	;---------------------------------------------------------------------------
	
	;compara el siguiente color con su correspondiente símbolo, si no es no lo dibuja y sigue 
	Color9:
		cmp buffer[si], 17
		jne Color10
		je cafe
	;---------------------------------------------------------------------------	
	;							CAFE
	;1: Se apunta al valor indice en el que va la variable
	;2: se escribe un caracter
    ;3: Se escribe el símbolo que representa el color
	;4: Pasa el símbolo a la variable
	;5: Se mueve en el indice
	;6: Aumenta el indice de la variable
	;7: Se reestablece el valor de SI
	;8: Pinta el color en pantalla	
	Cafe:
		
		mov si,varSi
		mov cx,1		
		mov al,'*'
		mov escritura[bx+si],al		
		dec indice	;devuelvo el indice 10 más abajo para próxima línea		
		mov si,0
		inc varSi
		pixel 0110b	
	;---------------------------------------------------------------------------
	
	;compara el siguiente color con su correspondiente símbolo, si no es no lo dibuja y sigue 
	Color10:
		cmp buffer[si], 170
		jne otrociclo
		je verdeclaro
	;---------------------------------------------------------------------------
	;								VERDE CLARO
	;1: Se apunta al valor indice en el que va la variable
	;2: se escribe un caracter
    ;3: Se escribe el símbolo que representa el color
	;4: Pasa el símbolo a la variable
	;5: Se mueve en el indice
	;6: Aumenta el indice de la variable
	;7: Se reestablece el valor de SI
	;8: Pinta el color en pantalla	
	VerdeClaro:
		
		mov si,varSi
		mov cx,1		
		mov al,'/'
		mov escritura[bx+si],al		
		dec indice	;devuelvo el indice 10 más abajo para próxima línea		
		mov si,0
		inc varSi
		pixel 1010b	
	;---------------------------------------------------------------------------
	
	;NO SE ENCONTRÓ EL COLOR O ERA NEGRO
	OtroCiclo:
		inc tempColumna ;aumenta la columna		
		mov si,varSi ;se establece el puntero de la variable
		mov cx,1 ;se escribe un caracter	
		mov al,'O' ;se escribe el caracter correspondiente
		mov escritura[bx+si],al	;mueve el caracter a la variable	
		dec indice	;devuelvo el indice 10 más abajo para próxima línea	
		inc varSi ;se mueve en el indice
		mov si,0 ;reestablece el valor del si		
		jmp ciclo ;sigue en el ciclo
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	;FIN DE CICLO
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
CSeg EndS ;Fin del segmento del código
End begin ;Fin del procedimiento principal