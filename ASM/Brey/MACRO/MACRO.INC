;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                         ;;
;;the MACRO.INC file contains macros that can be included with any program ;;
;;by using the following line after .CODE                                  ;;
;;                                                                         ;;
;;                INCLUDE C:\DIR\MACRO.INC                                 ;;
;;                                                                         ;;
;;note that C:   is the disk drive where MACRO.INC is stored               ;;
;;and          DIR  is the directory                                       ;;
;;                                                                         ;;
;;The macros in this file all start with the _ to distinguish them from    ;;
;;procedures and are:                                                      ;;                                                                         ;;
;;                                                                         ;;
;;      _DISP   CHAR     (display CHAR)  _DISP 'A' displays A              ;;                                                  
;;                                       _DISP BH  displays contents of BH ;;                                                                            ;;
;;                                       _DISP     displays new line       ;;
;;                                                                         ;;
;;                                                                         ;;
;;      _KEY    ECHO    (read one key)  returns the key in AL              ;;
;;                                      _KEY reads without echo            ;;                                      
;;                                      _KEY ECHO read with echo           ;;
;;                                      Carry = 1 = extended ASCII         ;;
;;                                      Carry = 0 = regular ASCII          ;;
;;                                                                         ;;
;;                                                                         ;;
;;      _STRING OFFSET  (display string)  displays the character that ends ;;
;;                                        with a $ (24H) from DS:OFFSET    ;;
;;                                                                         ;;
;;                                                                         ;;
;;      _NUM BASE,BKL (display number) display EAX as decimal BASE=10 with ;;
;;                                             with leading zeros blanked  ;;
;;                                     display EAX as BASE 2--36 with the  ;;
;;                                             number of digits indicated  ;;
;;                                             by BLK, if BLK is blank     ;;
;;                                             leading zeros are blanked   ;;
;;                                                                         ;;
;;                                                                         ;;
;;      _INUM BASE  (read number)  read a number for BASE = 2 through 36.  ;;
;;                                             result retruned in EAX      ;;
;;                                                                         ;;
;;                                                                         ;;
;;      _BLOCK  X,Y,CO (display Block)  displays a block in video mode 12H ;;
;;                                              X = row, Y = column and    ;;
;;                                              CO = color                 ;;
;;                                                                         ;;
;;      _DOT    X,Y,CO (display dot)   display a dot in video mode 12H     ;;
;;                                              X = row, Y = column and    ;;
;;                                              CO = color                 ;;
;;      _BAND   X,CO  (display band)   displays a band of color in mode 12H;;
;;                                              X = row and CO = color     ;;
;;                                                                         ;;
;;      _SCREEN CO   (change screen color)   displays an entire screen in  ;;
;;                                              mode 12H with color CO     ;;
;;                                                                         ;;
;;      _CHAR  X,Y,CHAR,CO (display character)  displays a character in    ;;
;;                                              mode 12H display at row X  ;;
;;                                              column Y, with color CO    ;;
;;                                                                         ;;
;;      _VSTR   X,Y,OFF,CO                      displays a character       ;;
;;                                              null string from DS:OFFSET ;;
;;						in video mode 12H	   ;;
;;                                                                         ;;
;;      _DISK   OP,HAN,BUF,COUNT                performs all disk ops      ;;
;;                                                                         ;;
;;      _MOUSE  OP,X,Y                          performs mouse services    ;;
;;									   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;a macro that displays CHAR as 'A' (ASCII), BH (from an 8-bit register)  
;;or if CHAR is blank, a carriage return line/feed combination            
;;
_DISP   MACRO   CHAR   
        PUSH    AX              ;;save registers
        PUSH    DX
        IFB     <CHAR>          ;;if CHAR is blank
                MOV     AH,6
                MOV     DL,13
                INT     21H     ;;display cariage return
                MOV     DL,10
                INT     21H     ;;display line feed
        ELSE
                MOV     DL,CHAR ;;display CHAR
                MOV     AH,6
                INT     21H
        ENDIF
        POP     DX              ;;restore registers
        POP     AX
        ENDM
;;
;;the _KEY macro reads a key without echo and returns the ASCII code in AL
;;the _KEY ECHO macro reads a key with echo and returns the ASCII code in AL
;;Carry = 1 for extended ASCII
;;Carry = 0 for regular ASCII
;;AH is destroyed
;;
_KEY    MACRO   VAR
        LOCAL   K1,K2
        PUSH    DX
        IFB     <VAR>
K1:
                MOV     AH,6            ;;read without echo
                MOV     DL,0FFH
                INT     21H
                JZ      K1
        ELSE
                MOV     AH,1            ;;read with echo
                INT     21H
        ENDIF
                CMP     AL,0            ;;test for extended
                CLC
                JNZ     K2
                INT     21H             ;;get extended
                STC
