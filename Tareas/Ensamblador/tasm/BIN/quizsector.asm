Pila Segment Stack 'Stack'
	dw 2048 dup(?)
Pila Ends

Datos Segment
               
Datos Ends
	
Codigo Segment
	Assume DS:Datos,CS:Codigo,SS:Pila

inicio:


  

load_sector_2:
    mov  al, 0x01           ; load 1 sector
    mov  bx, 0x7E00         ; destination (might as well load it right after your bootloader)
    mov  cx, 0x0002         ; cylinder 0, sector 2
    mov  dl, [BootDrv]      ; boot drive
    xor  dh, dh             ; head 0
    call read_sectors_16
    jnc  .success           ; if carry flag is set, either the disk system wouldn't reset, or we exceeded our maximum attempts and the disk is probably shagged
    mov  si, read_failure_str
    call print_string_16
.success:
    ; do whatever (maybe jmp 0x7E00?)


read_failure_str db 'Boot disk read failure!', 13, 10, 0
  
  ; finalizar el programa
  mov ax,4c00h
  int 21h
  
Codigo ENDS
END Inicio
