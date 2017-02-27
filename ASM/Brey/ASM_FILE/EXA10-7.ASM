;A program that displays the contents of EAX in decimal.
;This program inserts commas between thousands, millions,
;and billions.
;
	.MODEL TINY
	.386			;select 80386
	.CODE
	.STARTUP
        
	MOV	EAX,123455	;load test data
	CALL	DISPE		;display EAX in decimal
	.EXIT
;
;the DISPE procedure displays EAX in decimal format.
;
DISPE	PROC	NEAR
        
	MOV	EBX,10		;load 10 for decimal
	PUSH	BX		;save end of number indicator (10)
	MOV	CL,0		;load comma counter
        
	.WHILE	1		;first infinite loop
        
	MOV	EDX,0		;clear EDX
	DIV	EBX		;divide EDX:EAX by 10	
	ADD	DL,30H		;convert to ASCII
	PUSH	DX		;save remainder
        
	.BREAK	.IF EAX == 0	;break if quotient is zero
        
	INC	CL		;increment comma counter
        
	.IF	CL == 3		;if comma count is 3
		PUSH	','	;save comma
		MOV	CL,0	;clear comma counter
	.ENDIF
        
	.ENDW			;end first loop
        
	.WHILE	1		;second infinite loop
        
	POP	DX		;get remainder

	.BREAK	.IF DL == 10	;break if remainder is 10
        
	MOV	AH,2		;display decimal digit
	INT	21H
        
	.ENDW

	RET

DISPE	ENDP
        END
