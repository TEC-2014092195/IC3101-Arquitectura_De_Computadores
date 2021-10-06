      cr        EQU   13               ; constante de retorno de carro
      lf        EQU   10               ; constante de salto de línea

      programa  SEGMENT                ; segmento común a CS, DS, ES, SS.

                ASSUME CS:programa, DS:programa

                ORG   100h             ; programa de tipo COM

      inicio:   LEA   DX,texto         ; dirección de texto a imprimir
                MOV   AH,9             ; función de impresión
                INT   21h              ; llamar al DOS
                INT   20h              ; volver al sistema operativo

      texto     DB    cr,lf,"carlos benavides ejemplo academico",cr,lf,"$"

      programa  ENDS                   ; fin del segmento

                END   inicio           ; fin del programa y punto de inicio
