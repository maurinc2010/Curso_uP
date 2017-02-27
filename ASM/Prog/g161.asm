PAGE    40,132
TITLE   G161 - GRAFICA NUMEROS ALEATORIOS 200 X 200 (G161.ASM)
COMMENT *       DESCRIPCION: Esta rutina genera 25 numeros aleatorios
                y los grafica           *

        EXTRN   GRAND:FAR,BOX1:FAR,TICK1:FAR,CONNL1:FAR
        EXTRN   LLABEL:FAR
STACK   SEGMENT PARA STACK 'STACK'
        DB      64 DUP ('STACK')
STACK   ENDS

DATA    SEGMENT PARA PUBLIC 'DATA'

RN      DW      50 DUP (0)
NUM     DW      24
XSTART  DW      75
XEND    DW      225
SY      DW      37
DDX     DW      0
Y0      DW      0
Y1      DW      0
X0      DW      0
X1      DW      0
DATA    ENDS

CSEG    SEGMENT PARA PUBLIC 'CODE'
PLOTRN  PROC    FAR
        ASSUME CS:CSEG,DS:DATA,SS:STACK

        PUSH    DS
        SUB     AX,AX
        PUSH    AX

        MOV     AX,SEG DATA
        MOV     DS,AX

        MOV     DI,1
        MOV     SI,0
        MOV     AX,1000H

D01:            CALL    GRAND
                MOV     RN[SI],CX
                MOV     RN[SI+2],DX
                ADD     SI,4
                ADD     DI,1
                CMP     DI,25
                JBE     D01
        CALL    BOX1
        CALL    TICK1
        CALL    LLABEL

        MOV     SI,0
        MOV     DI,1

        MOV     AX,XEND
        SUB     AX,XSTART
        MOV     DX,0
        DIV     NUM
        MOV     DDX,AX

D02:    MOV     AX,RN[SI+2]
        MOV     CL,15
        SHR     AX,CL
        CMP     AX,1
        JE      ELSE1
                MOV     AX,RN[SI+2]
                MOV     DX,0
                DIV     SY
                MOV     BX,100
                SUB     BX,AX
                JMP     _IF1

ELSE1:          MOV     AX,RN[SI+2]
                SHL     AX,1
                SHR     AX,1
                MOV     DX,0
                DIV     SY
                MOV     BX,100
                ADD     BX,AX
_IF1:   MOV     Y0,BX
        MOV     AX,DDX
        MOV     DX,0
        MOV     CX,DI
        SUB     CX,11
        MUL     CX
        ADD     AX,XSTART
        MOV     X0,AX

        MOV     AX,RN[SI+4]
        MOV     CL,15
        SHR     AX,CL
        CMP     AX,1
        JE      ELSE2
                MOV     AX,RN[SI+4]
                MOV     DX,0
                DIV     SY
                MOV     BX,100
                SUB     BX,AX
                JMP     _IF2

ELSE2:          MOV     AX,RN[SI+4]
                SHL     AX,1
                SHR     AX,1
                MOV     DX,0
                DIV     SY
                MOV     BX,100
                ADD     BX,AX

_IF2:   MOV     Y1,BX
        MOV     AX,X0
        ADD     AX,DDX
        MOV     X1,AX

        MOV     DH,BYTE PTR Y0
        MOV     DL,BYTE PTR Y1
        MOV     BX,X0
        MOV     CX,X1
        CALL    CONNL1

        ADD     SI,2
        INC     DI
        MOV     AX,NUM
        ADD     AX,1
        CMP     DI,AX
        JA      LOUT
        JMP     D02

LOUT:   MOV     AH,0
        INT     16H

        MOV     AH,0
        MOV     AL,2
        INT     10H
        RET
PLOTRN  ENDP
CSEG    ENDS
        END     PLOTRN

