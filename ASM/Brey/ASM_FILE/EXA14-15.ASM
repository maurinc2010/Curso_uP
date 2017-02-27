;a program that displays the contents of any area of memory
;including extended memory.
;***command line syntax***
;EDUMP XXXX,YYYY  where XXXX is the start address and YYYY is
;the end address.
;Note:  this program must be executed from WINDOWS.
;
	.MODEL SMALL
	.386
	.STACK 1024             ;stack area of 1,024 bytes
	.DATA
ENTRY   DD      ?               ;DPMI entry point
EXIT    DD      ?               ;DPMI exit point
FIRST   DD      ?               ;first address
LAST1   DD      ?               ;last address
MSIZE   DW      ?               ;memory needed for DPMI
ERR1    DB      13,10,10,'Parameter error.$'
ERR2    DB      13,10,10,'DPMI not present.$'
ERR3    DB      13,10,10,'Not enough real memory.$'
ERR4    DB      13,10,10,'Could not move to protected mode.$'
ERR5    DB      13,10,10,'Cannot allocate selector.$'
ERR6    DB      13,10,10,'Cannot use base address.$'
ERR7    DB      13,10,10,'Cannot allocate 64K to limit.$'
CRLF    DB      13,10,'$'
MES1    DB      'Press any key...$'
;                                       
;register array storage for DPMI function 0300H
;                                       
ARRAY   EQU     THIS BYTE
REDI    DD      0               ;EDI
RESI    DD      0               ;ESI
REBP    DD      0               ;EBP
	DD      0               ;reserved
REBX    DD      0               ;EBX
REDX    DD      0               ;EDX
RECX    DD      0               ;ECX
REAX    DD      0               ;EAX
RFLAG   DW      0               ;flags
RES     DW      0               ;ES
RDS     DW      0               ;DS
RFS     DW      0               ;FS
RGS     DW      0               ;GS
RIP     DW      0               ;IP
RCS     DW      0               ;CS
RSP     DW      0               ;SP
RSS     DW      0               ;SS
	.CODE
	.STARTUP
	MOV     AX,ES
	MOV     BX,DS           ;find size of program and data
	SUB     BX,AX
	MOV     AX,SP           ;find stack size
	SHR     AX,4
	INC     AX
	ADD     BX,AX           ;BX = length in paragraphs
	MOV     AH,4AH
	INT     21H             ;modify memory allocation
	CALL    GETDA           ;get command line information
	JNC     MAIN1           ;if parameters are good
	MOV     AH,9            ;parameter error
	MOV     DX,OFFSET ERR1
	INT     21H
	JMP     MAINE           ;exit to DOS
MAIN1:
	CALL    ISDPMI          ;is DPMI loaded?
	JC      MAIN2           ;if DPMI present
	MOV     AH,9
	MOV     DX,OFFSET ERR2
	INT     21H             ;display DPMI not present
	JMP     MAINE           ;exit to DOS
MAIN2:
	MOV     AX,0            ;indicate 0 memory needed
	CMP     MSIZE,0
	JE      MAIN2           ;if DPMI needs no memory
	MOV     BX,MSIZE        ;get amount
	MOV     AH,48H
	INT     21H             ;allocate memory for DPMI
	JNC     MAIN3
	MOV     AH,9            ;if not enough real memory
	MOV     DX,OFFSET ERR3
	INT     21H
	JMP     MAINE           ;exit to DOS
MAIN3:
	MOV     ES,AX
	MOV     AX,0            ;16-bit application
	CALL    DS:ENTRY        ;switch to protected mode
	JNC     MAIN4
	MOV     AH,9            ;if switch failed
	MOV     DX,OFFSET ERR4
	INT     21H
	JMP     MAINE           ;exit to DOS
;
;PROTECTED MODE
;
MAIN4:
	MOV     AX,0000H        ;get local selector
	MOV     CX,1            ;only one is needed
	INT     31H
	JC      MAIN7           ;if error
	MOV     BX,AX           ;save selector
	MOV     ES,AX           ;load ES with selector
	MOV     AX,0007H        ;set base address
	MOV     CX,WORD PTR FIRST+2
	MOV     DX,WORD PTR FIRST
	INT     31H
	JC      MAIN8           ;if error
	MOV     AX,0008H
	MOV     CX,0
	MOV     DX,0FFFFH       ;set limit to 64K
	INT     31H
	JC      MAIN9           ;if error
	MOV     CX,24           ;load line count
	MOV     SI,0            ;load offset
