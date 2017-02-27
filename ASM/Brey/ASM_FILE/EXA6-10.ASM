	.MODEL TINY		;select TINY model
	.CODE			;indicate start of code segment
	.STARTUP		;indicate start of program
	IN	AL,61H		;read port 61H
	OR	AL,3		;set rightmost two bits
	OUT	61H,AL		;speaker is on
        
	MOV	CX,1000H	;delay count
L1:
	LOOP	L1		;time delay
        
	IN	AL,61H		;read port 61H
	AND	AL,0FCH    	;clear rightmost two bits
	OUT	61H,AL		;speaker is off
	.EXIT			;exit to DOS
	END			;end of file