K2:
        POP     DX
        ENDM
;;
;;the _STRING macro displays the character string addressed by DS:OFFSET 
;;
_STRING MACRO   OFF
        PUSH    AX
        PUSH    DX
        MOV     DX,OFFSET OFF
        MOV     AH,9
        INT     21H
        POP     DX
        POP     AX
        ENDM
;;
;;the _NUM macros displays an integer of BASE 2 through 36 with or without
;;leading zeros blanked.  If BKL is 1 through 8, a nondecimal number is
;;displayed with the number of digits in BLK   (USES the _DISP macro)
;;
_NUM    MACRO   BASE,BLK
        LOCAL   N1,N2,N3,N4,N5,N6,N7,N8,NS
        IF      BASE GT 1 AND BASE LT 37
                PUSH    EAX             ;;save registers
                PUSH    EBX
                PUSH    CX
                PUSH    EDX
                MOV     EBX,BASE        ;;load number base
                PUSH    BX              ;;save end indicator
                        IFB     <BLK>
                                MOV     CX,0
                        ELSE    
                                MOV     CX,BLK
                        ENDIF
                                CMP     CX,33
                                JAE     NS
                        IF      BASE NE 10
N1:
                                MOV     EDX,0
                                DIV     EBX
                                ADD     DL,30H          ;;convert to ASCII
                                CMP     DL,3AH
                                JB      N2
                                ADD     DL,7
N2:
                                PUSH    DX              ;;save remainder
                                CMP     CX,0
                                JE      N3              ;;if blanked     
                                LOOP    N1              ;;repeat
                                JMP     N4              ;;when done
N3:
                                CMP     EAX,0
                                JNZ     N1              ;;keep dividing:
N4:
                        ENDIF
                        IF      BASE EQ 10
                                CMP     EAX,80000000H
                                JB      N5              ;;if positive
                                NEG     EAX
                                _DISP   '-'             ;;show minus
N5:
                                MOV     CX,3            ;;comma count
N6:
                                MOV     EDX,0
                                DIV     EBX             ;;divide by 10
                                ADD     DL,30H          ;;make ASCII
                                PUSH    DX              ;;save remainder
                                CMP     EAX,0
                                JE      N7              ;;if finished
                                LOOP    N6
                                PUSH    ','             ;;save comma
                                JMP     N5              ;;repeat
N7:
                        ENDIF
N8:
                POP     DX
                CMP     DX,BX
                JE      NS              ;;if finished
                _DISP   DL
                JMP     N8
NS:                     
                POP     EDX             ;restore registers
                POP     CX
                POP     EBX
                POP     EAX
        ENDIF
        ENDM
;;
;;the _INUM BASE macro reads a number in number BASE 2 through 36.  The 
;;result is returned in EAX.  ***USES _KEY and _DISP***
;;
_INUM   MACRO   BASE
        LOCAL   I1,I2,I3,I4
        IF      BASE GT 1 AND BASE LT 37
        PUSH    EDX
        MOV     EAX,0
        MOV     EDX,0
I1:        
        _KEY
        JC      I1      ;;if extended ASCII
        CMP     AL,'a'
        JB      I2
        CMP     AL,'z'
        JA      I2
        SUB     AL,20H     ;;make uppercase
I2:     MOV     AH,AL
        SUB     AL,30H
        JB      I4      ;;if below zero end it
        CMP     AL,0AH
        JB      I3      ;iif number
        SUB     AL,7    ;;if letter
I3:
        CMP     AL,BASE      
        JAE     I1      ;;if invalid digit
        _DISP   AH      ;;display digit
        MOV     AH,0
        PUSH    EAX
        MOV     AL,BASE
        MUL     EDX
        MOV     EDX,EAX
        POP     EAX
        ADD     EDX,EAX
        JMP     I1      ;;get next character
I4:
        MOV     EAX,EDX
        POP     EDX
        ENDIF
        ENDM
;;
;;the _BLOCK macro function in mode 12H to display a block that is 8 PELs
;;wide and 9 PELs high.  X = row (0--52), Y = column (0--79), and 
;;CO = color (0--15).
;;
_BLOCK  MACRO   X,Y,CO
        LOCAL   B1
        PUSH    DS
        PUSHA
        MOV     AL,X            ;;get paramters
        MOV     DL,Y
        MOV     BL,CO
        MOV     AH,0
        MOV     CX,80*9         ;;find memory byte location
        PUSH    DX
        MUL     CX
        POP     DX
        MOV     DH,0
        ADD     AX,DX
        MOV     DI,AX
        MOV     AX,0A000H        ;;address video segment
        MOV     DS,AX
        MOV     DX,3CEH         ;;set all mask bits
        MOV     AX,0FF08H
        OUT     DX,AX
        MOV     BH,0FFH
        MOV     CX,9
        MOV     DX,3C4H         ;;enable all planes
