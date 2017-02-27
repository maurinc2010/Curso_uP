;a program that uses a macro to read 2 keys from the keyboard
;and echo them to the display.  The first key code is stored at 
;VAR5 and the second at VAR6.
;
	.MODEL SMALL		;select SMALL model
	.DATA			;indicate start of DATA segment
VAR5	DB	0		;define VAR5
VAR6	DB	0		;define VAR6
	.CODE			;indicate start of CODE segment
        
READ	MACRO	A		;;reads keyboard with echo 
	LOCAL	READ1		;;define READ1 as local
                                        
	PUSH	DX   
READ1:
	MOV	AH,6		;;read key
	MOV	DL,0FFH
	INT	21H
	JE	READ1
	MOV	A,AL		;;save key code
	MOV	DL,AL		;;echo key
	INT	21H
	POP	DX
        
	ENDM
	.STARTUP		;start of program
                                        
	READ	VAR5		;read key and store it at VAR5
	READ	VAR6		;read key and store it at VAR6
        
	.EXIT			;exit to DOS
	END			;end of file
