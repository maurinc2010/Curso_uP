;a terminate and stay resident program that hooks into interrupt
;vector 8 to beep the speaker one time per half-hour and two 
;times per hour.
;***must be assembled as a .COM file***
;
	.MODEL TINY
	.CODE
	.STARTUP
	JMP	INSTALL		;install interrupt service procedure
TONE	EQU	1000		;set tone at 1000 Hz
COUNT	DB	0 		;elapsed time counter
ADD8	DD	?		;old vector address
PASS	DB	0		;1 or 2 beeps
BEEP	DB	0		;beep or silent
FLAG	DB	0		;busy flag

VEC8	PROC	FAR		;interrupt service procedure
                                                
	CMP	CS:FLAG,0	;test busy flag
	JE	VEC81		;if not busy
	JMP	CS:ADD8		;if busy do normal INT 8
VEC81:
	PUSHF			;do normal INT 8
	CALL	CS:ADD8
	MOV	CS:FLAG,1	;show busy
	STI			;allow other interrupts
	CMP	CS:PASS,0
	JNE	VEC83		;if beep counter active
	PUSH	AX		;save registers
	PUSH	CX
	PUSH	DX
	MOV	AH,2		;get time from BIOS
	INT	1AH
	CMP	DH,0		;is it 00 seconds
	JNE	VEC86		;not time yet, so return
	CMP	CL,0		;test for hour
	JE	VEC82		;if hour beep 2 times
	CMP	CL,30H		;test for half-hour
	JNE	VEC86		;if not half-hour
	CALL	BEEPS		;start speaker beep
	MOV	CS:PASS,1	;set number of beeps to 1
	JMP	VEC86		;end it
VEC82:
	CALL	BEEPS		;start speaker beep
	MOV	CS:PASS,2	;set number of beeps to 2
	JMP	VEC86		;end it
VEC83:
	CMP	CS:COUNT,0 	;test for end of delay
	JE	VEC84		;if time delay has elapsed
	DEC	CS:COUNT
	JMP	VEC88		;end it
VEC84:
	CMP	CS:BEEP,0	;test beep on
	JNE	VEC85		;if beep is on
	DEC	CS:PASS		;test for 2 beeps
	JZ	VEC88		;if second beep not needed end
	MOV	CS:COUNT,9	;reset count
	MOV	CS:BEEP,1	;beep on for second beep 
	PUSH	AX
	IN	AL,61H		;enable speaker for beep
	OR	AL,3
	OUT	61H,AL
	JMP	VEC87		;end it
VEC85:
	MOV	CS:COUNT,9	;reset count
	MOV	CS:BEEP,0	;show beep is off
	PUSH	AX
	IN	AL,61H		;disable speaker for beep off
	XOR	AL,3
	OUT	61H,AL
	JMP	VEC87		;end it
VEC86:
	POP	DX		;restore registers
	POP	CX
VEC87:
	POP	AX
VEC88:
	MOV	CS:FLAG,0	;show not busy
	IRET			;interrupt return
                                                
VEC8	ENDP
;
;the BEEPS procedure programs the speaker for the frequency stored
;as TONE using an equate at assembly time.  The duration of the 
;beep is 1/2 second.
;***uses registers AX, CX, and DX***
;                                                       
BEEPS	PROC	NEAR		;beep speaker for 1/2 second

	MOV	CX,CS:TONE	;set tone
	MOV	AX,34DCH	;load AX with 1,193,180
	MOV	DX,12H
	DIV	CX		;calculate count
	OUT	42H,AL		;program timer 2 with count
	MOV	AL,AH
	OUT	42H,AL
        
	IN	AL,61H		;speaker on
	OR	AL,3
	OUT	61H,AL
	MOV	CS:COUNT,9	;set count for 1/2 second
	MOV	CS:BEEP,1	;indicate beep is on
	RET

BEEPS	ENDP
        
INSTALL:			;install interrupt procedure VEC8
	MOV	AX,CS		;overlap CS and DS
	MOV	DS,AX

	MOV	AX,3508H	;get current vector 8
	INT	21H		;and save it
	MOV	WORD PTR ADD8,BX
	MOV	WORD PTR ADD8+2,ES

	MOV	AX,2508H   
	MOV	DX,OFFSET VEC8	;address interrupt procedure
	INT	21H		;install vector 8

	MOV	DX,OFFSET INSTALL	;find paragraphs
	MOV	CL,4
	SHR	DX,CL
	INC	DX

	MOV	AX,3100H	;exit to DOS, but make VEC 8 a TSR
	INT	21H
	END
