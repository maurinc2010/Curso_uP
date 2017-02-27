;a TSR program that counts keystrokes and reports the time of 
;installation and number of accumulated keystrokes whenever
;the ALT-K key combination is activated.
;***requires an 80386 or newer microprocessor***
;
	.MODEL TINY
	.386
	.CODE
	.STARTUP
	JMP	INSTALL		;install VEC8 and VEC9
                                                
HFLAG	DB	0		;Hot-key detected
ADD8	DD	?		;old vector 8 address
ADD9	DD	?		;old vector 9 address
COUNT	DD	0		;Keystroke counter
HOUR	DB	?		;start-up time
MIN	DB	?
SFLAG	DB	0		;start-up flag
FLAG8	DB	0		;interrupt 8 busy
KEY	DB	25H		;scan code for K
HMASK	DB	8		;alternate key mask
MKEY	DB	8		;alternate key
SCRN	DB	160 DUP (?)	;screen buffer
MES1	DB	'Time = '
MES2	DB	'   KeyStrokes = '
        
VEC9	PROC	FAR		;keyboard intercept
        
	STI			;enable interrupts
	PUSH	EAX		;save EAX
	IN	AL,60H		;get scan code
	CMP	AL,CS:KEY	;test for K
	JNE	VEC91		;no hot-key
	MOV	AX,0		;address segment 0000
	PUSH	DS		;save DS
	MOV	DS,AX
	MOV	AL,DS:[417H]	;get shift/alternate data
	POP	DS
	AND	AL,CS:HMASK	;isolate alternate key
	CMP	AL,CS:MKEY	;test for alternate key
	JE	VEC93		;if hot-key found
VEC91:
	PUSH	CX		;add one to BCD COUNT
	MOV	CX,3
	MOV	EAX,CS:COUNT
	ADD	EAX,1
	DAA			;make result BCD
VEC92:
	PUSHF
	ROR	EAX,8
	POPF
	ADC	AL,0		;propagate carry
	DAA
	LOOP	VEC92
	ROR	EAX,8
	MOV	CS:COUNT,EAX
	POP	CX
	POP	EAX
	JMP	CS:ADD9		;do normal interrupt
VEC93:				;if hot-key pressed
	CLI			;interrupts off	
	IN	AL,61H		;clear keyboard and
	OR	AL,80H		;throw away hot key
	OUT	61H,AL
	AND	AL,7FH
	OUT	61H,AL
	MOV	AL,20H		;reset keyboard interrupt
	OUT	20H,AL
	STI			;enable interrupts
	MOV	CS:HFLAG,1	;indicate hot-key pressed
	POP	EAX
	IRET
        
VEC9	ENDP
                                                
VEC8	PROC	FAR		;clock tick interrupt procedure
                                                
	CMP	CS:FLAG8,0
	JZ	VEC81		;if not busy
	JMP	CS:ADD8		;if busy
VEC81:
	CMP	CS:HFLAG,0
	JNZ	VEC83		;if hot-key detected
	CMP	CS:SFLAG,0
	JZ	VEC82		;if start-up
	JMP	CS:ADD8		;if not hot-key or start-up
VEC82:
	PUSHF			;do old interrupt 8
	CALL	CS:ADD8
	MOV	CS:FLAG8,1	;indicate busy
	STI			;enable interrupts
	PUSH	AX
	PUSH	CX
	PUSH	DX
	MOV	AH,2		;get start-up time
	INT	1AH
	MOV	CS:HOUR,CH	;save hour
	MOV	CS:MIN,CL	;save minute
	POP	DX		;restore registers
	POP	CX
	POP	AX
	MOV	CS:SFLAG,1	;indicate started
	JMP	VEC89		;end it
VEC83:				;do hot-key display
	PUSHF			;do old interrupt 8
	CALL	CS:ADD8
	MOV	CS:FLAG8,1	;indicate busy
	STI			;enable interrupts
	PUSH	AX		;save registers
	PUSH	BX
	MOV	AH,0FH		;get video mode
	INT	10H
	CMP	AL,3
	JBE	VEC84		;if DOS text mode
	POP	BX		;ignore if graphics mode
	POP	AX
	JMP	VEC88
