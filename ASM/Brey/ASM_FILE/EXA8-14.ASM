Z;a program that displays a string of characters using the
;procedure STRING.  
;
	.MODEL SMALL		;select SMALL model
	.DATA			;indicate start of DATA segment
MES1	DB	13,10,10,0
MES2	DB	'This is a sample line.',0
	.CODE			;indicate start of CODE segment
;
;procedure that displays the character string address by 
;SI in the data segment.  The character string must end with a 
;null.
;
;This procedure changes AX, DX, and SI.
;
STRING	PROC	NEAR
        
	LODSB			;get character from string
	CMP	AL,0		;test for null
	JE	STRING1		;if null
	MOV	DL,AL		;move ASCII code to DL
	MOV	AH,2		;select function 02H
	INT	21H		;access DOS
	JMP	STRING		;repeat until null
STRING1:
	RET			;return from procedure
        
STRING	ENDP
	.STARTUP		;indicate start of program
	CLD			;select increment
	MOV	SI,OFFSET MES1	;address MES1
	CALL	STRING		;display MES1
	MOV	SI,OFFSET MES2	;address MES2
	CALL	STRING		;display MES2
	.EXIT			;exit to DOS
	END			;end of file

