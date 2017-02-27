;a program that displays all of 256 colors available to the
;320 x 200 video display mode (13H)
;***uses***
;the BAND procedure to display 64 colors at a time in a band
;on the display.
;
	.MODEL TINY
	.CODE
;        .STARTUP
	MOV	AX,13H		;select mode 13H
	INT	10H
        
	MOV	AX,0A000H	;address segment A000 with ES
	MOV	ES,AX
	CLD			;select increment
	MOV	DI,0		;address offset 0000
        
	MOV	AL,0		;load starting test color of 00H
	CALL	BAND		;display one band of 64 colors
        
	MOV	AL,64		;load starting color of 40H
	CALL	BAND		;display one band of 64 colors
        
	MOV	AL,128		;load starting color of 80H
	CALL	BAND		;display one band of 64 colors
        
	MOV	AL,192		;load starting color of C0H
	CALL	BAND		;display one band of 64 colors
        
	MOV	AH,1		;wait for any key
	INT	21H
        
	MOV	AX,3		;switch back to DOS video mode
	INT	10H
;        .EXIT
;
;the BAND procedure displays a color band of 64 colors
;***input parameter***
;AL = starting color number
;ES = A000H
;DI = starting offset address for display
;
BAND	PROC	NEAR
        
	MOV	BH,40		;load line count
BAND1:
	PUSH	AX		;save starting color
	MOV	CX,64		;load color across line count
BAND2:
	MOV	BL,5		;load times color is displayed
BAND3:
	STOSB			;store color
	DEC	BL   
	JNZ	BAND3		;repeat 5 times
	INC	AL		;change to next color
	LOOP	BAND2		;repeat for 64 colors
	POP	AX		;restore starting color
	DEC	BH
	JNZ	BAND1		;repeat for 40 lines
	ADD	DI,320*10	;skip 10 lines
	RET
        
BAND	ENDP
	END

