	.MODEL TINY             ;select TINY model
	.CODE                   ;indicate start of CODE segment
	.STARTUP                ;indicate start of program
	CLD                     ;select increment
	MOV     AX,0B800H       ;load ES and DS with B800
	MOV     ES,AX
	MOV     DS,AX
	
	MOV     SI,160          ;address line 1
	MOV     DI,0            ;address line 0
	MOV     CX,24*80        ;load count
	REP     MOVSW           ;scroll screen
	
	MOV     DI,24*80*2      ;clear bottom line
	MOV     CX,80
	MOV     AX,0720H
	REP     STOSW
	.EXIT                   ;exit to DOS
	END                     ;end of file
