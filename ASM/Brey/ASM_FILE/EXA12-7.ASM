;a TSR program that displays the time in the upper right corner 
;of any text mode display.
;Installation is accomplished by typing the program name.
;Removal is accomplished by typing the program name followed by /R.
;***uses the 80386 or newer microprocessor***
;
	.MODEL TINY
	.386
	.CODE
	.STARTUP
	JMP	START		;start installation/removal
                                                
BUSY	DB	0		;busy flag
ADD8	DD	?		;old address of vector 8
ADD9	DD	?		;old address of vector 9
ADD2F	DD	?		;old address of vector 2F
ADD15	DD	?		;old address of vector 15
ID_L	DW	12		;TSR ID string length
PSPAD	DW	?		;PSP address for TSR
VECS	DW	VEC8,VEC9,VEC2F,VEC15
LIST	DB	8,9,2FH,15H
HFLAG	DB	0		;hot-key flag
HKEY	DB	2EH		;hot-key scan code for C
HMASK	DB	0AH		;hot mask alternate/left shift
HCODE	DB	0AH		;hot code alternate/left shift
VIDBUF	DB	16 DUP (?)
PSFLAG	DB	0		;PS/2 flag
ID_N 	DB	?		;TSR ID number
ID_S	DB	'POP-UP CLOCK'	;TSR ID string
ABORT	DB	13,10,'Already Installed or Cannot Install.',13,10,'$'
NOTS	DB	13,10,'TSR not Installed.',13,10,'$'
        
VEC8	PROC	FAR		;clock tick interrupt
                                                
	CMP	CS:BUSY,0	;check for busy
	JNE	VEC81		;if busy
	CMP	CS:HFLAG,0	;check for hot-key
	JNE	VEC82		;if hot-key active
VEC81:
	JMP	CS:ADD8		;do old interrupt
VEC82:
	STI			;enable interrupts
	PUSHF			;simulate an interrupt
	CALL	CS:ADD8
	MOV	CS:BUSY,1	;indicate busy
	PUSHA			;save registers
	PUSH	DS
	PUSH	ES
	MOV	AX,CS		;address video buffer
	MOV	ES,AX
	MOV	DI,OFFSET VIDBUF
	MOV	AX,0B800H	;address video memory
	MOV	DS,AX
	MOV	SI,2*72		;address column 72
	MOV	CX,16		;load count
	REP	MOVSB		;copy from video memory
	PUSH	DS		;exchange segments
	PUSH	ES
	POP	DS
	POP	ES
	MOV	DI,2*72		;address video memory
	MOV	AH,02H		;get time from BIOS
	INT	1AH
	MOV	AH,0FH		;set video attribute
	MOV	AL,CH		;display hours
	CALL	DISP
	MOV	AL,':'		;display colon
	STOSW
	MOV	AL,CL		;display minutes
	CALL	DISP
VEC83:
	MOV	AH,11H		;test keyboard
	INT	16H
	JE	VEC83		;wait for any key
	MOV	AH,10H		;dump keystroke
	INT	16H
	MOV	DI,2*72		;restore video
	MOV	SI,OFFSET VIDBUF
	MOV	CX,16
	REP	MOVSB
	POP	ES		;restore register
	POP	DS
	POPA
	MOV	CS:HFLAG,0	;clear hot-key
	MOV	CS:BUSY,0	;clear busy
	IRET
                                                
VEC8	ENDP
;the DISP procedure displays the BCD contents of AL on
;the text mode video display at the offset address DI.
;                                       
DISP	PROC	NEAR

	PUSH	AX
	SHR	AL,4
	AND	AL,0FH
	ADD	AL,30H		;mask ASCII
	STOSW
	POP	AX
	AND	AL,0FH
	ADD	AL,30H
	STOSW
	RET

DISP	ENDP

VEC9	PROC	FAR		;keyboard vector (PC/XT/AT)
                                                
	STI			;enable interrupts
	PUSH	AX
	IN	AL,60H		;get scan code
	CMP	AL,CS:HKEY	;test scan code
	JNE	VEC91		;if no hot-key
	PUSH	ES
	MOV	AX,0		;address segment 0000
	MOV	ES,AX
	MOV	AL,BYTE PTR ES:[417H]
	POP	ES
	AND	AL,CS:HMASK
	CMP	AL,CS:HCODE
	JNE	VEC91		;if no hot-key
	CLI			;disable interrupt
	IN	AL,61H	
	OR	AL,80H		;clear keyboard
	OUT	61H,AL
	AND	AL,7FH
	OUT	61H,AL
	MOV	AL,20H		;clear keyboard interrupt
	OUT	20H,AL
	STI			;enable interrupts
	MOV	CS:HFLAG,1	;signal hot-key	
	POP	AX
	IRET
