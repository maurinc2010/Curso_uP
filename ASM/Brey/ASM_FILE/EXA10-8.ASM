	.MODEL SMALL
	.DATA
MES	DB	13,10		;define MES
BUF	DB	256 DUP (?)	;reserve memory for BUF
	.CODE
	.STARTUP
	MOV	AX,DS		;overlap DS and ES
	MOV	ES,AX
	CLD			;select increment
	MOV	DI,OFFSET BUF	;address BUF
        
	.REPEAT
        
	MOV	AH,1		;read key with echo
	INT	21H
	STOSB			;save key code in BUF
        
	.UNTIL	AL == 0DH
        
	MOV	BYTE PTR [DI-1],'$'	;make $ string
	MOV	AH,9		;display MES and BUF
	MOV	DX,OFFSET MES
	INT	21H
	.EXIT
      	END
