	.MODEL TINY
	.CODE
	.STARTUP

        CLD			;select increment mode
        MOV	AX,0B800H	;address segment B800
        MOV	ES,AX
        
        MOV	DI,0		;address offset 0000
        MOV	CX,25*80	;load count
        MOV	AX,0720H	;load data
        
        REP	STOSW		;clear the screen

	.EXIT			;exit to DOS
        END			;end of file



