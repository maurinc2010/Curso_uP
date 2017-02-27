;program that uses a CALL lookup table to access one of three
;different procedures: ONE, TWO, or THREE.
;
	.MODEL SMALL		;select SMALL model
	.DATA			;indicate start of DATA segment
TABLE	DW	ONE		;define lookup table
	DW	TWO
	DW	THREE
	.CODE			;indicate start of CODE segment
 
ONE	PROC	NEAR
        
	MOV	AH,2		;display a letter A
	MOV	DL,'A'
	INT	21H
	RET
        
ONE	ENDP
        
TWO	PROC	NEAR
        
	MOV	AH,2		;display letter B
	MOV	DL,'B'
	INT	21H
	RET
        
TWO	ENDP
        
THREE	PROC	NEAR
        
	MOV	AH,2		;display letter C
	MOV	DL,'C'
	INT	21H
	RET
        
THREE	ENDP
	.STARTUP        
TOP:
	MOV	AH,1		;read key into AL
	INT	21H
        
	SUB	AL,31H		;convert from ASCII to 0, 1, or 2
	JB	TOP		;if below 0
	CMP	AL,2
	JA	TOP		;if above 2
        
	MOV	AH,0		;form lookup address
	MOV	BX,AX
	ADD	BX,BX
	CALL	TABLE [BX]	;call procedure ONE, TWO, or THREE
        
	.EXIT			;exit to DOS
	END			;end of file
