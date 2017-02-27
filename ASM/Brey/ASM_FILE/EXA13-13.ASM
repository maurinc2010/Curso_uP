;a program that reads a mixed number from the keyboard.
;The result is stored at memory location NUMB as a
;double-precision floating-point number.
;
	.MODEL SMALL
	.386
	.387
	.DATA
SIGN	DB	?		;sign indicator
TEMP1	DW	?		;temporary storage
TEN	DD	10.0		;10.0
NUMB	DD	?		;result
	.CODE
GET	MACRO			;;read key macro
	MOV	AH,1	
	INT	21H
	ENDM
	.STARTUP
	FLDZ			;clear ST
	GET			;read a character
	.IF  AL == '+'		;test for +
		MOV	SIGN,0	;clear sign indicator
	GET
	.ENDIF
	.IF  AL == '-'		;test for -
		MOV	SIGN,1	;set sign indicator
	GET
	.ENDIF
	.REPEAT
		FMUL	TEN	;multiply result by 10
		MOV	AH,0
		SUB	AL,30H	;convert from ASCII
		MOV	TEMP1,AX
		FIADD	TEMP1	;add it to result
		GET		;get next character
	.UNTIL  AL < '0' || AL > '9'
	.IF  AL == '.'		;do if -
		FLD1		;get one
		.WHILE  1
			FDIV	TEN
			GET
			.BREAK  .IF  AL < '0' || AL > '9'
			MOV	AH,0
			SUB	AL,30H	;convert from ASCII
			MOV	TEMP1,AX
			FILD	TEMP1
			FMUL	ST,ST(1)
			FADD	ST(2),ST
			FCOMP
		.ENDW
		FCOMP		;clear stack
	.ENDIF
	.IF  SIGN == 1
		FCHS		;make negative
	.ENDIF
	FSTP	NUMB		;save result
	.EXIT
	END
