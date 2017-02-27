;program that display a bright red B at row 0, column 0, and a
;cyan A at row 5, column 20.
	.MODEL TINY
	.CODE
;        .STARTUP
	MOV     AX,0A000H       ;address video RAM at segment A000
	MOV     DS,AX
	CLD                     ;select increment
	
	MOV     AX,12H          ;set mode to 12H
	INT     10H             ;and clear screen
	
	MOV     AL,'A'          ;display 'A'
	MOV     DL,3            ;cyan
	MOV     BX,5            ;row 5
	MOV     SI,20            ;column 0
	CALL    CHAR            ;display cyan 'A'
	
	MOV     AL,'B'          ;display 'B'
	MOV     DL,12           ;bright red
	MOV     BX,0            ;row 0
	MOV     SI,0            ;column 0
	CALL    CHAR            ;display bright red 'B'
	
	MOV     AH,1            ;wait for key
	INT     21H
	
	MOV     AX,3
	INT     10H             ;return to DOS video mode
;        .EXIT
;
;The CHAR procedure displays a character (8 x 8) on the
;mode 12H display without changing the background color.
;AL = ASCII code
;DL = color (0 to 15)
;BX = row (0 to 52)
;SI = column (0 to 79)
;
CHAR    PROC    NEAR
	
	PUSH    CX
	PUSH    DX
	PUSH    BX              ;save row address
	PUSH    AX              ;save ASCII
	MOV     AX,1130H        ;get 8 x 8 set
	MOV     BH,3
	INT     10H             ;segment is in ES
	POP     AX              ;get ASCII code
	MOV     AH,0
	SHL     AX,1            ;multiply by 8
	SHL     AX,1
	SHL     AX,1
	ADD     BP,AX           ;index character in ROM
	POP     BX              ;get row address
	MOV     AX,80*9         ;find row address
	MUL     BX
	MOV     DI,AX
	ADD     DI,SI           ;add in column address
	MOV     CX,8            ;set count to 8 rows
C1:        
	MOV     DX,3CEH         ;address bit mask register
	MOV     AL,8            ;load index 8
	MOV     AH,ES:[BP]      ;get character row
	INC     BP              ;point to next row
	OUT     DX,AX           ;modify bit mask register
	MOV     DX,3C4H         ;address map mask register
	MOV     AX,0F02H
	OUT     DX,AX           ;select all planes
	INC     DX
	MOV     AL,[DI]         ;read data
	MOV     BYTE PTR [DI],0 ;write black
	POP     AX              ;get color      
	PUSH    AX
	OUT     DX,AL           ;write color
	MOV     BYTE PTR [DI],0FFH      
	ADD     DI,80           ;address next raster row
	LOOP    C1              ;repeat 8 times

	POP     DX
	POP     CX
	RET

CHAR    ENDP
	END