MAIN5:
	CALL    DADDR           ;display address, if needed
	CALL    DDATA           ;display data
	INC     SI              ;point to next data
	MOV     EAX,FIRST       ;test for end
	CMP     EAX,LAST1
	JE      MAIN6           ;if done
	INC     FIRST
	JMP     MAIN5
MAIN6:
	MOV     AX,0001H        ;release descriptor
	MOV     BX,ES
	INT     31H
	JMP     MAINE           ;exit to DOS
MAIN7:
	MOV     DX,OFFSET ERR5
	CALL    DISPS           ;display cannot allocate selector
	JMP     MAINE           ;exit to DOS
MAIN8:
	MOV     DX,OFFSET ERR6
	CALL    DISPS           ;display cannot use base address
	JMP     MAIN6           ;release descriptor
MAIN9:
	MOV     DX,OFFSET ERR7
	CALL    DISPS           ;display cannot allocate 64K limit
	JMP     MAIN6           ;release descriptor
MAINE:
	.EXIT
;
;the ISDPMI procedure tests for the presence of DPMI
;***exit parameters***
;carry = 1; if DPMI is present
;carry = 0; if DPMI is not present
;
ISDPMI  PROC    NEAR
						
	MOV     AX,1687H        ;get DPMI status
	INT     2FH             ;DOS multiplex
	OR      AX,AX
	JNZ     ISDPMI1         ;if no DPMI
	MOV     MSIZE,SI        ;save amount of memory needed
	MOV     WORD PTR ENTRY,DI
	MOV     WORD PTR ENTRY+2,ES
	STC
ISDPMI1:
	RET
						
ISDPMI  ENDP
;
;the GETDA procedure retrieves the command line parameters
;for memory display in hexadecimal.
;FIRST = the first address from the command line
;LAST1 = the last address from the command line
;***return parameters***
;carry = 1; if error
;carry = 0; for no error
;
GETDA   PROC    NEAR

	PUSH    DS
	PUSH    ES
	POP     DS
	POP     ES              ;exchange ES with DS
	MOV     SI,81H          ;address command line
GETDA1:
	LODSB                   ;skip spaces
	CMP     AL,' '
	JE      GETDA1          ;if space
	CMP     AL,13
	JE      GETDA3          ;if enter = error
	DEC     SI              ;adjust SI
GETDA2:
	CALL    GETNU           ;get first number
	CMP     AL,','
	JNE     GETDA3          ;if no comma = error
	MOV     ES:FIRST,EDX
	CALL    GETNU           ;get second number
	CMP     AL,13           
	JNE     GETDA3          ;if error
	MOV     ES:LAST1,EDX
	CLC                     ;indicate no error
	JMP     GETDA4          ;return no error
GETDA3:
	STC                     ;indicate error
GETDA4:
	PUSH    DS              ;exchange ES with DS    
	PUSH    ES
	POP     DS
	POP     ES
	RET

GETDA   ENDP
;
;the GETNU procedure extracts a number from the command line
;and returns with it in EDX and last command line character in
;AL as a delimiter.
;
GETNU   PROC    NEAR
	
	MOV     EDX,0           ;clear result
GETNU1:
	LODSB                   ;get digit from command line
	.IF  AL >= 'a' && AL <= 'z'
		SUB     AL,20H  ;make uppercase
	.ENDIF
	SUB     AL,'0'          ;convert from ASCII
	JB      GETNU2          ;if not a number
	.IF  AL > 9             ;convert A-F from ASCII
		SUB     AL,7
	.ENDIF
	CMP     AL,0FH
	JA      GETNU2          ;if not 0--F
	SHL     EDX,4
	ADD     DL,AL           ;add digit to EDX
	JMP     GETNU1          ;get next digit
GETNU2:
	MOV     AL,[SI-1]       ;get delimiter
	RET
						
GETNU   ENDP
;
;the DISPC procedure displays the ASCII character found
;in register AL.
;***uses***
;INT21H
;
DISPC   PROC    NEAR
	
	PUSH    DX
	MOV     DL,AL
	MOV     AH,6
	CALL    INT21H          ;do real INT 21H
	POP     DX
	RET

