      cr        EQU   13               ; constante de retorno de carro
      lf        EQU   10               ; constante de salto de l�nea

      programa  SEGMENT                ; segmento com�n a CS, DS, ES, SS.

                ASSUME CS:programa, DS:programa

                ORG   100h             ; programa de tipo COM

      inicio:   LEA   DX,texto         ; direcci�n de texto a imprimir
                MOV   AH,9             ; funci�n de impresi�n
                INT   21h              ; llamar al DOS
                INT   20h              ; volver al sistema operativo

      texto     DB    cr,lf,"carlos benavides ejemplo academico",cr,lf,"$"

      programa  ENDS                   ; fin del segmento

                END   inicio           ; fin del programa y punto de inicio
