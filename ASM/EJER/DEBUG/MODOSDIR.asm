;******************************************************************************
; Nombre del programa   :   MODOSDIR.ASM
; Objetivo              :   Ilustrar el uso de las técnicas de direccionamiento
;			    Diseñado para ser probado paso a paso empleando DEBUG
;			    Ing WJPH. Curso de Microprocesadores
;			    Date:05 ABR 2003
;**********************************************************************

STACK	SEGMENT	PARA	STACK	'STACK'
	DB	64	DUP('STACK ')
STACK	ENDS

DATA 	SEGMENT	PARA	PUBLIC	'DATA'
	DATD	DW	0
	DATW	DW	300
	DATX	DW	200
	DATY	DW	150
	DATZ	DW	125
	DATQ	DW	100
	DATR	DW	80
	DATS	DW	70
	DATJ	DW	60
	DATU	DW	50
DATA	ENDS

CSEG	SEGMENT	PARA PUBLIC 'CODE'
INICIO	PROC	FAR
	ASSUME	CS:CSEG,DS:DATA,SS:STACK
	PUSH	DS
	SUB 	AX,AX
	PUSH	AX
	MOV	AX,SEG	DATA
	MOV	DS,AX
	MOV	AX,DATW
	MOV	BX,OFFSET DATX
	MOV	AX,[BX]
	MOV	AX,[BX+2]
	MOV	SI,2
	MOV	AX,DATZ[SI]
	MOV	BX,OFFSET DATW
	MOV	SI,8
	MOV	AX,[BX][SI+2]
	RET
INICIO	ENDP

CSEG	ENDS
	END	

