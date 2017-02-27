;a program that clears the screen and homes the
;cursor to the upper lefthand corner of the screen.
;
	.MODEL TINY		;select TINY model
	.CODE			;start CODE segment
HOME	MACRO			;;home cursor macro
	MOV	AH,2		;;function 02H
	MOV	BH,0		;;page 0
	MOV	DX,0		;;row 0, line 0
	INT	10H		;;home cursor
	ENDM
        
	.STARTUP		;start program
	HOME			;home cursor
	MOV	CX,25*80	;load character count
	MOV	AH,6		;select function 06H
	MOV	DL,' '		;select a space
MAIN1:
	INT	21H		;display a space
	LOOP	MAIN1		;repeat 2000 times
	HOME			;home cursor
	.EXIT			;exit to DOS
	END			;end of file
