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
		Text db 'texto$'
Datos Ends

Codigo Segment
	Assume DS:Datos,CS:Codigo,SS:Pila
Inicio:
	; INT 10h / AH = 0 - configurar modo de video.
  ; AL = modo de video deseado.
  ;     00h - modo texto. 40x25. 16 colores. 8 paginas.
  ;     03h - modo texto. 80x25. 16 colores. 8 paginas.
  ;     13h - modo grafico. 40x25. 256 colores. 
  ;           320x200 pixeles. 1 pagina. 
  mov ax,0013h
  int 10h
  mov ax, 0A000h
  mov ds, ax  ; DS = A000h (memoria de graficos).

  ; ============== Lineas verticales ======================
  ; Queremos pintar 256 colummas, cada una con un alto de 
  ; 200 pixeles. Podemos ejecutar 51,200 ciclos.
  ; Como la memoria de graficos es lineal, es mejor pintar
  ; una fila a la vez, cada fila tiene 320 columnas, pero
  ; solo pintamos 256. Al llegar a la columna 256 saltamos
  ; a la siguiente fila sumando 320-256 = 64
  ; Cada pixel cambia de color para dar el efecto de lineas
  ; verticales
  mov cx,0C800h ; # de pixeles
  xor dx,dx     ; contador de columnas y color
  xor di,di

  
  
  ; ciclo_1:
  ; mov [di], dx ; poner color en A000:DI
  ; inc di
  ; inc dx
  ; cmp dx,256
  ; jne sig_pix1

  ; add di,0040h ; saltar al inicio de siguiente fila
  ; xor dx,dx    ; reiniciar columnas y color
; sig_pix1:
  ; loop ciclo_1
  
	;INT 10 - AH = 09h VIDEO - WRITE ATTRIBUTES/CHARACTERS AT CURSOR POS
	MOV AH,09H 
	MOV AL ,'*' 
	MOV BH ,00h ;Screen Page 
	 MOV BL ,001010b ;Color (graphics mode) 
	;MOV DX, 0FH ;row number (y coordinate) 
	MOV CX ,01h 
	int 10h
	
	;INT 10 - AH = 02h VIDEO - SET CURSOR POSITION http://mprolab.teipir.gr/vivlio80X86/dosints.pdf
	MOV AH,02h
	MOV DH,0h
	MOV DL,0h
	int 10h
	
	;INT 10 - AH = 0Eh VIDEO - WRITE CHARACTER AND ADVANCE CURSOR (TTY WRITE)  http://mprolab.teipir.gr/vivlio80X86/dosints.pdf
	;AL = character
	MOV AH,0Eh
	MOV AL,2Ah
	MOV BH,00h
	MOV BL,18h
	MOV CX,0F0h
	int 10h
	
	MOV AH,0Eh
	MOV AL,2Ah
	MOV BH,00h
	MOV BL,19h
	MOV CX,0F0h
	int 10h
	; Video Palette INT 10h AX = 1010h
	;------------------------------------------
	;Modify the palette of one color.
	;BX = color number
	;ch = green 
	;cl = blue 
	;dh = red   
	;------------------------------------------
	MOV AX,1010h
	MOV BL,18h
	MOV ch,0Fh
	MOV CL,0H 
	MOV DH,0h
	INT 10h 
	
	MOV AX,1010h
	MOV BL,19h
	MOV ch,0FFh
	MOV CL,0Fh
	MOV DH,0Fh
	INT 10h 
	


  ; esperar por tecla
  mov ah,10h
  int 16h

  
  ; regresar a modo texto
  mov ax,0003h
  int 10h
  
  ; finalizar el programa
  mov ax,4c00h
  int 21h
  ret

Codigo ENDS
END Inicio
