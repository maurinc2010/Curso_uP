;a TSR interrupt hook that monitors the keyboard and the mouse.
;if the keyboard and mouse are idle for more than 5 minutes, the
;screen dims by a factor of four.  If the mouse or keyboard 
;is used, the display rebounds to normal brightness.
;
	.MODEL TINY
	.386                    ;uses comes 80386 instructions
	.CODE
;        .STARTUP
	JMP     INSTALL         ;install VEC8 and VEC9
DELAY   EQU     1092*5          ;delay time (5 minutes)
BUSY    DB      0               ;busy flag
ADD8    DD      ?               ;old vector 8 address
ADD9    DD      ?               ;old vector 9 address
SADD    DD      ?               ;old stack pointer
COUNT   DW      DELAY           ;count
X       DW      ?               ;X mouse position
Y       DW      ?               ;Y mouse position
	DW      256 DUP (?)     ;stack area        
STT     EQU     THIS WORD
KFLAG   DB      0               ;key detected
PFLAG   DB      0               ;palette flag
PAL     DB      256*3 DUP (?)   ;palette memory
	
VEC9    PROC    FAR             ;keyboard intercept
											
	MOV     CS:KFLAG,1      ;indicate any key typed
	JMP     CS:ADD9         ;do keyboard interrupt
											
VEC9    ENDP
											
VEC8    PROC    FAR             ;clock tick interrupt procedure
											
	CMP     CS:BUSY,0       ;test busy flag
	JZ      VEC81           ;if not busy
	JMP     CS:ADD8         ;do old INT 8
VEC81:
	MOV     CS:BUSY,1       ;indicate busy
	PUSHF                   ;do normal INT 8 interrupt
	CALL    CS:ADD8
	CLI                     ;interrupts off
	MOV     WORD PTR CS:SADD,SP
	MOV     SP,SS           ;save old SS:SP
	MOV     WORD PTR CS:SADD+2,SP
	MOV     SP,CS
	MOV     SS,SP           ;load new SS:SP
	MOV     SP,OFFSET STT
	STI                     ;interrupts on
	CMP     CS:KFLAG,0      ;test key active
	JNZ     VEC85           ;if key active
	PUSHA                   ;test mouse
	MOV     AX,3
	INT     33H             ;get mouse status
	AND     BX,7            ;2- or 3-button mouse
	JNZ     MICKEY1         ;for any button
	CMP     CS:X,CX
	JNE     MICKEY          ;if mouse moved
	CMP     CS:Y,DX
	JNE     MICKEY          ;if mouse moved
	POPA
	CMP     CS:PFLAG,0      ;test for dim
	JNE     VEC88           ;if already dim, end
	DEC     CS:COUNT        ;decrement count
	JNZ     VEC88           ;if time delay not done, end
VEC82:                          ;dim screen
	PUSHA                   ;save registers
	PUSH    ES
	PUSH    DS
	CLD
	MOV     AX,CS           ;load ES and DS
	MOV     ES,AX
	MOV     DS,AX
	MOV     DI,OFFSET PAL   ;address palette storage area
	MOV     SI,DI
	MOV     CX,256          ;load count
	MOV     DX,3C7H         ;select read, set color to 00H
	XOR     AL,AL
	OUT     DX,AL
	MOV     DX,3C9H         ;address PEL register
VEC83:                          ;save old palette and dim it
	CLI                     ;disable interrupts
	IN      AL,DX           ;get red and save it
	STOSB
	IN      AL,DX           ;get green and save it
	STOSB
	IN      AL,DX           ;get blue and save it
	STOSB
	STI                     ;enable interrupts
	LOOP    VEC83           ;read all 256 colors
	MOV     CX,256          ;load count
	DEC     DX              ;select write port
	XOR     AL,AL           ;color number 00H
	OUT     DX,AL
	INC     DX              ;address PEL register
VEC84:
	CLI                     ;disable interrupts
	LODSB                   ;get red and dim it
	SHR     AL,2
	OUT     DX,AL
	LODSB                   ;get green and dim it
	SHR     AL,2
	OUT     DX,AL
	LODSB                   ;get blue and dim it
	SHR     AL,2
	OUT     DX,AL
	STI                     ;enable interrupts
	LOOP    VEC84           ;write all colors
	MOV     CS:PFLAG,1      ;indicate dim
	POP     DS              ;restore registers
	POP     ES
	POPA
	JMP     VEC88
MICKEY:
	MOV     CS:X,CX         ;save new position
	MOV     CS:Y,DX
MICKEY1:
	POPA
VEC85:
	CMP     CS:PFLAG,0
	JZ      VEC87           ;if display normal
	PUSHA                   ;save registers
	PUSH    DS
	MOV     AX,CS           ;load DS
	MOV     DS,AX
	MOV     SI,OFFSET PAL
	CLD
	MOV     CX,256          ;load count
	MOV     DX,3C8H         ;select write, color 00H
	XOR     AL,AL
	OUT     DX,AL
	INC     DX              ;address PEL register
VEC86:                          ;reload palette
	CLI                     ;disable interrupts
	LODSB                   ;reload red
	OUT     DX,AL
	LODSB
	OUT     DX,AL           ;reload green
	LODSB
	OUT     DX,AL           ;reload blue
	STI                     ;enable interrupts
	LOOP    VEC86           ;repeat for all colors
	MOV     CS:PFLAG,0      ;indicate normal palette
	POP     DS              ;restore registers
	POPA
VEC87:
	MOV     CS:COUNT,DELAY  ;reset count to DELAY
	MOV     CS:KFLAG,0      ;clear key active
VEC88:
	MOV     CS:BUSY,0       ;indicate not busy
	LSS     SP,CS:SADD
	IRET
											
VEC8    ENDP
											
INSTALL:

	MOV     AX,CS           ;load DS
	MOV     DS,AX
	MOV     AX,3508H        ;get current vector 8
	INT     21H             ;and save it
	MOV     WORD PTR ADD8,BX
	MOV     WORD PTR ADD8+2,ES
											
	MOV     AX,3509H        ;get current vector 9
	INT     21H             ;and save it
	MOV     WORD PTR ADD9,BX        
	MOV     WORD PTR ADD9+2,ES
	
	MOV     AX,2508H        ;install new interrupt 8
	MOV     DX,OFFSET VEC8
	INT     21H
	
	MOV     AX,2509H        ;install new interrupt 9
	MOV     DX,OFFSET VEC9
	INT     21H
											
	MOV     DX,OFFSET INSTALL
	SHR     DX,4            ;determine paragraphs
	INC     DX
						
	MOV     AX,3100H        ;install as TSR
	INT     21H
	END
