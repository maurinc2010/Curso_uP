;A procedure that converts a floating-point number into an ASCII
;character string.

.model small
.386
.387

.stack 4096

.data
	STRV	DB 40 DUP(?)	;storage for string
	NUMB	REAL4 -213.94566	;test number
	WHOLE	DD ?
	FRACT	DD ?
	TEMP	DW ?			;place for CW
	TEN		DW 10			;integer of 10

.code
.startup
;F2A	PROC	NEAR USES EBX,ECX,EDX
 
	MOV		ECX,0			;initialize pointer
	FSTCW	TEMP			;save current control word
	MOV		AX,TEMP			;change rounding to chop
	PUSH	AX
	OR		AX,0C00H
	MOV		TEMP,AX
	FLDCW	TEMP
	FLD		NUMB
	FXAM 					;test NUMB
	FSTSW	AX
	FCOMP
	AND		AX,4500H		;get C0, C2, and C3
	.IF AX == 100H			;if negative
			MOV		STRV[ECX],'-'
			INC		ECX
			FABS			;make positive
	.ENDIF
	FRNDINT					;round to integer
	FIST	WHOLE			;save the integer part of NUMB into the WHOLE variable
	
	FLD		NUMB			;load the NUMB into the coprocessor stack ST(0)
	FABS					;absolute value of ST(0) (NUMB)
	FSUBR					;Fractional part = NUMB - WHOLE
	FSTP	FRACT			;save the fractional part of NUMB into the FRACT variable
	MOV		EAX,WHOLE
	MOV		EBX,10
	PUSH	EBX
	.REPEAT
		MOV		EDX,0
		DIV		EBX
		ADD		DL,30H		;convert to ASCII
		PUSH	EDX
	.UNTIL EAX == 0
	POP		EDX
	MOV		AH,3			;comma counter
	.WHILE	EDX != 10		;whole part to ASCII
		POP		EBX
		DEC		AH
		.IF AH == 0 && EBX != 10
			MOV		STRV[ECX],'-'
			INC		ECX
			MOV		AH,3
		.ENDIF
		MOV		STRV[ECX],DL
		INC		ECX
		MOV		EDX,EBX
	.ENDW
	MOV		STRV[ECX],'.'	;store decimal point
	INC		ECX
	POP		TEMP 			;restore original CW
	FLDCW	TEMP
	FLD		FRACT 			;convert fractional part
	.REPEAT
		FIMUL	TEN
		FIST	TEMP
		MOV		AX,TEMP
		ADD		AL,30H
		MOV		STRV[ECX],AL
		INC		ECX
		FISUB	TEMP
		FXAM
		FSTSW	AX
		SAHF
	.UNTIL ZERO?
	FCOMP 					;clear stack
	MOV		STRV[ECX],0 	;store null
;	RET
;F2A	ENDP

	END