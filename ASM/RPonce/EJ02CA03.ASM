;***************************************************************************
; Nombre del programa:   EJ02CA03.ASM
; Fecha de creaci¢n  :   Abril 19 de 1993
; Autor              :   J.A. Rojas Ponce
; Objetivo           :   Desplegar una cadena
;***************************************************************************
; COMANDO DE ENSAMBLE    : MASM EJ02CA03;
; COMANDO DE ENLACE      : LINK EJ02CA03;
; COMANDO DE EJECUCION   : EJ02CA03 [Enter]
;***************************************************************************
;
; Define el modelo de memoria
;
     .MODEL    SMALL          ; Modelo de memoria
     .CODE                    ; Area de c¢digo

Empieza:                      ; Etiqueta de comienzo de programa

     mov  Ax, @Data           ; Inicializa DS con la
     mov  Ds, Ax              ; direcci¢n de @Data
     mov  Dx, Offset Mensaje  ; Direcci¢n de Mensaje
     mov  Ah, 9               ; en Dx para poder desplegarlo
     Int  21h                 ; a trav‚s de la Int 21 de MS-DOS.
     mov  ax,4c00h            ; Regresa a MS-DOS por medio de la
     int  21h                 ; funci¢n 4c.
    .DATA                     ; Segmento de datos
     Mensaje DB 'Hola, que tal !.$' ; Cadena a desplegar

     .STACK                   ; Se necesita una PILA.
     END  Empieza             ; Fin del programa
