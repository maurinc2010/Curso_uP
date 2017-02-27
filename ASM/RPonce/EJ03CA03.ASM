;***************************************************************************
; Nombre del programa:   EJ03CA03.ASM
; Fecha de creaci¢n  :   Abril 19 de 1993
; Autor              :   J.A. Rojas Ponce
; Objetivo           :   Desplegar una cadena
;***************************************************************************
; COMANDO DE ENSAMBLE    : MASM EJ03CA03;
; COMANDO DE ENLACE      : LINK EJ03CA03;
; COMANDO DE EJECUCION   : EJ03CA03 [Enter]
;***************************************************************************
;
; Define el modelo de memoria
;
CODE SEGMENT   PUBLIC    'CODE'
     ORG  100H
     ASSUME    CS:CODE, ES:CODE, DS:CODE, SS:CODE

Empieza:                 ; Etiqueta de comienzo de programa

     Jmp  C¢digo

Mensaje   Db   'Hola, que tal !.$'

C¢digo:
     mov  Dx, Offset Mensaje  ; Direcci¢n de Mensaje
     mov  Ah, 9               ; en Dx para poder desplegarlo
     Int  21h                 ; a trav‚s de la Int 21 de MS-DOS.
     mov  ax,4c00h            ; Regresa a MS-DOS por medio de la
     int  21h                 ; funci¢n 4c.
CODE ENDS
     END  Empieza             ; Fin del programa
