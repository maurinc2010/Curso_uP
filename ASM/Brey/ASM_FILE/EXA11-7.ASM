;a program that creates CUST.FIL and then fills 5,000 records of
;256 bytes each with zeros.
;
	.MODEL SMALL
	.DATA
FILE1	DB	'CUST.FIL',0		;file name
BUF	DB	256 DUP (0)		;buffer
	.CODE
;        .STARTUP
	MOV	AH,3CH			;create CUST.FIL
	MOV	CX,0
	MOV	DX,OFFSET FILE1
	INT	21H
	MOV	BX,AX			;handle to BX        
	MOV	BP,5000			;record counter
MAIN1:
	MOV	AH,40H			;write record
	MOV	CX,256
	MOV	DX,OFFSET BUF
	INT	21H
	DEC	BP			;decrement record count
	JNZ	MAIN1			;if 5000 records have not been written
        
	MOV	AH,3EH			;close file
	INT	21H
;        .EXIT
	END




