;a program that displays a short cyan line that is 10 PELs wide
;with a red dot below and to the right of the cyan line.
;
	.MODEL TINY
	.CODE
;        .STARTUP
	MOV	AX,0A000H	;address video RAM at segment A000
	MOV	DS,AX
	CLD			;select increment
                                                
	MOV	AX,12H		;set mode to 12H
	INT	10H		;and clear screen
                                                
	MOV	CX,10		;set dot count to 10
	MOV	BX,10		;row address
	MOV	SI,100		;column address
	MOV	DL,3		;color 3 (cyan)
MAIN1:				;plot 10 dots
	CALL	DOT		;display one dot
	INC	SI
	LOOP	MAIN1		;repeat 10 times
                                                
	MOV	BX,40		;row address
	MOV	SI,200		;column address
	MOV	DL,4		;color 4 (red)
	CALL	DOT		;display one red dot
        
	MOV	AH,1		;wait for key
	INT	21H
        
	MOV	AX,3
	INT	10H		;return to DOS video mode
;        .EXIT
;
;the DOT procedure displays one dot or PEL on the video display.
;BX = row address (0 to 479)
;SI = column address (0 to 639)
;DL = color (0 to 15)
;
DOT	PROC	NEAR
                                                
	PUSH	CX
	PUSH	DX		;save color
	MOV	AX,80		;find row address byte
	MUL	BX
	MOV	DI,AX		;save it
	MOV	AX,SI		;find column address byte
	MOV	DH,8
	DIV	DH
	MOV	CL,AH		;get shift count
	MOV	AH,0
	ADD	DI,AX		;form address of PEL byte

	MOV	AL,80H
	SHR	AL,CL		;find bit in bit mask register
	PUSH	AX		;save bit mask
        
	MOV	DX,3CEH		;graphics address register
	MOV	AL,8		;select bit mask register	
	OUT	DX,AL

	MOV	DX,3CFH		;bit mask register
	POP	AX		;get bit mask
	OUT	DX,AL
        
	MOV	DX,3C4H		;sequence address register
	MOV	AL,2		;select map mask register
	OUT	DX,AL
                                                
	MOV	DX,3C5H		;map mask register
	MOV	AL,0FH		;enable all planes
	OUT	DX,AL
                                                
	MOV	AL,[DI]		;must read first
	MOV	BYTE PTR [DI],0	;clear old color
	POP	AX 		;get color from stack
	PUSH	AX
	OUT	DX,AL
	MOV	BYTE PTR [DI],0FFH	;write memory
        
	POP	DX		;restore registers
	POP	CX
	RET
                                                
DOT	ENDP
	END

