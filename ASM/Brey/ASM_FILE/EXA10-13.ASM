	.MODEL TINY
	.CODE
;the IO macro functions in 3 ways
;
;(1) IO           read a key with echo
;(2) IO -1       display a carriage return & line feed
;(3) IO 'B'      display the letter 'B'
;or  IO AL      display contents of AL
;
IO   MACRO    CHAR
	IFB	<CHAR>		;;if CHAR is blank
		MOV	AH,1	;;read key function number
	ENDIF
        
	IFNB	<CHAR>		;;if CHAR is not blank
		MOV	AH,2	;;display character function number
	IF	CHAR EQ -1	;;if CHAR equals -1
		MOV	DL,13	;;display carriage return
		INT	21H
		MOV	DL,10	;;display line feed
        
	ELSE			;;if CHAR not equal to -1
        
		MOV	DL,CHAR	;;load CHAR to DL and display
	ENDIF
        
	ENDIF
        
	INT	21H
	ENDM
	.STARTUP
;
;this program does a carriage return, line feed then displays
;the letters BE on the video screen.  Next to waits for a key
;to be typed.  Following the key, a carriage return, line feed
;is displayed.
;
	IO	-1		;carriage return & line feed 
	IO	'B'		;display 'B'
	IO	'E'		;display 'E'
	IO			;read key
	IO	-1		;carriage return & line feed
	.EXIT
	END
