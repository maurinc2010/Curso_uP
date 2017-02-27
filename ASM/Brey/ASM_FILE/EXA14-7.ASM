;a program that tests to determine if VCPI is installed.
;
	.MODEL SMALL
	.386
	.DATA
EMS	DB	'EMMXXXX0',0	;EMS name
ERR1	DB	13,10,10,'VCPI not installed.$'
MES1	DB	13,10,10,'VCPI version '
VER	DB	' . $'
MES2	DB	13,10,'Free VCPI memory = $'
	.CODE
	.STARTUP
	CALL	ISVCPI
	JNC	MAIN1		;if EMS $ VCPI is installed
ERR:	MOV	AH,9
	MOV	DX,OFFSET ERR1
	INT	21H		;display error
	JMP	MAIN2
MAIN1:	ADD	BX,3030H	;make version ASCII
	MOV	VER,BH		;save major
	MOV	VER+2,BL	;save minor
	MOV	AH,9
	MOV	DX,OFFSET MES1
	INT	21H		;display version
	MOV	AX,0DE03H	;get memory info
	INT	67H
	CMP	AH,0	
	JNE	ERR		;if error
	SHL	EDX,12		;multiply EDX by 4K
	MOV	EAX,EDX
	CALL	DISPD		;display free VCPI memory
MAIN2:
	.EXIT
;
;the ISVCPI procedure detects the VCPI driver.
;***return parameter***
;carry = 1, if VCPI is not installed
;carry = 0, if VCPI is installed
;                                       
ISVCPI	PROC	NEAR
        
	CALL	ISEMS		;test for EMS
	JC	ISVCPI1		;if no EMS
	MOV	AX,0DE00H	;test for VCPI
	INT	67H
	CMP	AL,0
	JE	ISVCPI1		;if VCPI is found
	STC
ISVCPI1:
	RET
                                                
ISVCPI	ENDP
;
;the ISEMS procedure determines if EMS is installed.
;***return parameter***
;carry = 1, if no EMS installed
;carry = 0, if EMS is installed
;                                       
ISEMS	PROC	NEAR
                                                
	MOV	AX,3D00H
	MOV	DX,OFFSET EMS
	INT	21H		;open EMS driver
	JC	ISEMS1		;if not found
	MOV	BX,AX		;save handle
	MOV	AX,4407H	;check IOCTL
	INT	21H
	JC	ISEMS1		;if not found
	CMP	AL,0FFH
ISEMS1:
	PUSHF
	MOV	AH,3EH		;close file
	INT	21H
	POPF
	RET
                                                
ISEMS	ENDP
;
;the DISPD procedure displays the amount of free memory 
;available to VCPI.
;
DISPD	PROC	NEAR
                                                
	PUSH	EAX		;save number
	MOV	AH,9
	MOV	DX,OFFSET MES2	;display free memory string
	INT	21H
	POP	EAX
	MOV	EBX,10
	MOV	CX,-1
	PUSH	CX		;save end
	MOV	CX,3
DISPD1:
	MOV	EDX,0		;clear EDX
	DIV	EBX		;divide by 10
	ADD	DL,30H		;convert to ASCII
	PUSH	DX
	CMP	EAX,0
	JE	DISPD2		;if done
	LOOP	DISPD1
	MOV	DL,','		;save comma
	PUSH	DX
	MOV	CX,3
	JMP	DISPD1
DISPD2:
	MOV	AH,6
	POP	DX
	CMP	DL,-1
	JE	DISPD3		;if done
	INT	21H		;display digit
	JMP	DISPD2
DISPD3:
	RET
                                                
DISPD	ENDP
	END
