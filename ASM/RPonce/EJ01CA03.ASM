;***************************************************************************
; Nombre del programa:   EJ01CA03.ASM
; Fecha de creaci¢n  :   Abril 19 de 1993
; Autor              :   J.A. Rojas Ponce
; Objetivo           :   Programa sin DIRECTIVAS SIMPLIFICADAS
;***************************************************************************
; COMANDO DE ENSAMBLE    : MASM EJ01CA03;
; COMANDO DE ENLACE      : LINK EJ01CA03;
; COMANDO DE EJECUCION   : EJ01CA03 [Enter]
;***************************************************************************

;--------------------------------------------------------------------------
; La siguiente l¡nea especifica el segmento que contendr 
; el bloque c¢digo.
;--------------------------------------------------------------------------

CODE SEGMENT   PUBLIC    'CODE'  ; Segmento de c¢digo

;--------------------------------------------------------------------------
; La siguiente l¡nea le indica al ensamblador el nombre del
; segmento que cada registro de segmentos debe direccionar.
;--------------------------------------------------------------------------

     ASSUME    CS:CODE, DS:CODE, ES:CODE, SS:STACK

; Empieza el c¢digo.

Empieza:

     Mov  Ax, 4C00h
     Int  21h

;--------------------------------------------------------------------------
; La siguiente l¡nea le indica al ensamblador que termina
; el segmento de c¢digo 'CODE'.
;--------------------------------------------------------------------------

CODE ENDS

;--------------------------------------------------------------------------
; El segmento STACK es el  rea que usar  la pila .
;--------------------------------------------------------------------------

STACK     SEGMENT   PARA STACK     'STACK'
     Dw   64 DUP (?)
STACK     ENDS

;--------------------------------------------------------------------------
; Se cierra el bloque de c¢digo. Es decir, termina el programa.
;--------------------------------------------------------------------------

END Empieza
