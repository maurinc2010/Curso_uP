;a device driver called DUMP that allows hexadecimal data
;to be displayed from the DOS pipe or by using the DOS 
;COPY command.  This file must be loaded as a DEVICE in the
;CONFIG.SYS file.
	.MODEL TINY
	.386
	.CODE
;HEADER
;
CHAIN	DD	-1		;link to next driver in chain
ATTR	DW	0A800H		;driver attribute
STRT	DW	STRAT		;address of strategy
INTR	DW	INTT 		;address of interrupt
DNAME	DB	'DUMP    '	;driver name
REQ	DD	?		;request header address
CT	DW	C0,CZ,CZ,CZ,CZ,C5,CZ,CZ  ;command lookup table
	DW	C8,CZ,CZ,CZ,CZ,CD,CZ,CZ
	DW	C8,CU,CU,CZ,CU,CU,CU
	DW	CZ,CZ,CZ
COUNT	DW	?		;transfer counter
ADDR1	DD	?		;address
LINES	DB	?		;line counter
ANY  	DB	'Press any key to continue ...',0
;STRATEGY
;
STRAT	PROC	FAR		;strategy procedure (must be FAR)
        
	MOV	WORD PTR CS:REQ,BX   ;save request header address
	MOV	WORD PTR CS:REQ+2,ES
	RET
        
STRAT	ENDP
;
;INTERRUPT procedure processes commands
;
INTT PROC FAR			;interrupt procedure (must be FAR)

	PUSHF			;save all registers
	PUSHAD
	PUSH	DS
	PUSH	ES
	MOV	AX,CS
	MOV	DS,AX		;load DS

	MOV	SI,WORD PTR REQ	;get request header address
	MOV	ES,WORD PTR REQ+2
        
	MOV	AL,ES:[SI+2]	;get command
	CMP	AL,19H		;check range
	JBE	INTT1		;if possible command
	MOV	AX,9003H	;get bad command code
	JMP	INTT_END	;end program
INTT1:
	MOV	AH,0
	ADD	AX,AX;double code
	ADD	AX,OFFSET CT	;address command table
	MOV	DI,AX
	MOV	AX,[DI]		;get address from table
	CALL	AX		;call command
INTT_END:
	MOV	ES:[SI+3],AX	;save return status word
	POP	ES		;restore registers
	POP	DS
	POPAD
	POPF
	RET
        
INTT ENDP
;
;the DISP procedure displays the null character string
;stored at the location addressed by DS:SI.
;
DISP	PROC	NEAR 
        
	MOV	BH,0		;select video page 0
DISP1:
	LODSB			;get byte
	OR	AL,AL		;test for null (0)
	JZ	DISP2		;if null
	MOV	AH,0EH		;display AL
	INT	10H		;call BIOS display function
	JMP	DISP1		;repeat until null
DISP2:
	RET
        
DISP	ENDP
;
;process any unknown command
;
CU	PROC	NEAR
        
	MOV	AX,9003H	;indicate error
	RET

CU	ENDP
;
;process an unimplemented command
;
CZ	PROC	NEAR 
        
	MOV	AX,100H		;indicate not implemented
	RET
        
CZ	ENDP
;
;process the nondestructive read command
;
C5	PROC	NEAR		;nondestructive read
        
	MOV	AX,300H
	RET
        
C5	ENDP
;
;process the write command
;
;this command displays hexadecimal data on the video display.
;
C8	PROC	NEAR		;write command (08H)
        
	PUSH	ES		;save data segment
	PUSH	SI		;save request header offset
	MOV	AX,ES:[SI+0EH]	;get buffer address
	MOV	BX,ES:[SI+10H]
	MOV	CX,ES:[SI+12H]	;get transfer count
	MOV	COUNT,CX
	JCXZ	C8E		;if no data to transfer
	MOV	ES,BX
	MOV	SI,AX
C81:
	PUSH	CX		;save count
	CALL	HADDR		;display address
	CALL	HBYTE		;display byte
	POP	CX		;get count
	LOOP	C81		;repeat until count = 0