B1:        
        MOV     AX,0F02H
        OUT     DX,AX
        INC     DX
        MOV     AL,[DI]         ;;read byte
        MOV     BYTE PTR [DI],0
        MOV     AL,BL
        OUT     DX,AL
        MOV     [DI],BH
        ADD     DI,80
        DEC     DX
        LOOP    B1
        POPA
        POP     DS
        ENDM
;;
;;the _DOT macro displays a single dot on the mode 12H video display
;;X = row (0--479)
;;Y = column (0--639)
;;CO = color (0--15)
;;
_DOT    MACRO   X,Y,CO
        PUSH    DS
        PUSHA
        MOV     AX,X            ;;get parameters
        MOV     BP,Y
        MOV     BL,CO           
        MOV     CX,80           ;;find byte
        MUL     CX
        MOV     DI,AX
        MOV     AX,BP
        MOV     CX,8
        DIV     CX
        ADD     DI,AX
        MOV     AH,80H
        MOV     CX,DX
        SHR     AH,CL           ;;find mask
        MOV     DX,3CEH         ;;set all mask bits
        MOV     AL,08H
        OUT     DX,AX
        MOV     AX,0A000H       ;address video segment
        MOV     DS,AX
        MOV     BH,0FFH
        MOV     DX,3C4H         ;;enable all planes
        MOV     AX,0F02H
        OUT     DX,AX
        INC     DX
        MOV     AL,[DI]         ;;read byte
        MOV     BYTE PTR [DI],0
        MOV     AL,BL
        OUT     DX,AL
        MOV     [DI],BH
        POPA
        POP     DS
        ENDM
;;
;;the _BAND macro display a color band across the screen that is one block
;;high.
;;X = row (0--52)
;;CO = color
;;
_BAND   MACRO   X,CO
        LOCAL   B1
        PUSH    DS
        PUSHA
        MOV     AX,X
        MOV     BL,CO
        MOV     CX,80*9
        MUL     CX
        MOV     DI,AX
        MOV     AX,0A000H
        MOV     DS,AX
        MOV     DX,3CEH         ;;set all mask bits
        MOV     AX,0FF08H
        OUT     DX,AX
        MOV     CX,9*80
B1:
        MOV     DX,3C4H         ;;enable all planes
        MOV     AX,0F02H
        OUT     DX,AX
        INC     DX
        MOV     BH,-1
        MOV     AL,[DI]         
        MOV     BYTE PTR [DI],0
        MOV     AL,BL
        OUT     DX,AL
        MOV     [DI],BH
        DEC     DX
        INC     DI
        LOOP    B1
        POPA
        POP     DS
        ENDM
;;
;;the _SCREEN macro changes the screen to color CO
;;
_SCREEN MACRO   CO
        LOCAL   B1
        PUSH    DS
        PUSHA
        MOV     BL,CO
        MOV     BH,-1
        MOV     DI,0
        MOV     AX,0A000H
        MOV     DS,AX
        MOV     DX,3CEH         ;;set all mask bits
        MOV     AX,0FF08H
        OUT     DX,AX
        MOV     CX,80*9*53
B1:
        MOV     DX,3C4H         ;;enable all planes
        MOV     AX,0F02H
        OUT     DX,AX
        INC     DX
        MOV     AL,[DI]         
        MOV     BYTE PTR [DI],0
        MOV     AL,BL
        OUT     DX,AL
        MOV     [DI],BH
        DEC     DX
        INC     DI
        LOOP    B1
        POPA
        POP     DS
        ENDM
;;
;;the _CHAR macro displays a 8x8 character on the mode 12H display
;;CO = color (0--15)
;;X = row (0--52)
;;Y = column (0-79)
;;CHAR = character to be displayed
;;
_CHAR   MACRO   X,Y,CHAR,CO
        LOCAL   B1
        PUSH    DS
        PUSH    ES
        PUSHA
        MOV     BH,CHAR
        MOV     AL,X            ;;get paramters
        MOV     DL,Y
        MOV     BL,CO
        PUSH    AX    
        PUSH    BX
        PUSH    DX
        MOV     AX,1130H
        MOV     BH,3
        INT     10H             ;;get character set
        POP     DX
        POP     BX
        PUSH    BX
        MOV     BL,BH
        MOV     BH,0
        SHL     BX,3
        ADD     BP,BX
        POP     BX
        POP     AX
        MOV     CX,80*9         ;;find memory byte location
        PUSH    DX
        MOV     AH,0
        MUL     CX
        POP     DX
        MOV     DH,0
        ADD     AX,DX
        MOV     DI,AX
        MOV     AX,0A000H        ;;address video segment
        MOV     DS,AX
        MOV     CX,8