VEC84:				;for text mode
	PUSH	CX
	PUSH	EDX
	PUSH	DI
	PUSH	SI
	PUSH	DS
	PUSH	ES
	CLD
	MOV	AX,CS		;address this segment
	MOV	ES,AX
	MOV	AX,0B800H	;address text memory
	MOV	DS,AX
	MOV	CX,160		;save top screen line
	MOV	DI,OFFSET SCRN
	MOV	SI,0
	REP	MOVSB
	PUSH	DS		;swap segments
	PUSH	ES
	POP	DS
	POP	ES
	MOV	DI,80		;start display at center
	MOV	SI,OFFSET MES1
	MOV	AH,0FH		;load white on black
	MOV	CX,7
VEC85:
	LODSB			;display "Time = "
	STOSW
	LOOP	VEC85
	MOV	DL,CS:MIN
	MOV	DH,CS:HOUR
	SHL	EDX,16
	MOV	CX,2
	MOV	BL,30H
	CALL	DISP		;display hours	
	MOV	AL,':'
	STOSW			;display colon	
	MOV	CX,2
	MOV	BL,80H
	CALL	DISP		;display minutes
	MOV	SI,OFFSET MES2	;display "   KeyStrokes = "
	MOV	CX,16
VEC86:
	LODSB
	STOSW
	LOOP	VEC86
	MOV	EDX,CS:COUNT	;get count
	MOV	CX,8
	MOV	BL,30H
	CALL	DISP		;display count
VEC87:
	MOV	AH,1		;wait for any key (BIOS)
	INT	16H
	JZ	VEC87
	CLD
	MOV	SI,OFFSET SCRN	;restore text
	MOV	DI,0
	MOV	CX,160
	REP	MOVSB
	POP	ES
	POP	DS
	POP	SI
	POP	DI
	POP	EDX
	POP	CX
	POP	BX
	POP	AX
VEC88:
	MOV	CS:HFLAG,0	;kill hot_key
VEC89:
	MOV	CS:FLAG8,0	;indicate not busy
	IRET
                                                
VEC8	ENDP
;
;the DISP procedure displays the BCD contents of EDX.
;***input parameters***
;CX = number of digits
;BL = 30H for blank leading zeros or 80H for no blanking
;ES = segment address of text mode display
;DI = offset address of text mode display
;
DISP	PROC	NEAR		;display
        
	ROL	EDX,4		;position number
	MOV	AL,DL
	AND	AL,0FH
	ADD	AL,30H		;convert to ASCII
	STOSW			;store in text display
	CMP	AL,BL		;test for blanking
	JE	DISP1		;if blanking needed
	MOV	BL,80H		;turn off blanking
	JMP	DISP2		;continue
DISP1:
	SUB	DI,2		;blank digit
DISP2:
	LOOP	DISP
	RET
        
DISP	ENDP
                                                
INSTALL:			;install VEC8 and VEC9
                                                
	MOV	AX,CS		;load DS
	MOV	DS,AX
                                                
	MOV	AX,3508H	;get current vector 8
	INT	21H		;and save it
	MOV	WORD PTR ADD8,BX
	MOV	WORD PTR ADD8+2,ES
        
	MOV	AX,3509H	;get current vector 9
	INT	21H		;and save it
	MOV	WORD PTR ADD9,BX
	MOV	WORD PTR ADD9+2,ES
                                                
	MOV	AX,2508H
	MOV	DX,OFFSET VEC8	;address interrupt procedure
	INT	21H		;install vector 8
                                                
	MOV	AX,2509H
	MOV	DX,OFFSET VEC9	;address interrupt procedure
	INT	21H		;install vector 9
                                                
	MOV	DX,OFFSET INSTALL	;find paragraphs
	SHR	DX,4
	INC	DX
        
	MOV	AX,3100H	;set as a TSR
	INT	21H
	END
