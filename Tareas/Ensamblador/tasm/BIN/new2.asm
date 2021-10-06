include inout.asm
.model small,c
.486
.stack
.data
org 100h ; .com memory layout 
buf db ?
file db "c:\rtasm\bin\file.txt";the file name in bin
.code

mov dx, offset file ; address of file to dx 
mov al,0 ; open file (read-only) 
mov ah,3dh 
int 21h ; call the interupt 
mov bx,ax ; put handler to file in bx 


mov ah,40h
mov bx,ax
mov cx,2h                 ;; how many bytes you want to read
mov dx,offset buf  ;; where you want to store that data (see note on Offset above)
int 21h

call putchar,offset buf; print char on the screen


mov ah,3eh
mov bx,ax
int 21h 
.exit
END 