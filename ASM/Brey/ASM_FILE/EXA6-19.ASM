;An example program that reads a key and displays it.
;Note that an @ key ends the program
;
CODE_SEG SEGMENT  'CODE'
                                        
	ASSUME    CS:CODE_SEG
                                        
MAIN	PROC	FAR
                                        
	MOV	AH,6 		;read key
	MOV	DL,0FFH
	INT	21H
	JE	MAIN 		;if no key
                                        
	CMP	AL,'@'		;test for @
	JE	MAIN1		;if @
        
	MOV	AH,6		;display key
	MOV	DL,AL
	INT	21H
	JMP	MAIN		;repeat
MAIN1:
	MOV	AH,4CH		;exit to DOS
	INT	21H
                                        
	MAIN	ENDP
                                        
CODE_SEG  ENDS
                                        
	END	MAIN
