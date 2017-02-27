;a program that creates a new directory in the root of drive C
;the name of the directory is a parameter
;
	.MODEL SMALL
	.DATA
FILE1	DB	128 DUP (0)		;space for parameter
ROOTS	DB	'C:\',0 		;root directory 
	.CODE
	.STARTUP
	PUSH	DS			;exchange ES with DS
	PUSH	ES
	POP	DS
	POP	ES
	MOV	DI,OFFSET FILE1		;address FILE1
	CALL	EX			;get command line parameter
	JC	ERR			;if no parameter
	MOV	AX,ES
	MOV	DS,AX			;make ES and DS overlap
        
	MOV	AH,0EH			;log to drive C
	MOV	DL,2			;select drive C (2)
	INT	21H
        
	MOV	AH,3BH			;log to root
	MOV	DX,OFFSET ROOTS
	INT	21H
        
	MOV	AH,39H			;make new directory
	MOV	DX,OFFSET FILE1
	INT	21H
ERR:
	.EXIT
;
;The EX procedure copies the first parameter from the command line
;into the location addressed by ES:DI.
;***Input parameters***
;ES:DI = address for storage of command line parameter
;DS = segment of PSP
;***Output parameters***
;Carry = 0 for normal return
;Carry = 1 if no parameter is found
;
EX	PROC	NEAR
        
 	MOV	SI,81H			;address command line
        
	.REPEAT
		LODSB
	.UNTIL	AL > ' ' ||  AL == 13
        
	CMP	AL,13			;test for enter
	STC
	JE	EX1			;if enter
	DEC	SI			;adjust pointer
        
	.REPEAT
        	LODSB
		.IF	AL >= 'a' && AL <= 'z'
			SUB   AL,20H
		.ENDIF
	STOSB
	.UNTIL	AL == 13 || AL <= ' ' || AL == 2CH
        
	DEC	DI			;adjust pointer
	MOV	AL,0			;make it an ASCII-Z string
	STOSB
	CLC
EX1:
	RET
        
EX	ENDP
	END
