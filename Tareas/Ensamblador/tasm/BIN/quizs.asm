Pila Segment Stack 'Stack'
	dw 2048 dup(?)
Pila Ends

Datos Segment
               buff dw      1024
Datos Ends
	
Codigo Segment
	Assume DS:Datos,CS:Codigo,SS:Pila

inicio:
	
	xor ax, ax
	mov es, ax    ; ES <- 0
	mov ch,00h    ;CH = track/cylinder number  (0-1023 dec., see below)
	mov cl,01h        ;CL = sector number  (1-17 dec.)
	mov  dh, 0        ; head number
    mov  dl, 00h     ; drive number. Remember Drive 0 is floppy drive.
	mov bx, buff     ; segment offset of the buffer
	mov ax, 0201h ; AH = 02 (disk read), AL = 01 (number of sectors to read)
	
	int 13h
  
	; xor ax, ax
	; mov es, ax    ; ES <- 0
	; mov cx, 1     ; cylinder 0, sector 1
	; mov dx, 0080h ; DH = 0 (head), drive = 80h (0th hard disk)
	; mov bx, 5000h ; segment offset of the buffer
	; mov ax, 0301h ; AH = 03 (disk write), AL = 01 (number of sectors to write)
	; int 13h
  
  
  ; finalizar el programa
  mov ax,4c00h
  int 21h
  
Codigo ENDS
END Inicio
