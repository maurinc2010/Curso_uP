;a program that beeps the speaker with some sample audio tones
;that each have a duration of 1/3 second.
;
	.MODEL TINY
	.CODE
	.STARTUP
	MOV	AX,0
	MOV	DS,AX		;address segment 0000H
                                                
	MOV	CX,4		;set count to 4
	IN	AL,61H		;enable timer and speaker
	OR	AL,3		;set PB0 and PB1
	OUT	61H,AL
MAIN1:
	MOV	BX,1000		;select 1000 Hz tone
	CALL	BEEP
	MOV	BX,1200		;select 1200 Hz tone	
	CALL	BEEP
	MOV	BX,1400		;select 1400 Hz tone
	CALL	BEEP
	LOOP	MAIN1		;repeat 4 times
                                                
	IN	AL,61H		;turn speaker off
	XOR	AL,3		;clear PB0 and PB1
	OUT	61H,AL
	.EXIT
;
;the BEEP procedure programs timer 2 to beep the speaker for
;1/3 of a second with the frequency of the audio tone in BX.
;***input parameters***
;BX = desired audio tone
;***uses***
;WAITS procedure to wait for 1/2 second
;
BEEP	PROC	NEAR		;beep speaker for 1/3 second
                                                
	MOV	AX,34DCH	;load AX with 1,193,180
	MOV	DX,12H
	DIV	BX		;find count
	OUT	42H,AL		;program timer 2 with count
	MOV	AL,AH
	OUT	42H,AL
	CALL	WAITS		;wait 1/3 second
	RET
                                                
BEEP	ENDP
;
;the WAITS procedure waits 1/3 of a second
;***uses***
;memory doubleword location 0000:46CH to time the wait
;                                       
WAITS	PROC	NEAR

	MOV	DX,6		;number of clock ticks
	MOV	BX,0
	ADD	DX,DS:[46CH]	;get tick count plus time
	ADC	BX,DS:[46EH]
WAIT1:
	MOV	BP,DS:[46CH]	;test for elapsed time
	MOV	AX,DS:[46EH]
	SUB	BP,DX
	SBB	AX,BX
	JC	WAIT1		;keep testing
        
	RET
                                                
WAITS	ENDP
	END
