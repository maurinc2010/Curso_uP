;a program that displays AB followed by a carriage return
;and line feed combination using the DISP macro
;
	.MODEL TINY		;select TINY model
	.CODE			;start CODE segment
DISP	MACRO	VAR		;;display VAR macro
	MOV	DL,VAR
	MOV	AH,6
	INT	21H
	ENDM
	.STARTUP		;start program
        
	DISP	'A'		;display 'A'
                       
	MOV	AL,'B'		;load AL with 'B'
	DISP	AL		;display 'B'

	DISP	13		;display carriage return

	DISP	10		;display line feed
 
	.EXIT			;exit to DOS
	END			;end of file
