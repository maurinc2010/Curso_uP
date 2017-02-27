;------------------------------------------------------------------------------
;PROGRAMA PARA DESPLEGAR NÚMEROS FLOTANTE DE PRECISIÓN SENCILLA EN PANTALLA
;TOMADO DEL LIBRO "LOS MICROPROCESADORES INTEL", BARRY BREY, 3Ed.
;EDITADO POR ING. WILSON JAVIER PÉREZ HOLGUÍN
;UPTC FACULTAD SECCIONAL SOGAMOSO
;ESCUELA DE INGENIERÍA ELECTRÓNICA
;NOVIEMBRE DE 2016
;ESTADO: FUNCIONA OK
;------------------------------------------------------------------------------
.286
.287

;Declaración del segmento de datos
DATAS	SEGMENT
		NUMB	DD -22924.6502434
		TEMP	DW ?
		WHOLE	DW ?
		FRACT	DD ?
DATAS	ENDS

;Declaración del segmento de pila 
STACKS	SEGMENT	PARA STACK 'STACK'
		DB	64 DUP (?)
STACKS	ENDS

;Declaración del segmento de código
CODES	SEGMENT
		ASSUME CS:CODES, DS:DATAS, SS:STACKS
		
;--- Programa principal que muestra NUMB en pantalla ---
MAIN	PROC 	FAR
		MOV		AX,DATAS
		MOV		DS,AX
		CALL	DISP
		MOV		AH,4CH
		INT		21H
MAIN	ENDP
;-------------- Fin de programa principal ---------------

;***** Procedimientos *****
DISPS	PROC	NEAR
		MOV		AH,06
		MOV		DL,AL
		INT		21H
		RET
DISPS	ENDP

DISP	PROC	NEAR
		FSTCW	TEMP
		OR		TEMP,0C00H
		FLDCW	TEMP
		FLD		NUMB
		FTST
		FSTSW	AX
		AND		AX,4500H
		CMP		AX,0100H
		JNE		DISP1
		MOV		AL,'-'
		CALL	DISPS
DISP1:	
		FABS
		FRNDINT
		FIST	WHOLE
		FLD		NUMB
		FABS
		FSUB
		FABS
		FSTP	FRACT
		FWAIT
		
;Mostrar la parte entera del número
		MOV		AX,WHOLE
		MOV		CX,0
		MOV		BX,10
DISP2:
		INC		CX
		XOR		DX,DX
		DIV		BX
		ADD		DX,'0'
		PUSH	DX
		OR		AX,AX
		JNE		DISP2	
DISP3:
		POP		AX
		CALL	DISPS
		LOOP	DISP3
		MOV		AL,'.'
		CALL	DISPS
		
;Mostrar la parte fraccionaria del número
		MOV		AX,WORD PTR FRACT
		MOV		DX,WORD PTR FRACT+2
		MOV		CX,8
DISP4:
		SHL		AX,1
		RCL		DX,1
		LOOP	DISP4
		OR		DX,8000H	;Agregar el 1 implícito
		XCHG	AX,DX
		MOV		BX,10
DISP5:
		MUL		BX
		PUSH	AX
		XCHG	DX,AX
		ADD		AL,'0'
		CALL	DISPS
		POP		AX
		OR		AX,AX
		JNZ		DISP5
		RET
		
DISP	ENDP

CODES	ENDS

		END		MAIN