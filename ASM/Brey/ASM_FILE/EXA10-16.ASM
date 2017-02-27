;a program that displays all the possible brightness levels of the 
;color red for the 320 x 200, 256 color mode (13H)
;
	.MODEL TINY
	.CODE
;        .STARTUP
	MOV	AX,13H		;switch to mode 13H
	INT	10H
        
	MOV	AX,0A000H	;address segment A000 with ES
	MOV	ES,AX
	CLD			;select increment
        
        MOV     CH,20            ;green value
        MOV     CL,0            ;blue value
	MOV	DH,0		;red value
	MOV	BX,80H		;color register number 80H
	MOV	AX,1010H	;change palette color function
	MOV	DL,64		;count to change colors 80H to BFH
PROG1:
	INT	10H		;change a color value
	INC	DH		;next color of red
	INC	BX		;next color palette register	
	DEC	DL
	JNZ	PROG1		;repeat for 64 colors
        
	MOV	DI,0		;address offset 0000
	MOV	AL,80H		;starting color number
	CALL	BAND		;display 64 colors

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
        
	MOV	BH,40		;line count of 40
BAND1:
	PUSH	AX		;save starting color number
	MOV	CX,64		;color count of 64
BAND2:
	MOV	BL,5		;load times color is displayed
BAND3:
        STOSB     ;store color
	DEC	BL
	JNZ	BAND3		;repeat 5 times
	INC	AL		;get next color number
	LOOP	BAND2		;repeat for all 64 colors
	POP	AX		;restore original color number
	DEC	BH
	JNZ	BAND1		;repeat for 40 raster lines
	ADD	DI,320*10	;skip 10 raster lines
	RET
        
BAND	ENDP
	END

