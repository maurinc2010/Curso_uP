;a program that lists the information from the parameter
;block for a block device.
	.MODEL SMALL
	.386
	.DATA
FUNC	DB	1		;get disk parameter block
DTYPE	DB	?		;disk type
DATT	DW	?		;disk attribute
CYL	DW	?		;number of cylinders
MTYPE	DB	?		;media type
SEC	DW	?		;bytes per sector
CLUST	DB	?		;sectors per cluster
RSECT	DW	?		;reserved sectors
NFAT	DB	?		;number of FATs
ROOT	DW	?		;maximum root entries
NSEC	DW	?		;total number of sectors
MEDIA	DB	?		;media ID
SFAT	DW	?		;sectors per FAT
TRACK	DW	?		;number of sectors per track
NHEAD	DW	?		;number of heads
NHID	DD	?		;number of hidden sectors
HUGE	DD	?		;total sectors if NSEC = 0
	DB	6 DUP (?)	;reserved
DTAB	DW	T0,T1,T2,T3,T4,T5,T6,T7,T8,T9
T0	DB	'320K/360K, 5-1/4" disk.$'
T1	DB	'1.2M, 5-1/4" disk.$'
T2	DB 	'720K, 3-1/3" disk.$'
T3	DB	'Single-density, 8" disk.$'
T4	DB	'Double-density, 8" disk.$'
T5	DB	'Fixed disk.$'
T6	DB	'Tape drive.$'
T7	DB	'1.44M, 3-1/2" disk.$'
T8	DB	'2.88M, 3-1/2" disk.$'
T9	DB	'Other block device.$'
DATAB	DW	DA0,DA1,DA2,DA3
DA0	DB	'Removable medium.$'
DA1	DB	'Nonremovable medium.$'
DA2	DB	'Door lock not supported.$'
DA3	DB	'Door lock supported.$'
BPS	DB	'Bytes per sector = $'
NCYL	DB	'Number of cylinders = $'
AU	DB	'Sectors per cluster = $'
CYLS	DB	'Number of reserved sectors from sector 0 = $'
FAT	DB	'Number of FATs = $'
ROOTS	DB	'Number of root directory entries = $'
SECS	DB	'Total number of sectors = $'
SECF	DB	'Number of sectors per FAT = $'
STRA	DB	'Number of sectors per track = $'
HEADS	DB	'Number of heads = $'
HID	DB	'Number of hidden sectors = $'
ERR1	DB	'ERROR$'
	.CODE
;;the CRLF macro displays a carriage return
;;and line feed.
;;
CRLF	MACRO
	MOV	AH,6
	MOV	DL,13
	INT	21H
	MOV	DL,10
	INT	21H
	ENDM
;;
;;the STRING macro display a character string
;;
STRING	MACRO	WHAT
	CRLF
	MOV	AH,9
	MOV	DX,OFFSET WHAT
	INT	21H
	ENDM
	.STARTUP
	MOV	AX,440DH	;generic block control
	MOV	BL,3		;drive C
	MOV	CX,860H		;get device parameters
	MOV	DX,OFFSET FUNC	;address parameter block
	INT	21H
	JNC	MAIN1		;if no error
	STRING	ERR1		;display error
	JMP	MAIN6		;exit to DOS
MAIN1:				;if no error detected
	MOV	SI,OFFSET FUNC+1
	LODSB			;get device type
	MOV	AH,0
	ADD	AX,AX
	MOV	DI,OFFSET DTAB	;address device type table
	ADD	DI,AX
	CRLF
	MOV	DX,[DI]
	MOV	AH,9		;display device type
	INT	21H
	LODSW			;get attribute
	MOV	DI,OFFSET DATAB	;address DATAB table
	TEST	AL,1		;test bit 0
	JE	MAIN2		;if bit 0 = 0
	ADD	DI,2		;else
MAIN2:
	PUSH	AX		;save attribute
	CRLF
	MOV	DX,[DI]
	MOV	AH,9		;display removable/
	INT	21H		;nonremovable
	POP	AX		;get attribute
	MOV	DI,OFFSET DATAB+4	;address entry 2
	TEST	AL,2		;test door lock support
	JE	MAIN3		;if not supported
	ADD	DI,2		;if supported
MAIN3:
	CRLF
	MOV	DX,[DI]
	MOV	AH,9
	INT	21H		;display door lock status
	STRING	NCYL
	LODSW
	CALL	DISPW		;display cylinders
	LODSB			;media type
	STRING	BPS
	LODSW			;bytes per sector
	CALL	DISPW
	STRING	AU		;sectors per cluster
	LODSB
	CALL	DISPB
	STRING	CYLS		;number of cylinders
	LODSW			;sectors per cylinder
	CALL	DISPW
	STRING	FAT
	LODSB
	CALL	DISPB		;number of FATs
	STRING	ROOTS
	LODSW
	CALL	DISPW		;number of root entries
	STRING	SECS
	LODSW
	OR 	AX,AX
	JE	MAIN4		;if huge
	CALL	DISPW		;total sectors
	JMP	MAIN5
MAIN4:
	MOV	EAX,HUGE
	CALL	DISPD
MAIN5:
	LODSB
	STRING	SECF
	LODSW
	CALL	DISPW		;sectors per fat
	STRING	STRA
	LODSW
	CALL	DISPW		;sectors per track
	STRING	HEADS
	LODSW
	CALL	DISPW		;number of heads
	STRING	HID
	LODSD
	CALL	DISPD		;number of hidden sectors
MAIN6:
	.EXIT
;the DISPB procedure displays the contents of AL as a 
;decimal number.
;***uses DISPD***
;
DISPB	PROC	NEAR
        
	AND	EAX,0FFH
	CALL	DISPD
	RET
        
DISPB	ENDP
;
;the DISPW procedure displays the contents of AX as a
;decimal number.
;***uses DISPD***
;
DISPW	PROC	NEAR
        
	AND	EAX,0FFFFH
	CALL	DISPD
	RET

DISPW	ENDP
;the DISPD procedure displays the contents of EAX as a
;decimal number with leading zeros suppressed, including
;commas.
;
DISPD	PROC	NEAR
        
	MOV	EBX,10		;load 10 for decimal
	PUSH	BX		;save end marker
	MOV	CX,3		;load comma counter
DISPD1:
	XOR	EDX,EDX		;clear EDX to zero
	DIV	EBX		;divide by 10
	ADD	DL,30H		;convert remainder to ASCII
	PUSH	DX		;save remainder
	CMP	EAX,0		;test quotient for zero
	JE	DISPD2		;if zero display data
	LOOP	DISPD1		;test for comma
	MOV	CX,3		;reload comma counter
	MOV	DL,','		;get comma
	PUSH	DX		;save comma
	JMP	DISPD1		;repeat divisions
DISPD2:
	MOV	AH,6		;select display function
	POP	DX		;get digit from stack
	CMP	DX,BX		;test for end marker
	JE	DISPD3		;if end marker encountered
	INT	21H		;display digit
	JMP	DISPD2		;repeat until end marker
DISPD3:
	RET
        
DISPD	ENDP
	END
