PAGE    40,132
TITLE   G112

SQRSEG  SEGMENT PARA PUBLIC 'CODE'
        PUBLIC  WORDSR
WORDSR  PROC    FAR
        ASSUME  CS:SQRSEG

        MOV     CX,AX
        MOV     BX,AX
        SHR     BX,1

DO1:            MOV     DX,0
                DIV     BX
                ADD     AX,BX
                SHR     AX,1
                CMP     AX,BX
                JE      _IF1
                        SUB     BX,AX
                        CMP     BX,1
                        JE      _IF2
                                CMP     BX,1
                                JE      _IF3
                                        MOV     BX,AX
                                        MOV     AX,CX
_IF3:
_IF2:
_IF1:
        JNE     DO1
        RET
WORDSR  ENDP
SQRSEG  ENDS
        END


