;a program that displays the mouse pointer and its X and Y
;position.
;
	.MODEL SMALL
	.DATA
MES	DB	13,'X Position= '
MX	DB	'      '
	DB	'Y Position= '
MY	DB	'      $'
X	DW	?		;X position
Y	DW	?		;Y position
	.CODE
;        .STARTUP
	CALL	TM_ON		;enable mouse
	JC	MAIN4		;if no mouse
MAIN1:
	MOV	AX,3		;get mouse status
	INT	33H
	CMP	BX,1
	JE	MAIN3		;if left button pressed
        
	CMP	CX,X
	JNE	MAIN2		;if X position changed
	CMP	DX,Y
	JE	MAIN1		;if Y position did not change
MAIN2:
	MOV	X,CX		;save new position
	MOV	Y,DX
	MOV	DI,OFFSET MX
	MOV	AX,CX
	CALL	PLACE		;store ASCII X
	MOV	DI,OFFSET MY
	MOV	AX,Y
	CALL	PLACE		;store ASCII Y
        
	MOV	AX,2
	INT	33H		;hide mouse pointer
                                                
	MOV	AH,9
	MOV	DX,OFFSET MES
	INT	21H		;display position
                                                
	MOV	AX,1
	INT	33H		;show mouse pointer
                                                
	JMP	MAIN1		;do again
MAIN3:
	MOV	AX,0		;reset mouse
	INT	33H        
MAIN4:
;        .EXIT
;
;procedure that tests for the presence of a mouse driver
;***Output paramters***
;Carry = 1, if no mouse present
;Carry = 0, if mouse is present
;
CHKM	PROC	NEAR
                                                
	MOV	AX,3533H	;get INT 33H vector
	INT	21H		;returns vector in ES:BX
                                        
	MOV	AX,ES
	OR	AX,BX		;test for 0000:0000
	STC
	JZ	CHKM1		;if no mouse driver
	CMP	BYTE PTR ES:[BX],0CFH	
	STC
	JE	CHKM1		;if no mouse driver
	MOV	AX,0
	INT	33H		;reset mouse
	CMP	AX,0
	STC
	JZ	CHKM1		;if no mouse
	CLC
CHKM1:
	RET
                                                
CHKM	ENDP
;
;the TM_ON procedure tests for the presence of a mouse
;and enables mouse pointer.
;uses the CHKM (check for mouse) procedure
;
;***output parameters***
;Carry = 0, if mouse is present pointer enabled
;Carry = 1, if no mouse present
;
TM_ON	PROC	NEAR
        
	CALL	CHKM		;test for mouse
	JC	TM_ON1
	MOV	AX,1		;show mouse pointer
	INT	33H
	CLC
TM_ON1:
	RET
                                                
TM_ON	ENDP
;
;The PLACE procedure converts the contents of AX into a
;decimal ASCII coded number stored at the memory location
;addressed by DS:DI
;***input parameters***
;AX = number to be converted to decimal ASCII code
;DS:DI = address where number is stored
;
PLACE	PROC	NEAR
                                                
	MOV	CX,0		;clear count
	MOV	BX,10		;set divisor
PLACE1:
	MOV	DX,0		;clear DX
	DIV	BX		;divide by 10
	PUSH	DX
	INC	CX
	CMP	AX,0
	JNE	PLACE1		;repeat until quotient 0
PLACE2:
	MOV	BX,5
	SUB	BX,CX
PLACE3:
	POP	DX
	ADD	DL,30H		;convert to ASCII
	MOV	[DI],DL		;store digit
	INC	DI
	LOOP	PLACE3
	CMP	BX,0
	JE	PLACE5
	MOV	CX,BX
PLACE4:
	MOV	BYTE PTR [DI],20H
	INC	DI
	LOOP	PLACE4
PLACE5:
	RET
        
PLACE	ENDP
	END

