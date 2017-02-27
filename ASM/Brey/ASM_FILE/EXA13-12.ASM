;a program that displays the floating-point contents of NUMB
;as a mixed decimal number.
	.MODEL SMALL
	.386
	.387
	.DATA
NUMB    DD      -2224.125       ;test data
TEMP    DW      ?
WHOLE   DD      ?
FRACT   DD      ?
	.CODE
;        .STARTUP
	CALL    DISP            ;display NUMB
;        .EXIT
;
;procedure that displays the ASCII code from AL
;
DISPS   PROC    NEAR
										
	MOV     AH,6            ;display AL
	MOV     DL,AL
	INT     21H
	RET
						
DISPS   ENDP
;
;procedure that displays the floating-point contents of NUMB
;in decimal form.
;                                                                       
DISP    PROC    NEAR
										
	FSTCW   TEMP            ;save current control word
	OR      TEMP,0C00H      ;set rounding to chop     
	FLDCW   TEMP                                                   
	FLD     NUMB            ;get NUMB
	FTST                    ;test NUMB
	FSTSW   AX              ;status to AX
	AND     AX,4500H        ;get C3, C2, and C0
	.IF     AX == 0100H
		MOV     AL,'-'
		CALL    DISPS
		FABS
	.ENDIF
	FLD     ST
	FRNDINT                 ;get integer part
	FIST    WHOLE
	FSUBR
	FABS
	FSTP    FRACT           ;save fraction
	MOV     EAX,WHOLE
	MOV     EBX,10
	MOV     CX,0
	PUSH    BX
	.WHILE  1               ;divide until quotient = 0
		MOV     EDX,0
		DIV     EBX
		ADD     DL,30H
		PUSH    DX
	.BREAK  .IF EAX == 0
		INC     CX
		.IF     CX == 3
			PUSH    ','
			MOV     CX,0
		.ENDIF
	.ENDW        
	.WHILE  1               ;display whole number part
		POP     DX
	.BREAK .IF  DX == BX
		MOV     AL,DL
		CALL    DISPS
	.ENDW
	MOV     AL,'.'          ;display decimal point
	CALL    DISPS
	MOV     EAX,FRACT
	FSTCW   TEMP            ;save current control word
	XOR     TEMP,0C00H      ;set rounding to nearest     
	FLDCW   TEMP                                                   
	FLD     FRACT
	FXTRACT                
	FSTP    FRACT
	FABS
	FISTP   WHOLE
	MOV     ECX,WHOLE
	MOV     EAX,FRACT
	SHL     EAX,9
	RCR     EAX,CL
	.REPEAT
		MUL     EBX
		PUSH    EAX
		XCHG    EAX,EDX
		ADD     AL,30H
		CALL    DISPS
		
		POP     EAX
	.UNTIL  EAX == 0
	RET        

DISP    ENDP
	
	END
