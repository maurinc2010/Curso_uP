	.MODEL SMALL		;select SMALL model
	.DATA			;start DATA segment
MES	DB	13,10,10,'This is a test line.$'
	.CODE			;start CODE segment
	.STARTUP		;start program
        
	MOV	AH,9		;select function 09H
	MOV	DX,OFFSET MES	;address character string
	INT	21H		;access DOS
        
	.EXIT			;exit to DOS
	END			;end of file


