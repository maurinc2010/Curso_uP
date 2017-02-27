	.MODEL SMALL		;select SMALL model
	.DATA			;indicate start of DATA segment
TABLE	DW	ONE		;lookup table
	DW	TWO
	DW	THREE
	.CODE			;indicate start of CODE segment
	.STARTUP		;indicate start of program
TOP:
	MOV	AH,1		;read key to AL
	INT	21H
        
	SUB	AL,31H		;test for below '1'
	JB	TOP		;if below '1'
	CMP	AL,2   
	JA	TOP		;if above '3'
	MOV	AH,0		;calculate table address
	ADD	AX,AX
	ADD	SI,AX
	JMP	TABLE [SI]	;jump to ONE, TWO, or THREE
ONE:
	MOV	DL,'1'		;load DL with '1'
	JMP	BOT
TWO:
	MOV	DL,'2'		;load DL with '2'
	JMP	BOT
THREE:
	MOV	DL,'3'		;load DL with '3'
BOT:
	MOV	AH,2		;display ONE, TWO, or THREE
	INT	21H
	.EXIT			;exit to DOS
	END			;end of file
