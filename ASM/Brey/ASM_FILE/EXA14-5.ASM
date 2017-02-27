;a program that accesses expanded memory and stores a logic 00H into
;512K bytes.  Although not practical, this program does illustrate
;how expanded memory is allocated, accessed and deallocated.
;
	.MODEL SMALL
	.386
	.DATA
HAN	DW 	?		;EMM handle
PAGES	DW	?		;logical page number
EMM	DB	'EMMXXXX0',0	;EMM driver name
ERR1	DB	13,10,10,'EMM driver error.$'
	.CODE
	.STARTUP
	CALL	ISEMS		;see if EMS driver present
	JNC	MAIN1		;if EMM driver present
ERR:
	MOV	AH,9
	MOV	DX,OFFSET ERR1	;display no EMM driver
	INT	21H
	JMP	MAIN3		;end it
MAIN1:
	MOV	AH,43H		;allocate 32 pages
	MOV	BX,32		;or 512K bytes
	INT	67H
	CMP	AH,0		;test for error
	JNZ	ERR		;if error
	MOV	HAN,DX		;save handle
        
	MOV	PAGES,0		;address of first page
	MOV	BP,32		;page counter
	MOV	AH,41H		;get page frame address
	INT	67H
	CMP	AH,0
	JNE	ERR		;if error
	MOV	ES,BX		;load ES
MAIN2:	
	MOV	AH,44H		;select page
	MOV	AL,0		;page 0 in frame
	MOV	BX,PAGES	;first page in frame
	MOV	DX,HAN		;load handle
	INT	67H
	CMP	AH,0
	JNE	ERR		;if error
        
	MOV	CX,4000H	;fill a page with 00H
	MOV	AL,0
	MOV	DI,0
	REP	STOSB
        
	INC	PAGES		;get next page
	DEC	BP
	JNZ	MAIN2		;do 32 times for 32 pages
                                                
	MOV	AH,45H
	MOV	DX,HAN
	INT	67H		;release memory
	CMP	AH,0
	JNE	ERR
MAIN3:
	.EXIT
;
;the ISEMS procedure tests for the presence of an EMS manager.
;***return parameter***
;if carry = 1, no EMS manager is present
;if carry = 0, EMS manager is present
;                                       
ISEMS	PROC	NEAR
                                                
	MOV	AX,3D00H
	MOV	DX,OFFSET EMM
	INT	21H		;open file
	JC	ISEMS1		;if not there
	MOV	BX,AX		;save handle
	MOV	AX,4407H	;access IOCTL function 7
	INT	21H
	JC	ISEMS1		;if error
	CMP	AL,-1
	JE	ISEMS1		;if present
	STC
ISEMS1:
	PUSHF			;save carry
	MOV	AH,3EH		;close file
	INT	21H
	POPF
	RET

ISEMS	ENDP
	END
