;a program that displays a green box on the video screen using
;video mode 13H.
;
	.MODEL TINY
	.CODE
;        .STARTUP
	CLD			;select auto-increment
        
	MOV	AX,13H		;select mode 13H
	INT	10H		;this also clears the screen
                                                
	MOV	AL,2		;use color 02H (green)
	MOV	CX,100		;starting column number
	MOV	SI,10		;starting row number
	MOV	BP,75		;size
	CALL	BOX		;display box
        
	MOV	AH,1		;wait for any key
	INT	21H
        
	MOV	AX,3		;switch to DOS video mode
	INT	10H
;        .EXIT
;
;the BOX procedure displays a box on the mode 13H display.
;***input parameters***
;AL = color number (0-255)
;CX = starting column number (0-319)
;SI = starting row number (0-199)
;BP = size of box
;
BOX	PROC	NEAR
                                                
	MOV	BX,0A000H	;address segment A000 with ES
	MOV	ES,BX
	PUSH	AX		;save color
	MOV	AX,320		;find starting PEL
	MUL	SI
	MOV	DI,AX		;address start of BOX
	ADD	DI,CX
	POP	AX
	PUSH	DI		;save starting offset address
	MOV	CX,BP		;save size in BP
BOX1:
	REP	STOSB		;draw top line
	MOV	CX,BP
	SUB	CX,2		;adjust CX
BOX2:
	POP	DI
	ADD	DI,320		;address next row
	PUSH	DI
	STOSB			;draw PEL
	ADD	DI,BP
	SUB	DI,2
	STOSB			;draw PEL
	LOOP	BOX2
                                                
	POP	DI
	ADD	DI,320		;address last row
	MOV	CX,BP
	REP	STOSB
	RET
                                                
BOX	ENDP
	END

