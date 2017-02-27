;program that blanks the test mode screen and makes it red.
;It them displays the message This is a test line. before 
;returning to DOS.
;
	.MODEL SMALL
	.DATA
MES	DB	'This is a test line.$'
	.CODE
;        .STARTUP
	MOV	AX,0B800H	;address text segment
	MOV	ES,AX
	CLD			;select increment
	MOV	DI,0		;address text offset
	MOV	AH,40H		;attribute black on red
	MOV	AL,20H		;character is space
	MOV	CX,25*80	;set count
	REP	STOSW		;clear screen and change attributes
        
	MOV	AH,2		;home cursor
	MOV	BH,0		;page 0
	MOV	DX,0		;row 0, char 0
	INT	10H  
        
	MOV	DX,OFFSET MES	;display "This is a test line."
	MOV	AH,9
	INT	21H
;        .EXIT
	END

