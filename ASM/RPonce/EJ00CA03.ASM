;***************************************************************************
; Nombre del programa:   EJ00CA03.ASM
; Fecha de creaci¢n  :   Marzo 19 de 1993
; Autor              :   J.A. Rojas Ponce
; Objetivo           :   El primer programa formal
;***************************************************************************
; COMANDO DE ENSAMBLE    : Masm EJ00CA03;
; COMANDO DE ENLACE      : Link EJ00CA03;
; COMANDO DE EJECUCION   : EJ00CA03 [Enter]
;***************************************************************************

; Define el modelo de memoria
;
     .MODEL    SMALL          ; Modelo de memoria
     .CODE                    ; Area de c¢digo

Empieza:                      ; Etiqueta de comienzo de programa

;--------------------------------------------------------------------------
; El programa NO HACE NADA. Al ser ejecutado simplemente regresa
; el control a MS-DOS.
;--------------------------------------------------------------------------

     Mov  Ax,4c00h            ; Regresa a Ms-Dos por medio de la
     Int  21h                 ;  funci¢n 4c.
     .STACK                   ; Se necesita una PILA.
     END  Empieza             ; Fin del programa