B1:
        MOV     DX,3CEH         ;;set mask bits
        MOV     AL,08H
        MOV     AH,ES:[BP]
        INC     BP
        OUT     DX,AX
        MOV     BH,-1
        MOV     DX,3C4H         ;;enable all planes
        MOV     AX,0F02H
        OUT     DX,AX
        INC     DX
        MOV     AL,[DI]         ;;read byte
        MOV     BYTE PTR [DI],0
        MOV     AL,BL
        OUT     DX,AL
        MOV     [DI],BH
        ADD     DI,80
        LOOP    B1
        POPA
        POP     ES
        POP     DS
        ENDM
;;
;;the _VSTR macro displays the character string at DS:OFF
;;***USES _CHAR macro
;;
_VSTR   MACRO   X,Y,OFF,CO
        LOCAL   V1,V2
        PUSH    AX
        PUSH    CX
        PUSH    SI
        MOV     CL,Y
        MOV     SI,OFFSET OFF          ;address string
V1:        
        MOV     AL,[SI]
        CMP     AL,0
        JE      V2
        _CHAR   X,CL,AL,CO
        INC     SI
        INC     CL
        JMP     V1
V2:
        POP     SI
        POP     AX
        ENDM
;;
;;the _DISK macro performs READ, WRITE, OPEN, CLOSE, and CREATE functions
;;
;;OP = READ, WRITE, OPEN, CLOSE, CREATE, or EOF for end of file
;;HAN = data segment address of handle
;;BUFFER = address of buffer or file name address
;;COUNT = count
;;
_DISK   MACRO   OP,HAN,BUF,COUNT
        IFIDNI  <OP>,<CREATE>
                MOV     AH,3CH
                MOV     CX,0
                MOV     DX,OFFSET BUF
                INT     21H
                MOV     HAN,AX
        ELSEIFIDNI <OP>,<OPEN>
                MOV     AX,3D02H
                MOV     DX,OFFSET BUF
                INT     21H
                MOV     HAN,AX
        ELSEIFIDNI <OP>,<CLOSE>        
                MOV     AH,3EH
                MOV     BX,HAN
                INT     21H
        ELSEIFIDNI <OP>,<READ>
                MOV     AH,3FH
                MOV     BX,HAN
                MOV     CX,COUNT
                MOV     DX,OFFSET BUF
                INT     21H
        ELSEIFIDNI <OP>,<WRITE>
                MOV     AH,40H
                MOV     BX,HAN
                MOV     CX,COUNT
                MOV     DX,OFFSET BUF
                INT     21H
        ELSEIFIDNI <OP>,<EOF>
                MOV     AX,4202H
                MOV     BX,HAN
                MOV     CX,0
                MOV     DX,0
                INT     21H
        ENDIF
        ENDM
;;
;;the _MOUSE macro performs mouse services
;;
;;OP = ON, enables mouse
;;OP = TEST, tests for a mouse ***CARRY = 1 for no mouse***
;;OP = OFF, disables mouse
;;OP = BUTTON, reads mouse buttons
;;     BUT = which button (RIGHT, LEFT, MIDDLE)
;;      AX = button status, DX = vert, CX = horiz
;;OP = STATUS, reads mouse status
;;
_MOUSE  MACRO   OP,BUT
        LOCAL   M1
        PUSH    BX
        IFIDNI  <OP>,<TEST>        
                MOV     AX,3533H        ;;get INT 33H vector
                INT     21H             ;;returns vector in ES:BX
                                        
                MOV     AX,ES
                OR      AX,BX           ;;test for 0000:0000
                STC
                JZ      M1              ;;if no mouse driver
                CMP     BYTE PTR ES:[BX],0CFH   
                STC
                JE      M1              ;;if no mouse driver
                MOV     AX,0
                INT     33H             ;;reset mouse
                CMP     AX,0
                STC                     
                JZ      M1              ;;if no mouse
                CLC
M1:
        ELSEIFIDNI <OP>,<ON>           
                MOV     AX,1            ;;enable mouse       
                INT     33H
        ELSEIFIDNI <OP>,<OFF>
                MOV     AX,2            ;;disable mouse
                INT     33H
        ELSEIFIDNI <OP>,<BUTTON>
                MOV     AX,5            ;;get buttton press info
                IFIDNI  <BUT>,<LEFT>
                        MOV     BX,0
                ELSEIFIDNI   <BUT>,<RIGHT>
                        MOV     BX,1
                ELSEIFIDNI   <BUT>,<MIDDLE>
                        MOV     BX,2
                ENDIF
                INT     33H
        ELSEIFIDNI <OP>,<STATUS>
                MOV     AX,3
                INT     33H
        ENDIF
        POP     ES
        ENDM
