;a program that tests the video display for the word BUG
;if BUG appears anywhere on the display the program display Y
;if BUG does not appear, the program displays N
;
	.MODEL SMALL    	;select SMALL model
	.DATA			;indicate start of DATA segment
DATA1	DB	'BUG' 		;define BUG
	.CODE     		;indicate start of CODE segment
	.STARTUP		;indicate start of program
	MOV	AX,0B800H	;address segment B800 with ES
	MOV	ES,AX
	MOV	CX,25*80	;set count 
	CLD			;select increment
	MOV	DI,0		;address first display position
L1:
	MOV	SI,OFFSET DATA1	;address BUG
	PUSH	DI		;save display address
	CMPSB			;test for B
	JNE	L2		;if display is not B
	INC	DI		;address next display position
	CMPSB			;test for U
	JNE	L2		;if display is not U
	INC	DI		;address next display position
	CMPSB			;test for G
	MOV	DL,'Y'		;load Y for possible BUG
	JE	L3		;if BUG is found
L2:
	POP	DI		;restore display address
	ADD	DI,2		;point to next display position
	LOOP	L1		;repeat until entire screen is tested
	PUSH	DI		;save display address
	MOV	DL,'N'		;indicate N if BUG not found
L3:
	POP	DI		;clear stack
	MOV	AH,2		;display DL function
	INT	21H		;display ASCII from DL
	.EXIT			;exit to DOS
	END			;end of file
