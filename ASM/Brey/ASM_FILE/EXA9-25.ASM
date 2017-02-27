;a program that displays the hexadecimal value loaded into AX
;this program uses DISPH to display a 4-digit value
;
	.MODEL TINY		;select TINY model
	.CODE			;start CODE segment
;        .STARTUP                ;start program
	MOV	AX,0ABCH	;load AX with test data
	CALL	DISPH		;display AX in hexadecimal format
;        .EXIT                   ;exit to DOS
;
;The DISPH procedure displays AX as a 4-digit hexadecimal number
;
DISPH	PROC	NEAR
        
	PUSH	BX		;save BC and CX
	PUSH	CX
	MOV	CL,4		;load rotate count
	MOV	CH,4		;load digit count
DISPH1:
	ROL	AX,CL		;position digit
	PUSH	AX
	AND	AL,0FH		;convert it to ASCII
	ADD	AL,30H
	CMP	AL,'9'
	JBE	DISPH2
	ADD	AL,7
DISPH2:
	MOV	AH,2		;display hexadecimal digit
	MOV	DL,AL
	INT	21H
	POP	AX
	DEC	CH
	JNZ	DISPH1		;repeat for 4 digits
	POP	CX		;restore registers
	POP	BX
	RET
        
DISPH	ENDP
	END			;end of file

