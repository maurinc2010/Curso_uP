;a program that displays the mouse driver version number and
;the type of mouse installed.
;
	.MODEL SMALL
	.DATA
MES1	DB	13,10,'No MOUSE or MOUSE DRIVER found.$'
MES2	DB	13,10,'Mouse driver version '
M1	DB	'       ',13,10,'$'
TYPES	DW	T1,T2,T3,T4,T5
T1	DB	'Bus$'
T2	DB	'Serial$'
T3	DB	'InPort$'
T4	DB	'PS/2$'
T5	DB	'HP$'
MES3	DB	' mouse installed.',13,10,'$'
	.CODE
	.STARTUP
	CALL	CHKM			;test for mouse
	JNC	MAIN1			;if mouse present
	MOV	DX,OFFSET MES1
	JMP	MAIN2			;if no mouse
MAIN1:
	MOV	AX,24H
	INT	33H			;get driver version and type
	MOV	DI,OFFSET M1
	MOV	AL,BH			;save ASCII major version 
	CALL	DISP
	MOV	BYTE PTR [DI],'.'	;save period
	INC	DI
        
	MOV	AL,BL			;save ASCII minor version
	CALL	DISP

	MOV	DX,OFFSET MES2		;display version number
	MOV	AH,9
	INT	21H
        
	MOV	SI,OFFSET TYPES		;index type
	MOV	AH,0
	MOV	AL,CH
	DEC	AX
	ADD	SI,AX
	ADD	SI,AX
	MOV	DX,[SI]			;display type
	MOV	AH,9
	INT	21H
	MOV	DX,OFFSET MES3
MAIN2:
	MOV	AH,9
	INT	21H
	.EXIT
;
;procedure that tests for the presence of a mouse driver
;***Output paramters***
;Carry = 1, if no mouse present
;Carry = 0, if mouse is present
;
CHKM	PROC	NEAR
                                                
	MOV	AX,3533H		;get INT 33H vector
	INT	21H			;returns vector in ES:BX
                                                
	MOV	AX,ES
	OR	AX,BX			;test for 0000:0000	
	STC
	JZ	CHKM1			;if no mouse driver
	CMP	BYTE PTR ES:[BX],0CFH
	STC
	JE	CHKM1			;if no mouse driver
	MOV	AX,0
	INT	33H			;reset mouse
	CMP	AX,0
	STC
	JZ 	CHKM1			;if no mouse
	CLC
CHKM1:
	RET
                                                
CHKM	ENDP
;
;save the ASCII coded version number
;***input parameters***
;AL = version
;DS:DI = address where stored
;***output parameters***
;ASCII version number stored at DS:DI
;
DISP	PROC	NEAR
        
	MOV	AH,0
	AAM				;convert to BCD
	ADD	AX,3030H
	CMP	AH,30H			;save ASCII version
	JE	DISP1			;supress leading zero
	MOV	[DI],AH
	INC	DI
DISP1:
	MOV	[DI],AL
	INC	DI
	RET
        
DISP	ENDP
	END
