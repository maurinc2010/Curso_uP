;a program that reads the keyboard and converts all lowercase
;data to uppercase before displaying it.
;
;this program uses a control C for termination
;
	.MODEL TINY		;select TINY model
	.LISTALL		;list all assembler generated statements
	.CODE			;start CODE segment
	.STARTUP		;start program
MAIN1:
	MOV	AH,6		;read key without echo
	MOV	DL,0FFH
	INT	21H
	JE	MAIN1		;if no key typed
	CMP	AL,3		;test for control C key
	JE	MAIN2		;if control C key
        
	.IF   AL>='a' && AL<='z'
		SUB	AL,20H
	.ENDIF
        
	MOV	DL,AL		;echo character to display
	INT	21H
	JMP	MAIN1		;repeat
MAIN2:
	.EXIT			;exit to DOS on control C
	END			;end of file
