;***************************************************************************
; Nombre del programa:   EJER4.ASM
; Objetivo           :   Desplegar una cadena
;***************************************************************************
; COMANDO DE ENSAMBLE    : MASM EJER4;
; COMANDO DE ENLACE      : LINK EJER4;
; COMANDO DE EJECUCION   : EJER4 [Enter]
;***************************************************************************
;
; Define el modelo de memoria
;
CODE SEGMENT   PUBLIC    'CODE'
     ORG  100H
     ASSUME    CS:CODE, ES:CODE, DS:CODE, SS:CODE

Empieza:                      ; Etiqueta de comienzo de programa

     Jmp  C¢digo

Mensaje   Db   'Hola, que tal !.$'

C¢digo:
     mov  Dx, Offset Mensaje  ; Direcci¢n de Mensaje
     mov  Ah, 9               ; en Dx para poder desplegarlo
     Int  21h                 ; a trav‚s de la Int 21 de MS-DOS.
     mov  ax,4c00h            ; Regresa a MS-DOS por medio de la
     int  21h                 ; funcion 4c.
CODE ENDS
     END  Empieza             ; Fin del programa