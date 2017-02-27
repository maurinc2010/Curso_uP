;a program that uses DISPX to display AX in decimal.
;
	.MODEL TINY		;select TINY model
	.CODE			;start CODE segment
	.STARTUP		;start program
	MOV	AX,4A3H		;load AX with test data
	CALL	DISPX		;display AX in decimal
	.EXIT			;exit to DOS
;
;the DISPX procedure displays AX in decimal
;AX is destroyed 
;
DISPX	PROC	NEAR
        
	PUSH	DX		;save DX, CX, and BX
	PUSH	CX
	PUSH	BX
	MOV	CX,0		;clear digit counter
	MOV	BX,10		;set for decimal
DISPX1:
	MOV	DX,0		;clear DX
	DIV	BX		;divide DX:AX by 10
	PUSH	DX		;save remainder
	INC	CX		;count remainder
	OR	AX,AX		;test for quotient of zero
	JNZ	DISPX1		;if quotient is not zero
DISPX2:
	POP	DX		;get remainder
	MOV	AH,6		;select function 06H
	ADD	DL,30H		;convert to ASCII
	INT	21H		;display digit
	LOOP	DISPX2		;repeat for all digits
	POP	BX		;restore BX, CX, and DX
	POP	CX
	POP	DX
	RET
        
DISPX	ENDP
	END			;end of file
