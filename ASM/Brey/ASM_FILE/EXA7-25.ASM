;a program that displays the number loaded into AL,
;with the first instruction (48H), as a decimal number.
;
	.MODEL TINY		;select TINY model
	.CODE			;indicate start of CODE segment
	.STARTUP		;indicate start of program
	MOV	AL,48H		;load AL with test data
	MOV	AH,0		;clear AH
	AAM			;convert to BCD
	ADD	AX,3030H	;convert to ASCII
	MOV	DL,AH		;display most significant digit
	MOV	AH,2
	PUSH	AX		;save least significant digit 
	INT	21H  
	POP	AX		;restore AL
	MOV	DL,AL		;display least significant digit
	INT	21H
	.EXIT			;exit to DOS
	END			;end of file
