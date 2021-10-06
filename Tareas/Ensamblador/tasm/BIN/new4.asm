prnstr macro msg
    mov ah, 09h
    lea dx, msg
    int 21h
    endm

data segment
    ans db "asdf1234h$"
    buf1 db "c:\tempa\abc.txt", 00h
    buf2 db 0ah, "File not found...$"
    buf3 db 0ah, "File opened successfully...$"
    buf5 db 0ah, "Error closing file..$"
    buf6 db 0dh, 0ah, "File closed successfully...$"
data ends

code segment
    assume cs:code, ds:data
start :
    mov ax, data
    mov ds, ax
    mov es, ax

    lea dx, buf1
    mov ah, 3dh
    mov al, 02h     ; open in write mode
    int 21h

    jnc stop
    prnstr buf2
    jmp last
stop :

    mov bx, ax
    prnstr buf3

    mov ah,40h
    mov cx,000ah
    lea dx,ans
    int 21h
        


    mov ah, 3eh
    int 21h

        
    jnc success
    prnstr buf5
    jmp last
success :
        prnstr buf6
last :
        mov ax, 4c00h
        int 21h
code ends
    end start