;a program that tests for an IOTCL device and lists its
;status information. 
	.MODEL SMALL
	.386
	.DATA
NTAB	DW	M0,M1,M2,M3,M4,M5,M6
DEV	DB	'LPT1',0		;name for LPT1
M0	DB	'Standard input device.'
CRLF	DB	13,10,'$'
M1	DB	'Standard output device.',13,10,'$'
M2	DB	'NUL device.',13,10,'$'
M3	DB	'Clock device.',13,10,'$'
M4	DB	'Supports INT 28H.',13,10,'$'
M5	DB	'Binary device.',13,10,'$'
M6	DB	'Does not signal EOF.',13,10,'$'
ME	DB	'IOCTL functions 02H and 03H supported.',13,10,'$'
ERR1	DB	13,10,'ERROR$'
	.CODE
	.STARTUP
	MOV	AX,3D02H		;open device
	MOV	DX,OFFSET DEV
	INT	21H
	JC	ERR			;if not found
	MOV	BX,AX			;save handle in BX
	MOV	AX,4400H		;get IOCTL status
	INT	21H
	JC	ERR			;if error
	TEST	DL,80H			;is it a file?
	JZ	ERR			;if file
	PUSH	DX			;save status
	MOV	AH,9
	MOV	DX,OFFSET CRLF		;get new line
	POP	DX			;get status
	PUSH	DX
	MOV	SI,OFFSET NTAB		;address message table
	MOV	CX,7			;load count
MAIN1:
	SHR	DL,1			;test feature
	JC	MAIN3			;display message if 1
MAIN2:
	ADD	SI,2			;address next message
	LOOP	MAIN1			;keep checking 7 bits
	POP	DX
	TEST	DH,40H			;test bit position 14
	JZ 	MAIN4
	MOV	AH,9
	MOV	DX,OFFSET ME
	INT	21H
	JMP	MAIN4			;if done
MAIN3:
	PUSH	DX
	MOV	AH,9
	MOV	DX,[SI]
	INT	21H			;display message
	POP	DX
	JMP	MAIN2			;repeat
ERR:					;if error
	MOV	AH,9			;display ERROR
	MOV	DX,OFFSET ERR1
	INT	21H
MAIN4:
	.EXIT
	END