DISPC   ENDP
;
;the DISPS procedure displays a character string from
;protected mode addressed by DS:EDX.
;***uses***
;DISPC
;                                       
DISPS   PROC    NEAR
						
	AND     EDX,0FFFFH
	MOV     AL,[EDX]        ;get character
	CMP     AL,'$'          ;test for end
	JE      DISP1           ;if end
	INC     EDX             ;address next character
	CALL    DISPC           ;display character
	JMP     DISPS           ;repeat until $
DISP1:
	RET
	
DISPS   ENDP
;
;the DDATA procedure displays a byte of data at the location
;addressed by ES:SI.  The byte is followed by one space.
;***uses***
;DIP and DISPC
;                                       
DDATA   PROC    NEAR
						
	MOV     AL,ES:[SI]      ;get byte
	SHR     AL,4
	CALL    DIP             ;display first digit
	MOV     AL,ES:[SI]      ;get byte
	CALL    DIP             ;display second digit
	MOV     AL,' '          ;display space
	CALL    DISPC   
	RET

DDATA   ENDP
;
;the DIP procedure display the right nibble found in AL as a
;hexadecimal digit.
;***uses***
;DISPC
;
DIP     PROC    NEAR
	
	AND     AL,0FH          ;get right nibble
	ADD     AL,30H          ;convert to ASCII
	.IF  AL > 39H           ;if A-F
		ADD     AL,7
	.ENDIF
	CALL    DISPC           ;display digit
	RET
						
DIP     ENDP
;
;the DADDR procedure displays the hexadecimal address found
;in DS:FIRST if it is a paragraph boundary.
;***uses***
;DIP, DISPS, DISPC, and INT21H

DADDR   PROC NEAR
	
	MOV     EAX,FIRST       ;get address
	TEST    AL,0FH          ;test for XXXXXXX0
	JNZ     DADDR4          ;if not, don't display address
	MOV     DX,OFFSET CRLF
	CALL    DISPS           ;display CR and LF
	DEC     CX              ;decrement line count
	JNZ     DADDR2          ;if not end of page
	MOV     DX,OFFSET MES1  ;if end of page
	CALL    DISPS           ;display press any key
DADDR1:
	MOV     AH,6            ;get any key, no echo
	MOV     DL,0FFH
	CALL    INT21H          ;do real INT 21H
	JZ      DADDR1          ;if nothing typed
	MOV     DX,OFFSET CRLF
	CALL    DISPS           ;display CRLF
	MOV     CX,24           ;reset line count
DADDR2:
	PUSH    CX              ;save line count
	MOV     CX,8            ;load digit count
	MOV     EDX,FIRST       ;get address
DADDR3:
	ROL     EDX,4
	MOV     AL,DL
	CALL    DIP             ;display digit
	LOOP    DADDR3          ;repeat 8 times
	POP     CX              ;retrieve line count
	MOV     AL,':'
	CALL    DISPC           ;display colon
	MOV     AL,' '
	CALL    DISPC           ;display space
DADDR4:
	RET
						
DADDR   ENDP
;
;the INT21H procedure gains access to the real mode DOS
;INT 21H instruction with the parameters intact.
;
INT21H  PROC    NEAR
						
	MOV     REAX,EAX        ;save registers
	MOV     REBX,EBX
	MOV     RECX,ECX
	MOV     REDX,EDX
	MOV     RESI,ESI
	MOV     REDI,EDI
	MOV     REBP,EBP
	PUSHF
	POP     AX
	MOV     RFLAG,AX
	PUSH    ES              ;do DOS interrupt       
	MOV     AX,0300H
	MOV     BX,21H
	MOV     CX,0
	PUSH    DS
	POP     ES
	MOV     DI,OFFSET ARRAY
	INT     31H
	POP     ES
	MOV     AX,RFLAG        ;restore registers
	PUSH    AX
	POPF
	MOV     EDI,REDI
	MOV     ESI,RESI
	MOV     EBP,REBP
	MOV     EAX,REAX
	MOV     EBX,REBX
	MOV     ECX,RECX
	MOV     EDX,REDX
	RET
						
INT21H  ENDP
	END
