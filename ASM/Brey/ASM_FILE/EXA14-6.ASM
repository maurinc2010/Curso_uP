;a program that tests for the presence of an XMS driver.
;If the driver is present, it displays the driver version
;number and the size of available and free extended memory
;in bytes.
; 
	.MODEL SMALL
	.386
	.DATA
XMS	DD	?		;address of XMS driver
ERR1	DB	13,10,10,'XMS driver not present.$'
MES1	DB	13,10,10,'XMS version number = $'
MES2	DB	' . $'
MES3	DB	13,10,'Total extended memory = $'
MES4	DB	13,10,'Free extended memory = $'
	.CODE
	.STARTUP
	CALL	ISXMS		;is XMS driver present
	JNC	MAIN1		;if installed
	MOV	AH,9
	MOV	DX,OFFSET ERR1
	INT	21H		;not installed
	JMP	MAIN2
MAIN1:
	MOV	AH,9
	MOV	DX,OFFSET MES1
	INT	21H
	MOV	AH,0		;get XMS version
	CALL	XMS		;access XMS driver
	ADD	AX,3030H	;make ASCII
	MOV	MES2,AH		;save version
	MOV	MES2+2,AL	
	MOV	AH,9
	MOV	DX,OFFSET MES2
	INT	21H		;display version
	MOV	AH,9
	MOV	DX,OFFSET MES3
	INT	21H
	MOV	AH,8		;get memory info
	CALL	XMS
	PUSH	AX		;save free memory
	CALL	DISPD		;display total memory
	MOV	AH,9
	MOV	DX,OFFSET MES4
	INT	21H
	POP	DX
	CALL	DISPD		;display free memory
MAIN2:
	.EXIT
;
;the ISXMS procedure tests for the presence of the XMS driver.
;If the driver is not present a return with carry = 1 occurs
;If the driver is present the address of the driver entry point
;is stored at location XMS for later access and a return with
;carry = 0 occurs.
;                               
ISXMS	PROC	NEAR
                                                
	MOV	AX,4300H	;check XMS
	INT	2FH		;do multiplex interrupt
	CMP	AL,0
	JE	ISXMS1		;if not installed
	MOV	AX,4310H	;get driver address
	INT	2FH
	MOV	WORD PTR XMS,BX	;save driver address
	MOV	WORD PTR XMS+2,ES
	STC
ISXMS1:
	CMC			;return carry = not installed
	RET
                                                     
ISXMS	ENDP
;
;the DISPD procedure display the contents of DX after it is 
;multiplied by 1,024.  This displays the size of memory in 
;bytes.
;                                       
DISPD	PROC	NEAR
        
	MOV	EAX,0
	AND	EDX,0FFFFH
	MOV	AX,400H		;find 1K times blocks
	MUL	DX
	SHL	EDX,16
	ADD	EAX,EDX
	MOV	EBX,10
	PUSH	BX		;mark end
	MOV	CX,3		;load comma count
DISPD1:
	MOV	EDX,0
	DIV	EBX		;divide by 10
	ADD	DL,30H		;make ASCII
	PUSH	DX
	CMP	EAX,0
	JE	DISPD2
	LOOP	DISPD1
	MOV	DL,','
	PUSH	DX		;save comma
	MOV	CX,3
	JMP	DISPD1
DISPD2:
	MOV	AH,6	
	POP	DX		;get data
	CMP	DL,BL
	JE	DISPD3		;if done
	INT	21H		;display it
	JMP	DISPD2
DISPD3:
	RET
                                                
DISPD	ENDP
	END
