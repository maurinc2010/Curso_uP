PAGE    40,132
TITLE   CLINE1 - VERIFICA GRAFICA DE LINEAS (CLINE1.ASM)
COMMENT *       DESCRIPCION:
                Esta rutina llama a BOX320.ASM, CONNL1.ASM
                y comprueba su operaci¢n.

        EXTRN BOX1:FAR,TICK1:FAR,CONNL1:FAR
STACK   SEGMENT PARA STACK 'STACK'
        DB      64 DUP ('STACK')
STACK   ENDS

SEGCOD  SEGMENT PARA PUBLIC 'CODE'
CC_LIN  PROC    FAR
        ASSUME  CS:SEGCOD,SS:STACK

        PUSH    DS
        SUB     AX,AX
        PUSH    AX

        CALL    BOX1
        CALL    TICK1
        MOV     DH,175
        MOV     DL,25
        MOV     CX,225
        MOV     BX,75
        CALL    CONNL1

        MOV     CX,225
        MOV     BX,75
        MOV     DH,25
        MOV     DL,175
        CALL    CONNL1

        MOV     AH,0
        INT     16H

        MOV     AH,0
        MOV     AL,2
        INT     10H
        RET
CC_LIN  ENDP
SEGCOD  ENDS
        END     CC_LIN
