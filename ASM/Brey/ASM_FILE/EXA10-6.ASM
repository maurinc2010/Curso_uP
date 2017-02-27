	.MODEL SMALL
	.DATA
MES	DB	13,10		;define string
BUF	DB	256 DUP (?)	;memory for string
	.CODE
	.STARTUP
	MOV	AX,DS		;make ES overlap DS
	MOV	ES,AX
        
	CLD			;select increment
	MOV	DI,OFFSET BUF	;address BUF
        
	.WHILE	1		;create an infinite loop
               
		MOV	AH,1	;read key
		INT	21H
		STOSB		;store key code in BUF
        
	.BREAK	.IF AL == 0DH	;breaks the loop for a 0DH
	.ENDW
        
	MOV	BYTE PTR [DI-1],'$'	;make it a $ string
	MOV	DX,OFFSET MES	;display string
	MOV	AH,9
	INT	21H
	.EXIT
	END
