;a program that clears the screen and homes the cursor
;
	.MODEL TINY		;select TINY model
	.CODE			;start code segment
HOME	MACRO			;;home cursor
	MOV	AH,2
	MOV	BH,0
	MOV	DX,0
	INT	10H
	ENDM
        
	.STARTUP		;start program
        
	MOV	BH,0
	MOV	AH,8
	INT	10H		;read video attribute
        
	MOV	BL,BH		;load page number	
	MOV	BH,AH
	MOV	CX,0		;load attributes
	MOV	DX,194FH	;line 25, column 79 
	MOV	AX,600H		;select scroll function
	INT	10H		;scroll screen
        
	HOME			;home cursor
        
	.EXIT			;exit to DOS
	END			;end program
