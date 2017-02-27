;a program that tests for the presence of an extended memory
;manager and expanded memory.  If present, the program displays
;the version number, page frame address, total expanded memory,
;and available expanded memory.
;
	.MODEL SMALL
	.386
	.DATA
EMM	DB	'EMMXXXX0',0	;EMM driver name
ERR	DB	13,10,10,'No EMM driver present.$'
MES1	DB	13,10,10,'EMM version number $'
MES2	DB	13,10,'Page frame address = $'
MES3	DB	13,10,'Total expanded memory = $'
MES4	DB	13,10,'Available expanded memory = $'
	.CODE
	.STARTUP
	CALL	ISEMS		;see if EMS driver present
	JNC	MAIN1		;if EMM driver present
	MOV	AH,9
	MOV	DX,OFFSET ERR	;display no EMM driver
	INT	21H
	JMP	MAIN2		;end it
MAIN1:
	MOV	AH,9
	MOV	DX,OFFSET MES1
	INT	21H		;display EMM version number
        
	MOV	AH,46H
	INT	67H		;get version number
                                                
	MOV	AH,AL		;get minor version
	AND	AH,0FH
	SHR	AL,4		;get major version
	ADD	AX,3030H	;make ASCII
	PUSH	AX
	MOV	DL,AL		;display version number
	MOV	AH,6
	INT	21H
	MOV	DL,'.'
	INT	21H
	POP	DX
	MOV	DL,DH
	INT	21H
	MOV	AH,9
	MOV	DX,OFFSET MES2
	INT	21H		;page frame address	
	MOV	AH,41H
	INT	67H		;get page frame address
	CALL	DISPH		;display hex address
	MOV	AH,9
	MOV	DX,OFFSET MES3
	INT	21H		;total expanded memory
	MOV	AH,42H
	INT	67H		;get number of pages
	MOV	AX,DX
	MOV	CX,4000H
	MUL	CX		;find total
	CALL	DISPD		;display decimal
	MOV	AH,9
	MOV	DX,OFFSET MES4
	INT	21H		;available expanded memory
	MOV	AX,BX
	MOV	CX,4000H
	MUL	CX
	CALL	DISPD
MAIN2:
	.EXIT
;
;the ISEMS procedure tests to determine of EMM is loaded.
;***return parameter***
;if carry = 1, EMM is not installed
;if carry = 0, EMM is installed
;
ISEMS	PROC	NEAR
                                                
	MOV	AX,3D00H
	MOV	DX,OFFSET EMM
	INT	21H		;open file
	JC	ISEMS1		;if EMM not there
	MOV	BX,AX		;save handle
	MOV	AX,4407H	;access IOCTL function 7
	INT	21H
	JC	ISEMS1		;if error
	CMP	AL,-1
	JE	ISEMS1		;if present
	STC
ISEMS1:
	PUSHF			;save carry
	MOV	AH,3EH		;close file
	INT	21H
	POPF
	RET
                                                
ISEMS	ENDP
;
;the DISPH is places the contents of BX as a 4 digit
;hexadecimal number.
;                       
DISPH	PROC	NEAR
                                                
	MOV	CH,4
DISPH1:
	ROL	BX,4		;get digit
	MOV	DL,BL
	AND	DL,0FH
	ADD	DL,30H		;convert to ASCII
	.IF DL > 39H
		ADD	DL,7	;if a letter add 7 more
	.ENDIF
	MOV	AH,6		;display contents of DL
	INT	21H
	DEC	CH		;count off 4
	JNZ	DISPH1		;repeat 4 times
	RET
        
DISPH	ENDP
;
;the DISPD procedure displays the contents of EAX in decimal
;with commas.
;
DISPD	PROC	NEAR
                                                
	PUSH	BX		;save BX
	MOV	BP,','
	SHL	EDX,16
	AND	EAX,0FFFF0000H
	ADD	EAX,EDX
	MOV	CX,3		;comma counter
	MOV	BX,-1
	PUSH	BX		;indicate end
	MOV	EBX,10		;division factor
DISPD1:
	XOR	EDX,EDX
	DIV	EBX
	ADD	DL,30H		;make ASCII
	PUSH	DX
	CMP	EAX,0
	JE	DISPD2		;if done
	LOOP	DISPD1		;do three times
	PUSH	BP		;save comma
	MOV	CX,3
	JMP	DISPD1
DISPD2:
	MOV	AH,6		;display decimal digit
	POP	DX
	CMP	DL,-1
	JE	DISPD3
	INT	21H
	JMP	DISPD2
DISPD3:
	POP	BX		;restore BX
	RET
                                                
DISPD	ENDP
	END