VEC91:
	POP	AX
	JMP	CS:ADD9		;do normal keyboard interrupt
        
VEC9	ENDP
                                                
VEC15	PROC	FAR		;interrupt 15H for PS/2
                                                
	STI			;enable interrupt
	CMP	AH,4FH		;keyboard service?
	JNE	VEC151		;if not for keyboard
	PUSH	AX
	CMP	AL,CS:HKEY	;test hot-key code
	JNE	VEC151		;if not hot-key
	PUSH	ES
	MOV	AX,0
	MOV	ES,AX		;address segment 0000
	MOV	AL,BYTE PTR ES:[417H]
	POP	ES
	AND	AL,CS:HMASK
	CMP	AL,CS:HCODE
	JNE	VEC151		;if not hot-key
	POP	AX
	MOV	CS:HFLAG,1	;signal hot-key
	CLC			;signal BIOS no key
	RET	2    
VEC151:
	CLI			;disable interrupts
	JMP	CS:ADD15	;do old interrupt
                                                
VEC15 ENDP
;
;the DOS multiplex interrupt provides a way of passing
;parameters to the TSR.
;This handler accepts two commands AL = 0 and AL = 1.
;***input parameters***
;AH = TSR ID number
;AL = function number
;***functions provided***
;AL = 0; returns the address of the TSR ID in ES:DI                                     
;AL = 1; returns the address of the PSP in in ES:DI
;
VEC2F	PROC	FAR		;multiplex interrupt
                                                
	CMP	AH,CS:ID_N	;test this TSR ID number
	JE	VEC2F1		;if this ID	
	JMP	CS:ADD2F	;if not, do old interrupt
VEC2F1:
	CMP	AL,0		;function 0? (verify presence)
	JNE	VEC2F2		;if not function 0	
	MOV	AL,0FFH		;indicate ID good
	PUSH	CS
	POP	ES		;address this segment
	MOV	DI,OFFSET ID_S	;address TSR ID string
	JMP	VEC2F3
VEC2F2:
	CMP	AL,1		;function 1 (get PSP)
	JNE	VEC2F3
	MOV	ES,CS:PSPAD	;get PSP address
	MOV	DI,0		;clear DI
VEC2F3::			;make global for use in MULT
	IRET
        
VEC2F	ENDP
;
;the MULT procedure interrogates the multiplex interrupt
;to get an ID number and indicate whether or not POP-UP CLOCK
;is installed.
;***return codes***
;AX = 0; cannot install (no ID code available)
;AX = 1; POP-UP CLOCK is installed
;AX = 2; POP-UP CLOCK is not installed
;                                       
MULT	PROC	NEAR		;get ID and functions
                                                
	PUSH	AX
	MOV	AX,352FH	;test for DOS version 2.X
	INT	21H	
	MOV	AX,ES
	OR	AX,BX
	JNE	MULT1		;if vector loaded
	MOV	DX,OFFSET VEC2F3	;IRET vector address
	MOV	AX,252FH
	INT	21H
MULT1:
	MOV	DH,192		;initial test ID number
MULT2:
	MOV	AH,DH		;load test ID
	XOR	AL,AL		;set function 00H
	PUSH	DX
	PUSH	DS
	INT	2FH		;do multiplex interrupt
	POP	DS
	POP	DX
	OR	AL,AL
	JZ	MULT5		;if ID number available
	CMP	AL,0FFH
	JNE	MULT3		;if not ready
	MOV	SI,OFFSET ID_S	;check ID string
	MOV	CX,CS:ID_L
	REPE	CMPSB
	JE	MULT4		;if this TSR installed
MULT3:
	INC	DH
	JNZ	MULT2		;keep looking for free ID
	MOV	AX,0		;no ID available code
	JMP	MULT6		;end it
MULT4:
	MOV	AH,DH		;get ID number
	INT	2FH
	MOV	AX,1		;is installed code
	JMP	MULT6
MULT5:
	MOV	CS:ID_N,DH	;save ID number
	MOV	AX,2		;not installed
MULT6:
	POP	BX
	RET
                                                
MULT	ENDP
                                                
