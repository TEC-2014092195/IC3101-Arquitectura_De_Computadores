.386
.model small, c
;----------------------------------------------------------------
; Stak segment
stack_seg SEGMENT stack
	DB 100 DUP(?)
stack_seg ENDS
;----------------------------------------------------------------
; Data segment
data_seg SEGMENT USE16 'DATA'
 	
	Msg1 db 0ah,0dh,0ah,0dh,"*******************Write Some Text*******************$"
	reader db 1024 dup(?)
	datText db 1024 dup(?)
        filename	db "dat.txt", 0h
data_seg ENDS
;----------------------------------------------------------------
; CODE segment
code_seg SEGMENT USE16 'CODE'
ASSUME cs:code_seg, ds:data_seg
	
start:	
	mov ax, data_seg
	mov ds, ax	
	mov ax,0
	mov cx,0
;----------------------------------------------------------------
main PROC
;Write on scrin TITLE
	lea dx,Msg1
	mov ah,09h
	int 021h
	
;New Line
	mov ah,02h
	mov dl,0ah
	int 021h
	mov ah,02h
	mov dl,0dh
	int 021h
         lea si,reader
         mov cx,0
Here:
        	
	mov ah,08h
	int 021h
        cmp al,0dh
	je exit; if user press ENTER key exit 
	mov [si],al
	inc si
	inc cx
	jmp Here
exit:
        mov di,cx; counter
        mov ah, 03ch				
	mov cx, 0	
	lea dx, filename
	int 21h
	mov ah, 03Dh
	mov al, 01h ; 
	lea dx, filename
	int 21h
	mov bx, ax	; file-handle
	
	mov cx,di
	; WRITE in .txt file
	mov ah, 040h	
	lea dx, reader
	int 21h			
					
	; Close .txt file
	mov ah, 03eh
	int 21h
	
;Open .txt file
	mov ah,3dh
	mov al,02h
	lea dx,filename
	int 021h
         
;MOV CX,??????
         mov ah,3fh
	lea dx,datText 
	int 021h
	lea si,datText
         
        ;Here i ned to now count of chars readed from .txt file and mov that number in CX reg (in this case 11 from "Hello world") for example
 	
print:
         cmp CX,0
         je endX
	 
	 mov ah,02h
	 mov dl,[si]
	 int 021h
	
         inc si
	 dec CX
         
         jmp print
EndX:	
;Close .txt file
	mov ah, 03eh
	int 21h
	
mov ax, 04c00h
int 021h
		
;*************************************************************************************		
main ENDP
code_seg ENDS
END start