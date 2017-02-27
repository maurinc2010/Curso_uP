;a program that read two lines of data from the keyboard
;using DOS INT 21H function number 0AH
;***uses***
;LINE procedure to read a line.
;
	.MODEL SMALL		;select SMALL model
	.DATA			;start DATA segment
BUF1	DB	257 DUP (?)	;define BUF1
BUF2	DB	257 DUP (?)	;define BUF2
	.CODE			;start CODE segment
	.STARTUP		;start program
	MOV	BUF1,255	;character count of 255
	MOV	DX,OFFSET BUF1	;address BUF1
	CALL	LINE		;read a line
        
	MOV	BUF2,255	;character count of 255
	MOV	DX,OFFSET BUF2	;address BUF2
	CALL	LINE		;read a line
	.EXIT			;exit to DOS
;
;the LINE procedure uses DOS INT 21H function 0AH to read
;and echo an entire line from the keyboard.
;***parameters***
;DX must contains the data segment offset address of the buffer
;the first location in the buffer contains the number of characters
;to be read for the line.
;upon return the second location in the buffer contains the line length.
;
LINE	PROC	NEAR
        
	MOV	AH,0AH		;select function 0AH
	INT	21H		;access DOS
	RET			;return from procedure
        
LINE	ENDP
	END			;end of file
