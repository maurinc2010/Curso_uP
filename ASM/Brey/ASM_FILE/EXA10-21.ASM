;a program that display a cyan bar across the top of a white 
;screen.
;
	.MODEL TINY
	.CODE
;        .STARTUP
	MOV	AX,0A000H	;address video RAM at segment A000
	MOV	DS,AX
	CLD			;select increment
                                                
	MOV	AX,12H		;set mode to 12H
	INT	10H		;and clear screen
                                                
	MOV	CX,80		;block count
	MOV	BX,0		;row address
	MOV	SI,0		;column address
	MOV	DL,3		;color 3 (cyan)
MAIN1:				;plot 80 blocks
	CALL	BLOCK		;display a block
	INC	SI		;address next column
	LOOP	MAIN1		;repeat 80 times
        
	MOV	BX,1		;row address
	MOV	DL,7		;color 7 (white)
	MOV	DH,52		;row count
MAIN2:
	MOV	SI,0		;column address
	MOV	CX,80		;column count
MAIN3:
	CALL	BLOCK		;display a block	
	INC	SI		;address next column
	LOOP	MAIN3		;repeat 80 times
	INC	BX		;increment row address
	DEC	DH
	JNZ	MAIN2		;repeat 52 times
        
	MOV	AH,1		;wait for key
	INT	21H
        
	MOV	AX,3	
	INT	10H		;return to DOS video mode
;        .EXIT
;                                       
;The BLOCK procedure display one block that is 8 PELs
;wide by 9 PELs high.
;BX = row address (0 to 52)
;SI = column address (0 to 79)
;DL = block color (0 to 15)
;
BLOCK	PROC	NEAR
                                                
	PUSH	CX
	PUSH	DX		;save color
        
	MOV	DX,3CEH		;graphics address register
	MOV	AL,8		;select bit mask register
	OUT	DX,AL
	MOV	DX,3CFH		;bit mask register
	MOV	AL,0FFH		;enable all 8 bits
	OUT	DX,AL
        
	MOV	DX,3C4H		;sequence address register
	MOV	AL,2		;select map mask register
	OUT	DX,AL
                                                
	MOV	AX,80*9		;find row address byte
	MUL	BX
	MOV	DI,AX		;save it
	ADD	DI,SI		;form address of PEL byte
        
	MOV	CX,9		;byte count
	MOV	DX,3C5H		;map mask register
	POP	AX		;get color
	PUSH	AX
	MOV	AH,AL
BLOCK1:
	MOV	AL,0FH		;enable all planes
	OUT	DX,AL
	MOV	AL,[DI]		;must read first
	MOV	BYTE PTR [DI],0	;clear old color
	MOV	AL,AH
	OUT	DX,AL
	MOV	BYTE PTR [DI],0FFH	;write memory
	ADD	DI,80
	LOOP	BLOCK1
        
	POP	DX
	POP	CX
	RET

BLOCK	ENDP
	END

