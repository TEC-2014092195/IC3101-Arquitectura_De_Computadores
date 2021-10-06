datos segment
	mensaje db "VIRUS",10,13,"$" ;Para imprimir $ pongo el ascii 24h
	tablahex db "ABCDEF"
	var2 db ?
	tua db "Tuanis",10,13,"$" 
	
	FIL DB 20
	COL DB 50
	DIR DB 4
	ASTERIX DB '*',0AH   ; Fondo negro y asterisco verde CLARO
	PAUSA1 dw 1000
	PAUSA2 dw 1000 ; En total hace de pausa 10000x2000=20 000 000 de nops
	
datos EndS

codigo Segment

Enigma Macro Param, Num
	mov cx,Num
Param: 
	push cx
	xor dx,dx
	mov dx,offset tua
	mov ah,09h
	int 21h
	pop cx
	loop Param
EndM     


comienceaqui:
	Assume cs:codigo, ds:datos
	
	xor ax,ax
	mov ax,Datos
	mov Ds,Ax
	
	xor dx, dx
	
	mov dx,offset mensaje 
	mov ah,09h
	int 21h
	
	;mov ah,01h
	;int 21h
	;mov var2,al
	
	mov dl,var2
	mov ah,09h
	int 21h
	
	Enigma A,11h
	
	
	mov ax,4c00h
	int 21h
	
codigo EndS
End comienceaqui