START:				;begin installation/deinstallation
	MOV	AX,CS
	MOV	DS,AX		;address data segment
	CLD
	CMP	BYTE PTR DS:[80H],3
	JNE	ST1
	CMP	BYTE PTR DS:[82H],'/'
	JE	ST6		;to deinstall
ST1:
	MOV	AL,0  
	CALL	MULT		;request multiplex interrupt 2F
	CMP	AX,2
	JNE	ST12		;if already installed
	MOV	PSFLAG,0	;indicate PC/XT/AT
	MOV	PSPAD,CS	;save PSP address
	MOV	AH,30H
	INT	21H		;check DOS version
	XCHG	AL,AH
	CMP	AX,031EH
	JB	ST2		;if DOS version below 3.3
	MOV	AX,0C00H	;test for PS/2
	INT	15H
	STI			;enable interrupts
	JZ	ST2		;if not PS/2
	OR 	AH,AH
	JNZ	ST2		;if not PS/2
	TEST	BYTE PTR ES:[BX+5],10H
	JZ	ST2		;if not PS/2
	MOV	PSFLAG,1	;if PS/2
ST2:
	MOV	CX,4
	MOV	DI,OFFSET ADD8
	MOV	SI,OFFSET LIST
ST3:
	MOV	AH,35H		;get and save vectors
	LODSB
	INT	21H
	MOV	[DI],BX
	MOV	[DI+2],ES
	ADD	DI,4
	LOOP	 ST3
	MOV	CX,3
	MOV	DI,OFFSET VECS	;load new vectors
	MOV	SI,OFFSET LIST
ST4:
	MOV	DX,[DI]
	MOV	AH,25H
	LODSB
	INT	21H
	ADD	DI,2
	LOOP	ST4
	CMP	PSFLAG,1
	JNE	ST5
	MOV	AX,2515H
	MOV	DX,OFFSET VEC15
	INT	21H
ST5:
	MOV	DX,OFFSET MULT
	SHR	DX,4
	INC	DX
	MOV	AX,3100H	;make resident
	INT	21H
ST6:
	AND	BYTE PTR DS:[83H],0DFH
	CMP	BYTE PTR DS:[83H],'R'
	JNE	ST12		;abort
	XOR	AL,AL
	CALL	MULT		;multiplex
	CMP	AX,1
	JE	ST7		;if installed
	MOV	AH,9
	MOV	DX,OFFSET NOTS
	INT	21H
	JMP	ST13		;exit to DOS
ST7:
	PUSH	ES
	POP	DS
	MOV	CX,3
	MOV	SI,OFFSET LIST
	MOV	DI,OFFSET VECS
ST8:
	MOV	AH,35H		;test vectors
	LODSB
	INT	21H
	CMP	BX,[DI]
	JNE	ST12		;if wrong vector
	MOV	AX,ES
	MOV	BX,DS
	CMP	AX,BX
	JNE	ST12		;if wrong vector
	ADD	DI,2
	LOOP	ST8
	CMP	PSFLAG,1
	JNE	ST9
	MOV	AH,35H
	LODSB
	INT	21H
	CMP	BX,[DI]
	JNE	ST12		;if wrong vector
	MOV	AX,ES
	MOV	BX,DS
	CMP	AX,BX
	JNE	ST12		;if wrong vector
ST9:
	MOV	AL,1
	CALL	MULT		;get PSP segment
	PUSH	ES
	MOV	CX,3
	MOV	SI,OFFSET LIST
	MOV	DI,OFFSET ADD8
ST10:
	LODSB
	MOV	AH,25H
	PUSH	DS
	LDS	DX,[DI]
	INT	21H
	POP	DS
	ADD	DI,4
	LOOP	ST10
	CMP	PSFLAG,1
	JNE	ST11		;if not PS/2
	LODSB
	MOV	AH,25H
	PUSH	DS
	LDS	DX,[DI]
	INT	21H
	POP	DS
ST11:
	POP	DS		;get PSP address
	MOV	AX,DS:[2CH]	;release environment
	MOV	ES,AX
	MOV	AH,49H
	INT	21H
	JC	ST12		;if error
	PUSH	DS
	POP	ES
	MOV	AH,49H
	INT	21H		;release TSR memory
	JNC	ST13		;if no error, exit to DOS
ST12:
	MOV	AX,CS
	MOV	DS,AX
	MOV	AH,9		;indicate already installed
	MOV	DX,OFFSET ABORT
	INT	21H
ST13:
	.EXIT
	END