C8E:				;finish write
	POP	SI		;restore registers
	POP	ES
	MOV	CX,COUNT	;save transfer count
	MOV	ES:[SI+12H],CX
	MOV	AX,100H
	RET
        
C8	ENDP
;
;the HADDR procedure displays the contents of ADDR1 as a
;hexadecimal address whenever it represents a paragraph
;boundary.  Otherwise, a return occurs without displaying
;any address.
;
HADDR	PROC	NEAR		;display address
        
	MOV	EAX,ADDR1	;get address
	TEST	AL,0FH		;test for paragraph
	JNZ	HADDR4		;if not XXXXXXX0
	DEC	LINES		;decrement line counter
	JNZ	HADDR1		;if not last line of screen
	PUSH	EAX
	PUSH	SI
	MOV	DX,1800H
	MOV	BH,0
	MOV	AH,2
	INT	10H		;cursor to bottom line
	MOV	SI,OFFSET ANY
	CALL	DISP		;display "type any key"
	POP	SI
	MOV	AH,0
	INT	16H		;read any key
	CALL	CLS		;clear screen and home cursor
	POP	EAX
	JMP	HADDR2
HADDR1:
	PUSH	EAX
	MOV	AX,0E0DH
	INT	10H		;display carriage return
	MOV	AX,0E0AH
	INT	10H		;display line feed
	POP	EAX
HADDR2:
	MOV	CX,8		;set count for 8 digit address
HADDR3:
	ROL	EAX,4		;position digit
	PUSH	EAX
	CALL	DIP		;display one hex digit
	POP	EAX
	LOOP	HADDR3		;eight times
	MOV	AX,0E3AH
	INT	10H		;display colon
	MOV	AX,0E20H
	INT	10H		;display space
HADDR4:
	RET
        
HADDR	ENDP
;
;the DIP procedure displays a single hexadecimal digit
;from the AL register bit 3 through bit 0.
;
DIP	PROC	NEAR
        
	AND	AL,0FH		;get digit
	ADD	AL,30H		;make it ASCII
	.IF  AL > 39H
		ADD	AL,7	;if A through F
	.ENDIF
	MOV	AH,0EH
	INT	10H		;display digit
	RET

DIP	ENDP
;
;the HBYTE procedure displays the contents of ES:SI as a
;2-digit hexadecimal number.
;
HBYTE	PROC	NEAR
        
	MOV	AL,ES:[SI]	;get byte
	INC	SI		;address next byte
	PUSH	AX
	ROL	AL,4
	CALL	DIP		;display first digit
	POP	AX
	CALL	DIP		;display second digit
	MOV	AX,0E20H
	INT	10H		;display space
	INC	ADDR1		;increment address
	RET
        
HBYTE	ENDP
;
;the CLS procedure clears the screen and homes the cursor
;
CLS	PROC	NEAR
        
	PUSH	CX
	MOV	AX,600H		;clear screen
	MOV	BH,7
	MOV	CX,0
	MOV	DH,24
	MOV	DL,79
	INT	10H
	MOV	DX,0		;home cursor
	MOV	BH,0
	MOV	AH,2	
	INT	10H
	POP	CX
	MOV	LINES,23	;reset line counter
	RET
        
CLS	ENDP
;
;process the open device command
;
CD	PROC	NEAR		;open device (0DH)
        
	CALL	CLS		;clear screen
        
	MOV	ADDR1,0		;set address to 00000000	
	MOV	AX,100H		;show done
	RET

CD	ENDP
;
;process the initialize driver command
;
C0	PROC	NEAR		;initialize driver
        
	PUSH	SI		;save request header address
	MOV	SI,OFFSET HELLO
	CALL	DISP		;display hello
	POP	SI
				;save end address
	MOV	ES:[SI+0EH],OFFSET C0
	MOV	ES:[SI+10H],CS
	MOV	AX,100H
	RET
        
C0	ENDP
        
HELLO	DB	13,10,10,'...initializing hexadecimal DUMP',13,10,0

	END
