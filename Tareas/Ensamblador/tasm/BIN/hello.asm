.MODEL MEDIUM
.STACK 200H
.CODE
START:
mov ax, 0003h 
int 10h

mov bx, 0b800h
mov es, bx

mov bx, 0
mov ah, 1

mov cx, 100

startloop:
mov es:[bx], ah
add bx, 2
loop startloop

mov ax, 0100h
int 21h

mov ax, 4c00h
int 21h

END START