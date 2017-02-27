;a program that displays two test lines of text on a cyan graphics
;background screen.
;
	.MODEL SMALL
	.DATA
MES1	DB	'This is test line 1.',0
MES2	DB	'This is test line 2.',0
        
	.CODE
;        .STARTUP
	MOV	AX,0A000H	;address video RAM
	MOV	DS,AX
	CLD			;select increment
        
	MOV	AX,12H		;set mode to 12H
	INT	10H		;and clear screen
                                                
	MOV	DL,3		;color cyan
	MOV	DH,53		;row counter
	MOV	BX,0		;row 0
MAIN1:
	MOV	CX,80		;column counter
	MOV	SI,0		;column 0
MAIN2:
	CALL	BLOCK		;display a cyan block
	INC	SI		;address next column
	LOOP	MAIN2		;repeat 80 times
	INC	BX		;address next row
	DEC	DH		;decrement row counter
	JNZ	MAIN1		;repeat for 53 rows
        
	MOV	AX,@DATA	;address data segment
	MOV	ES,AX		;with ES
        
	MOV	DL,9		;bright blue text
	MOV	BX,5		;row 5
	MOV	SI,0		;column 0
	MOV	DI,OFFSET MES1	;address MES1
	CALL	LINE		;display bright blue MES1
        
	MOV	DL,12		;bright red
	MOV	BX,15		;row 15
	MOV	SI,0		;column 0
	MOV	DI,OFFSET MES2	;address MES2
	CALL	LINE		;display bright red MES2
        
	MOV	AH,1		;wait for key
	INT	21H
        
	MOV	AX,3
	INT	10H		;return to DOS video mode
;        .EXIT
;
;The line procedure displays the line of text addressed by ES:DI
;DL = color of text (0 to 15).
;The text must be stored as a null string
;BX = row
;SI = column
;
LINE	PROC	NEAR
        
	MOV	AL,ES:[DI]	;get character
	OR	AL,AL		;test for null
	JZ	LINE1		;if null
	PUSH	ES		;save registers
	PUSH	DI
	PUSH	SI
	CALL	CHAR		;display characters
	POP	SI		;restore registers
	POP	DI
	POP	ES
	INC	SI		;address next column
	INC	DI		;address next character
	JMP	LINE		;repeat until null
LINE1:
	RET
        
LINE	ENDP
;
;The CHAR procedure displays a character (8 x 8) on the
;mode 12H display without changing the background color.
;AL = ASCII code
;DL = color (0 to 15)
;BX = row (0 to 52)
;SI = column (0 to 79)
;
CHAR	PROC	NEAR
        
	PUSH	CX
	PUSH	DX
	PUSH	BX		;save row address
	PUSH	AX		;save ASCII
	MOV	AX,1130H	;get 8 x 8 set
	MOV	BH,3	
	INT	10H
	POP	AX		;get ASCII code
	MOV	AH,0
	SHL	AX,1		;multiply by 8
	SHL	AX,1
	SHL	AX,1
	ADD	BP,AX		;index character in ROM
	POP	BX		;get row address
	MOV	AX,80*9		;find row address
	MUL	BX
	MOV	DI,AX
	ADD	DI,SI		;add in column address
	MOV	CX,8		;set count to 8 rows
C1:
	MOV	DX,3CEH		;address bit mask register
	MOV	AL,8		;load index 8
	MOV	AH,ES:[BP]	;get character row
	INC	BP		;point to next row
	OUT	DX,AX
	MOV	DX,3C4H		;address map mask register
	MOV	AX,0F02H
	OUT	DX,AX		;select all planes
	INC	DX
	MOV	AL,[DI]		;read data
	MOV	BYTE PTR [DI],0	;write black
	POP	AX		;get color	
	PUSH	AX
	OUT	DX,AL		;write color
	MOV	BYTE PTR [DI],0FFH
	ADD	DI,80		;address next raster row
	LOOP	C1		;repeat 8 times
	POP	DX	
	POP	CX
	RET
        
CHAR	ENDP
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

