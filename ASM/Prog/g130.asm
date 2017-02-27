PAGE    40,132
TITLE   G130.ASM

        EXTRN   WORDSR:FAR,COSSIN:FAR,RAND1:FAR,LNLOG:FAR

RANDAT  SEGMENT PARA PUBLIC 'DATA'
        PUBLIC  NUM1,NUM2,NUM3,NCOS,NSIN

NUM1    DW      0
NUM2    DW      0
NUM3    DW      0
NCOS    DW      0
NSIN    DW      0
SSINE   DW      0
CCOSINE DW      0

RANDAT  ENDS
RANDOM  SEGMENT PARA PUBLIC 'CODE'
        PUBLIC  GRAND

GRAND   PROC    FAR
        ASSUME  CS:RANDOM,DS:RANDAT

        PUSH    DS

        MOV     BX,SEG RANDAT
        MOV     DS,BX

        MOV     CX,AX
        CALL    RAND1
        MOV     NUM1,AX
        MOV     CX,AX
        CALL    RAND1
        MOV     NUM2,AX
        MOV     NUM3,AX

        MOV     AX,NUM1
        MOV     BX,656
        MOV     DX,0
        DIV     BX
        MOV     NUM1,AX
        MOV     AX,NUM2
        MOV     BX,183
        MOV     DX,0
        DIV     BX
        MOV     NUM2,AX

        MOV     BX,NUM1
        CALL    LNLOG
        NEG     AX
        SHL     AX,1

        CALL    WORDSR
        MOV     NUM1,AX
        MOV     AX,NUM2
        CALL    COSSIN
        MOV     NSIN,DX
        MOV     NCOS,CX

        MOV     AX,DX
        MOV     CL,15
        SHR     AX,CL
        MOV     CL,9
        CMP     AX,0
        JNA     ELSE1
                SHL     NSIN,1
                MOV     CL,10
                SHR     NSIN,CL
                MOV     SSINE,8000H
        JMP     SHORT _IF1
ELSE1:          SHR     NSIN,CL
                MOV     SSINE,0
_IF1:   MOV     AX,NCOS
        MOV     CL,15
        SHR     AX,CL
        MOV     CL,9
        CMP     AX,0
        JNA     ELSE2
                SHL     NCOS,1
                MOV     CL,10
                SHR     NCOS,CL
                MOV     CCOSINE,8000H
        JMP     SHORT _IF2
ELSE2:          SHR     NCOS,CL
                MOV     CCOSINE,0
_IF2:   MOV     AX,NSIN

        MOV     DX,0
        MOV     BX,NUM1
        IMUL    BX
        MOV     NSIN,AX

        MOV     AX,NCOS

        MOV     DX,0
        IMUL    BX
        MOV     NCOS,AX

        MOV     AX,SSINE
        OR      NSIN,AX
        MOV     AX,CCOSINE
        OR      NCOS,AX

        MOV     CX,NCOS
        MOV     DX,NSIN
        MOV     AX,NUM3

        POP     DS
        RET
GRAND   ENDP

RANDOM  ENDS
        END GRAND
