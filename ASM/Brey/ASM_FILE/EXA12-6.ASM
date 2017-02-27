;a TSR program that locks the keyboard when an ALT + L key 
;is typed.  To unlock the keyboard, type ESC followed by the
;password, in this case SESAME.
;***uses the 80386 or newer microprocessor***
;
	.MODEL TINY
	.386
        .STACK
	.CODE
      ; .STARTUP
	JMP	INSTALL		;install VEC8 and VEC9
LOCKS	DB	0		;lock flag
ADD8	DD	?		;old vector 8 address
ADD9	DD	?		;old vector 9 address
KEY	DB	26H		;for L hot key scan code
BMASK	DB	8		;alternate key mask
AKEY	DB	8		;alternate key
PASS	DB	'SESAME',0	;password
FLAG8	DB	0		;busy flag for vector 8
                                                
VEC8	PROC	FAR		;clock tick handler
                                                
	CMP	CS:FLAG8,0
	JNE	VEC81		;if busy
	CMP	CS:LOCKS,0
	JNE	VEC82		;if locked
VEC81:
	JMP	CS:ADD8		;do old INT 8
VEC82:
	MOV	CS:FLAG8,1	;show busy
	PUSHF			;force old INT 8
	CALL	CS:ADD8
	STI			;enable interrupts
	PUSHA			;save registers
	PUSH	ES
	MOV	AX,CS
	MOV	ES,AX		;address this segment
	CLD
VEC83:
	MOV	DI,OFFSET PASS	;address password
VEC84:
	MOV	AH,10H
	INT	16H		;read key
	CMP	AL,1BH		;escape key resets
	JE	VEC83
	SCASB			;compare
	JNE	VEC85		;if wrong do nothing
	CMP	BYTE PTR ES:[DI],0
	JE	VEC86		;if correct
	JMP	VEC84		;get next
VEC85:
	MOV	AH,10H
	INT	16H		;read key
	CMP	AL,1BH
	JE	VEC83		;exit on escape
	JMP	VEC85
VEC86:	
	POP	ES		;restore registers
	POPA
	MOV	CS:LOCKS,0	;unlock keyboard
	MOV	CS:FLAG8,0	;show not busy
	CLI
	IRET
                                                
VEC8	ENDP
                                                
VEC9	PROC	FAR		;keyboard handler
                                                
	PUSH	AX
	STI			;enable interrupts
	CMP	CS:LOCKS,0
	JNE	VEC91		;if locked
	IN	AL,60H		;get scan code
	CMP	AL,CS:KEY	;test for L
	JNE	VEC91		;not an L
	PUSH	ES
	SUB	AX,AX
	MOV	ES,AX		;address segment 0000
	MOV	AL,ES:[417H]
	AND	AL,CS:BMASK	;mask alternate
	CMP	AL,CS:AKEY
	POP	ES
	JE	VEC92		;if an ALT + L
VEC91:
	POP	AX
	JMP	CS:ADD9		;do normal keyboard interrupt
VEC92:
	CLI			;interrupts off
	IN	AL,61H		;throw away ALT + L key away
	OR	AL,80H
	OUT	61H,AL
	AND	AL,7FH
	OUT	61H,AL
	MOV	AL,20H		;reset keyboard interrupt
	OUT	20H,AL
	STI			;enable interrupts
	MOV	CS:LOCKS,1	;lock keyboard
	POP	AX
	IRET
        
VEC9	ENDP
                                                
INSTALL:			;install VEC8 and VEC 9
	MOV	AX,CS		;load DS
	MOV	DS,AX

	MOV	AX,3508H	;get current vector 8
	INT	21H
	MOV	WORD PTR ADD8,BX
	MOV	WORD PTR ADD8+2,ES
        
	MOV	AX,3509H	;get current vector 9
	INT	21H
	MOV	WORD PTR ADD9,BX
	MOV	WORD PTR ADD9+2,ES
                                                
	MOV	AX,2508H	;install new interrupt 8
	MOV	DX,OFFSET VEC8
	INT	21H
                                                
	MOV	AX,2509H	;install new interrupt 9
	MOV	DX,OFFSET VEC9
	INT	21H
                                                
	MOV	DX,OFFSET INSTALL
	SHR	DX,4		;find paragraphs
	INC	DX
                                                
	MOV	AX,3100H	;install as TSR
	INT	21H
	END

