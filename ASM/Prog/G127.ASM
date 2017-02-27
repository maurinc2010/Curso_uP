PAGE    40,132
TITLE   G127
COMMENT *
                *
RND     SEGMENT PARA PUBLIC 'CODE'
        PUBLIC  RAND1
RAND1   PROC    FAR
        ASSUME  CS:RND

        MOV     DX,0

        MOV     AX,CX
        MOV     BX,2053
        MUL     BX
        MOV     BX,13849
        CLC
        ADD     AX,BX

        ADC     DX,0
        MOV     BX,0FFFFH
        DIV     BX
        MOV     AX,DX
        RET

RAND1   ENDP
RND     ENDS
        END RAND1
