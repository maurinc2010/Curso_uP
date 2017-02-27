;a program that accesses the DOS MEM.EXE program to display either
;a summary of memory or a complete listing.
;
	.MODEL SMALL
	.386
	.STACK	1024		;1K stack
	.DATA
TAB	DW	SUM,COMP,BYE	;jump table
OLDSS	DW	?		;stack pointer storage
OLDSP	DW	?
                                        
PARA1	DW	0		;standard environment
	DW	OFFSET C1	;address blank command line
	DW	SEG C1	
	DW	0,0,0,0		;FCBs
                                                
PARA2	DW	0		;standard environment
	DW	OFFSET C2	;address /C /P command line
	DW	SEG C2
	DW	0,0,0,0		;FCBs
        
CHILD	DB	'C:\DOS\MEM.EXE',0	;name of MEM program
C1	DB	0,13  			;blank command line
C2	DB	5,'/C /P',13   		;/C /P command line
MES1	DB	13,10,10,'MEMORY DISPLAY',13,10,10
	DB	'1 - Display memory summary',13,10
	DB	'2 - Display memory complete',13,10
	DB	'3 - Exit to DOS',13,10,10
	DB	'Enter choice $'
MES2	DB	'Type any key to continue: $'
	.CODE
KEY	MACRO		;;read key, no echo
	LOCAL	K1,K2
K1:
	MOV	AH,6
	MOV	DL,0FFH
	INT	21H
	JZ	K1	;;if no key typed
	CMP	AL,0
	JNZ	K2	;;if good ASCII code
	INT	21H	;if extended ASCII
	JMP	K1	;;ignore extended ASCII
K2:
	ENDM
        
	.STARTUP
	MOV	BX,DS		;get DS
	MOV	AX,ES		;load ES with segment address
	SUB	BX,AX		;calculate length of data paragraphs
	MOV	AX,SP		;find length of stack
	SHR	AX,4
	INC	AX
	ADD	BX,AX		;find length of all segments
	MOV	AH,4AH		;reserve memory for this program
	INT	21H		;its data, stack, and PSP
MAIN1:				;display menu
	MOV	AH,9
	MOV	DX,OFFSET MES1
	INT	21H
MAIN2:
	KEY			;get key, no echo
	SUB	AL,31H		;convert from ASCII
	JB	MAIN2		;if below 1 key
	CMP	AL,2
	JA	MAIN2		;if above 3 key
	MOV	AH,0
	ADD	AX,AX		;double choice
	MOV	SI,OFFSET TAB	;address lookup table
	ADD	SI,AX
	MOV	BX,[SI]		;get address of procedure
	CALL	BX		;execute choice
	MOV	DX,OFFSET MES2	;display any key
	MOV	AH,9
	INT	21H
	KEY			;get any key
	JMP	MAIN1		;repeat menu display
 
SUM	PROC	NEAR		;display memory summary (1)
                                                
	MOV	AH,4BH		;execute MEM
	MOV	AL,0		;operation load end execute
	MOV	DX,OFFSET CHILD	;address program name
	PUSH	DS		;get DS to ES
	POP	ES
	MOV	BX,OFFSET PARA1	;address command line C1
	CLI			;disable interrupts
	MOV	OLDSS,SS	;save stack at OLD
	MOV	OLDSP,SP
	STI			;enable interrupts
	INT	21H		;execute MEM child process
	CLI			;disable interrupts
	MOV	SS,OLDSS
	MOV	SP,OLDSP	;reload stack
	STI			;enable interrupts
	RET
                                                
SUM	ENDP
                                                
COMP	PROC	NEAR		;display memory complete (2)
                                                
	MOV	AH,4BH		;execute MEM /C /P
	MOV	AL,0
	MOV	DX,OFFSET CHILD	;address program name
	PUSH	DS		;DS to ES
	POP	ES
	MOV	BX,OFFSET PARA2	;address command line C2
	CLI			;disable interrupts
	MOV	OLDSS,SS	;save old stack area
	MOV	OLDSP,SP
	STI			;enable interrupts
	INT	21H		;execute MEM child process
	CLI			;disable interrupts
	MOV	SS,OLDSS
	MOV	SP,OLDSP	;get old stack area
	STI			;enable interrupts
	RET
                                                
COMP	ENDP
        
BYE	PROC	NEAR		;for exit to DOS (3)
        
	.EXIT			;exit to DOS
                                                
BYE	ENDP
	END
