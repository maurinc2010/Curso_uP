;a program that display OK on the monitor screen
;using procedure DISP
;
	.MODEL TINY             ;select TINY model
	.CODE                   ;indicate start of CODE segment
	.STARTUP                ;indicate start of program
	
	MOV     BX,OFFSET DISP  ;address DISP with BX
	MOV     DL,'O'          ;display 'O'
	CALL    BX
	MOV     DL,'K'          ;display 'K'
	CALL    BX
	.EXIT                   ;exit to DOS
;
;a procedure that displays the ASCII contents of DL on the
;monitor screen.
;
DISP    PROC    NEAR
	
	MOV     AH,2            ;select function 02H
	INT     21H             ;execute DOS function
	RET                     ;return from procedure
	
DISP    ENDP
	
	END                     ;end of file
