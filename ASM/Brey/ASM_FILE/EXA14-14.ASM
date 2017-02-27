;a program that uses DPMI (provided by WINDOWS) to access
;protected mode operation and display a message from 
;protected mode.
;
	.MODEL SMALL
	.386
	.STACK 1024		;make stack 1,024 bytes
	.DATA
ENTRY	DD	?		;DPMI entry point
MSIZE	DW	?		;memory needed for DPMI
ERR1	DB	13,10,10,'DPMI not present.$'
ERR2	DB	13,10,10,'Not enough real memory.$'
ERR3	DB	13,10,10,'Could not move to protected mode.$'
MES1	DB	13,10,10,'I am displayed from protected mode.$'
;
;register array storage for DPMI function 0300H
;
ARRAY	EQU	THIS BYTE
REDI	DD	0		;EDI
RESI	DD	0		;ESI
REBP	DD	0		;EBP
	DD	0		;reserved
REBX	DD	0		;EBX
REDX	DD	0		;EDX
RECX	DD	0		;ECX
REAX	DD	0		;EAX
RFLAG	DW	0		;flags
RES	DW	0		;ES
RDS	DW	0		;DS
RFS	DW	0		;FS
RGS	DW	0		;GS
RIP	DW	0		;IP
RCS	DW	0		;CS
RSP	DW	0		;SP
RSS	DW	0		;SS
	.CODE
	.STARTUP
	MOV	AX,ES
	MOV	BX,DS		;find size of program and data	
	SUB	BX,AX
	MOV	AX,SP		;find stack length
	SHR	AX,4
	INC	AX
	ADD	BX,AX		;BX = length in paragraphs
	MOV	AH,4AH
	INT	21H		;modify memory allocation

	CALL	ISDPMI		;is DPMI loaded?
	JC	MAIN1		;if DPMI present
	MOV	AH,9
	MOV	DX,OFFSET ERR1
	INT	21H		;display DPMI not present
	JMP	MAIN4		;end
MAIN1:
	MOV	AX,0		;indicate 0 memory needed
	CMP	MSIZE,0
	JE	MAIN2		;if DPMI needs no memory
	MOV	BX,MSIZE	;get amount
	MOV	AH,48H
	INT	21H		;allocate memory for DPMI
	JNC	MAIN2		;if enough memory exists
	MOV	AH,9		;if not enough real memory
	MOV	DX,OFFSET ERR2
	INT	21H		;display not enough memory
	JMP	MAIN4		;end
MAIN2:
	MOV	ES,AX
	MOV	AX,0		;16-bit application
	CALL	ENTRY		;switch to protected mode
	JNC	MAIN3		;if in protected mode
	MOV	AH,9		;if switch failed
	MOV	DX,OFFSET ERR3
	INT	21H		;display switch failed
	JMP	MAIN4		;end
;
;PROTECTED MODE
;
MAIN3:
	MOV	SI,OFFSET MES1	;address MES1
MAIN3A:				;display MES1
	LODSB
	MOV	DL,AL
	CMP	AL,'$'		;test for end of string	
	JE	MAIN4		;if end of string
	MOV	AH,2		;display characters
	CALL	INT21H		;emulate INT 21H
	JMP	MAIN3A
MAIN4:
	.EXIT
;
;the ISDPMI procedure tests for the presence of the DPMI
;manager.  
;***return parameters***
;carry = 1; if DPMI is present
;carry = 0; if DPMI is not present
;                                       
ISDPMI	PROC	NEAR
                                                
	MOV	AX,1687H	;get DPMI status
	INT	2FH		;DOS multiplex
	OR 	AX,AX		;test AX
	JNZ	ISDPMI1		;if no DPMI
	MOV	MSIZE,SI	;save amount of memory needed
	MOV	WORD PTR ENTRY,DI
	MOV	WORD PTR ENTRY+2,ES
	STC
ISDPMI1:
	RET
        
ISDPMI	ENDP
;
;the INT21H procedure is required to emulate a DOS INT 21H
;function from protected mode operation.
;***entry parameters***
;AH = DOS INT 21H function number
;other registers as required by the function
;                                       
INT21H	PROC	NEAR
                                                
	MOV	REAX,EAX	;save registers
	MOV	REBX,EBX
	MOV	RECX,ECX
	MOV	REDX,EDX
	MOV	RESI,ESI
	MOV	REDI,EDI
	MOV	REBP,EBP
	PUSHF
	POP	AX
	MOV	RFLAG,AX
	PUSH	ES		;do DOS interrupt
	MOV	AX,0300H
	MOV	BX,21H
	MOV	CX,0
	PUSH	DS
	POP	ES
	MOV	DI,OFFSET ARRAY
	INT	31H
	POP	ES
	MOV	AX,RFLAG	;restore registers
	PUSH	AX
	POPF
	MOV	EDI,REDI
	MOV	ESI,RESI
	MOV	EBP,REBP
	MOV	EAX,REAX
	MOV	EBX,REBX
	MOV	ECX,RECX
	MOV	EDX,REDX
	RET
                                                
INT21H	ENDP
	END
