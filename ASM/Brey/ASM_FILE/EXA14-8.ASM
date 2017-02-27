;a program that tests for DPMI that also displays information
;about the installation of DPMI.  Note that this program must
;be executed from WINDOWS or with a DOS extender.
;
	.MODEL SMALL
	.386
	.DATA
SUP	DW	?	;support flag
PROCS	DB	?	;processor type
VERS	DW	?	;version number
ENTR	DD	?	;entry point
ERR	DB	13,10,10,'Must run from WINDOWS.$'
MES1	DB	13,10,10,'DPMI version = $'
MES2	DB	13,10,'CPU version = $'
MES3	DB	13,10,'Protected mode entry point = $'
CPUT	DW	C1,C2,C3
C1	DB	'80286.$'
C2	DB	'80386.$'
C3	DB	'80486.$'
C4	DB	'unknown.$'
C5	DB	13,10,'DPMI supports 16-bit mode.$'
C6	DB	13,10,'DPMI supports 32-bit mode.$'
	.CODE
	.STARTUP
	CALL	ISDPMI		;is DPMI loaded?    
	JC	MAIN1		;if it is loaded
	MOV	AH,9
	MOV	DX,OFFSET ERR
	INT	21H		;display not loaded
	JMP	MAIN4		;end program
MAIN1:
	MOV	AH,9		;display version
	MOV	DX,OFFSET MES1
	INT	21H
	MOV	BX,VERS
	MOV	AL,BH	
	CALL	DISPB
	MOV	AH,6
	MOV	DL,'.'
	INT	21H
	MOV	AX,VERS
	CALL	DISPB		;display CPU type
	MOV	AH,9
	MOV	DX,OFFSET MES2
	INT	21H
	MOV	AH,0
	MOV	AL,PROCS
	SUB	AX,2
	MOV	DX,OFFSET C4	;unknown CPU
	JB	MAIN2
	CMP	AL,2
	JA	MAIN2
	ADD	AX,AX
	MOV	SI,OFFSET CPUT
	ADD	SI,AX
	MOV	DX,[SI]
MAIN2:
	MOV	AH,9
	INT	21H
	MOV	DX,OFFSET C5
	CMP	SUP,0	
	JE	MAIN3
	MOV	DX,OFFSET C6
MAIN3:
	MOV	AH,9
	INT	21H		;support
	MOV	AH,9
	MOV	DX,OFFSET MES3
	INT	21H		;entry point
	MOV	AX,WORD PTR ENTR+2
	CALL	DISPH
	MOV	AH,6
	MOV	DL,':'
	INT	21H
	MOV	AX,WORD PTR ENTR
	CALL	DISPH
MAIN4:
	.EXIT
;
;the ISDPMI procedure tests for the presence of DPMI.
;***return parameter***
;if carry = 1, DPMI is installed
;if carry = 0, DPMI is not installed
;                                       
ISDPMI	PROC	NEAR
                                                
	MOV	AX,1687H
	INT	2FH		;get entry point
	OR	AX,AX
	JNE	ISDPMI1		;if not loaded
	AND	BX,1
	MOV	SUP,BX		;save support
	MOV	PROCS,CL	;save processor type
	MOV	VERS,DX		;save version
	MOV	WORD PTR ENTR,DI ;save entry point
	MOV	WORD PTR ENTR+2,ES
	STC			;set carry for loaded
ISDPMI1:
	RET
                                                
ISDPMI	ENDP
;
;the DISPB procedure displays contents of AL in 
;decimal format.
;                       
DISPB	PROC	NEAR
                                                
	MOV	AH,0	
	AAM			;convert to BCD
	ADD	AX,3030H	;convert to ASCII
	CMP	AH,30H		;test for leading zero	
	JE	DISPB1		;blank leading zero
	PUSH	AX
	MOV	DL,AH		;display non blank
	MOV	AH,6
	INT	21H
	POP	AX
DISPB1:
	MOV	DL,AL		;display second digit
	MOV	AH,6
	INT	21H
	RET

DISPB	ENDP
;
;the DISPH procedure displays the contents of BX as a
;4 digit hexadecimal value.
;                                       
DISPH	PROC	NEAR
        
	MOV	CX,4		;set digit count
DISPH1:
	ROL	BX,4		;position digit
	MOV	DL,BL
	AND	DL,0FH
	.IF DL > 9		;convert to ASCII
		ADD	DL,37H
	.ELSE
		ADD	DL,30H
	.ENDIF
	MOV	AH,6		;display digit
	INT	21H
	LOOP	DISPH1		;repeat 4 times
	RET
                                                
DISPH	ENDP
	END
