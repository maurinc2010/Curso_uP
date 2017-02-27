;a program that reads only the number 1, 2, or 3 from the keyboard.
;if a 1, 2, or 3 are typed, the program displays a 1, 2, or 3.
;
	.MODEL SMALL		;select SMALL model
	.DATA			;indicate start of DATA segment
TABLE	DW	ONE		;define lookup table
	DW	TWO
	DW	THREE
	.CODE			;indicate start of CODE segment
	.STARTUP		;indicate start of program
TOP:
	MOV	AH,1		;read key into AL
	INT	21H
        
	SUB	AL,31H		;convert '1' to 0, '2' to 1, and '3' to 2	
	JB	TOP		;if below '1'
	CMP	AL,2  
	JA	TOP		;if above '3'
        
	MOV	AH,0		;double 0 to 0, 1 to 2, and 2 to 4
	ADD	AX,AX
	MOV	SI,OFFSET TABLE	;address lookup table
	ADD	SI,AX		;add 0, 2, or 4 to lookup table address
	MOV	AX,[SI]		;get ONE, TWO, or THREE from table
	JMP	AX		;jump to ONE, TWO, or THREE
ONE:
	MOV	DL,'1'		;load '1' for display
	JMP	BOT		;go display '1'
TWO:
	MOV	DL,'2'		;load '2' for display
	JMP	BOT		;go display '2'
THREE:
	MOV	DL,'3'		;load '3' for display
BOT:
	MOV	AH,2		;display '1', '2', or '3'
	INT	21H
	.EXIT			;exit to DOS
	END			;end of file
