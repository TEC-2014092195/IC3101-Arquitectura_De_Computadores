demores        SEGMENT
               ASSUME CS:demores, DS:demores

               ORG   100h
inicio:
               JMP   main

controla_int08 PROC
               PUSHF
               CALL  CS:ant_int08   ; llamar al gestor normal de INT 8
               STI
               CMP   CS:in10,0
               JNE   fin_int08      ; estamos dentro de INT 10h

               ;
               ; Colocar aqu� el proceso a ejecutar 18,2 veces/seg.
               ; que puede invocar funciones de INT 10h
fin_int08:
               IRET
controla_int08 ENDP

controla_int10 PROC
               INC   CS:in10        ; indicar entrada en INT 10h
               PUSHF
               CALL  CS:ant_int10
               DEC   CS:in10        ; fin de la INT 10h
               IRET
controla_int10 ENDP

in10           DB    0              ; mayor de 0 si hay INT 10h
ant_int08      LABEL DWORD
ant_int08_off  DW    ?
ant_int08_seg  DW    ?
ant_int10      LABEL DWORD
ant_int10_off  DW    ?
ant_int10_seg  DW    ?

               ; Dejar residente hasta aqu�.

main:          PUSH  ES
               MOV   AX,3508h
               INT   21h               ; obtener vector de INT 8
               MOV   ant_int08_seg,ES
               MOV   ant_int08_off,BX
               MOV   AX,3510h
               INT   21h               ; obtener vector de INT 10h
               MOV   ant_int10_seg,ES
               MOV   ant_int10_off,BX
               POP   ES

               LEA   DX,controla_int08
               MOV   AX,2508h
               INT   21h               ; nueva rutina de INT 8

               LEA   DX,controla_int10
               MOV   AX,2510h
               INT   21h               ; nueva rutina de INT 10h

               PUSH  ES
               MOV   ES,DS:[2Ch]       ; direcci�n del entorno
               MOV   AH,49h
               INT   21h               ; liberar espacio de entorno
               POP   ES

               LEA   DX,main           ; fin del c�digo residente
               ADD   DX,15             ; redondeo a p�rrafo
               MOV   CL,4
               SHR   DX,CL             ; bytes -> p�rrafos
               MOV   AX,3100h          ; terminar residente
               INT   21h

demores        ENDS
               END   inicio

