;***************************************************************************
; Nombre del programa:   EJER1.ASM
; Objetivo           :   El primer programa formal
;***************************************************************************
; COMANDO DE ENSAMBLE    : Masm EJER1;
; COMANDO DE ENLACE      : Link EJER1;
; COMANDO DE EJECUCION   : EJER1 [Enter]
;***************************************************************************

; Define el modelo de memoria
;
     .MODEL    TINY           ; Modelo de memoria
     .CODE                    ; Area de c¢digo

Empieza:                      ; Etiqueta de comienzo de programa

;--------------------------------------------------------------------------
; El programa NO HACE NADA. Al ser ejecutado simplemente regresa
; el control a MS-DOS.
;--------------------------------------------------------------------------

     Mov  Ax,4c00h            ; Regresa a Ms-Dos por medio de la
     Int  21h                 ; funci¢n 4c.
	 
     END  Empieza             ; Fin del programa
	 
	 .STACK                   ; Se necesita una PILA.