;a program that uses the DISP procedure to display 74 decimal
;on the video display.
;
	.MODEL TINY		;select TINY mode
	.CODE			;start code segment
	.STARTUP		;start program
	MOV	AL,4AH		;load test data to AL
	CALL	DISP		;display test data in decimal
	.EXIT			;exit to DOS
;
;DISP procedure displays AL (0 to 99) as a decimal number
;AX is destroyed by this procedure
;
DISP	PROC	NEAR
        
	PUSH	DX		;save DX
	MOV	AH,0		;clear AH
	AAM			;convert to BCD
	ADD	AH,20H    
	CMP	AH,20H		;test for leading zero
	JE	DISP1		;if leading zero
	ADD	AH,10H		;convert to ASCII
DISP1:
	MOV	DL,AH		;display first digit
	MOV	AH,6
	PUSH	AX   
	INT	21H
	POP	AX
	MOV	DL,AL
	ADD	DL,30H		;convert second digit to ASCII
	INT	21H		;display second digit
	POP	DX		;restore DX
	RET
        
DISP	ENDP
	END			;end of file
