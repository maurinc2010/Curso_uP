;a program that reads a character string from the keyboard
;and, after enter is typed, displays it again.
;
	.MODEL SMALL		;select small model
	.DATA			;indicate start of DATA segment
MES	DB	13,10		;store carriage return line feed
BUF	DB	256 DUP (?)	;character string buffer
	.CODE			;indicate start of CODE segment
	.STARTUP		;indicate start of program
	MOV	AX,DS		;make ES overlap DS
	MOV	ES,AX
        
	CLD			;select increment
	MOV	DI,OFFSET BUF	;address buffer
        
	.WHILE	AL != 0DH	;loop while AL is not an enter
        
		MOV	AH,1	;read key with echo
		INT	21H
		STOSB		;store key code
        
	.ENDW			;end while loop
        
	MOV	BYTE PTR [DI-1],'$'	;make it $ string
	MOV	DX,OFFSET MES	;address MES
	MOV	AH,9		;display MES
	INT	21H
	.EXIT			;exit to DOS
	END
