;a program that display a carriage return and a line feed
;using the DISP macro
;
	.MODEL TINY		;select TINY model
	.CODE			;start CODE segment
DISP	MACRO	A		;;display A macro
                                        
	MOV	AH,06H		;;DOS function 06H
	MOV	DL,A		;;place parameter A in DL
	INT	21H		;;display parameter A
        
	ENDM
                   
	.STARTUP		;start program
                                        
	DISP	0DH		;display carriage return
	DISP	0AH		;display line feed

	.EXIT			;exit to DOS
	END			;end of file
