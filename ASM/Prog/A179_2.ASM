TITLE   A179 (COM) Despliegue gr fico
        .MODEL SAMLL

SETSCREEN MACRO
        MOV     AH,00
        MOV     AL,06
        INT     10H
        ENDM

WRITEDOT MACRO
        MOV     AH,12
        MOV     AL,01
        MOV     CX,ANGLE
        ADD     CX,140
        MOV     DH,00
        MOV     DL,TEMP
        INT     10H
        ENDM

STACK   SEGMENT PARA    STACK
        DB      64 DUP ('MYSTACK')
STACK   ENDS

MYDATA  SEGMENT PARA 'DATA'
SINE    DB      00,02,04,05,07,09,11,12,14,16,17,19,21,23,24,26
        DB      28,29,31,33,34,36,38,39,41,42,44,45,47,49,50
        DB      52,53,55,56,57,59,60,62,63,64,66,67,68,70,71
        DB      72,73,74,76,77,78,79,80,81,82,83,84,85,86,87
        DB      88,88,89,90,91,91,92,93,93,94,95,95,96,96,97
        DB      97,97,98,98,99,99,99,99,100,100,100,100,100,100,100
ANGLE   DW      0
TEMP    DB      0
MYDATA  ENDS

        .CODE
        ORG     100H

BEGIN   PROC    NEAR
        MOV     AH,0FH
        INT     10H
        PUSH    AX
        CALL    B10MODE
        CALL    C10DISP
        CALL    D10KEY
        POP     AX
        MOV     AH,00H
        INT     10H
        MOV     AX,4C00H
        INT     21H
BEGIN   ENDP

B10MODE PROC    NEAR
        MOV     AH,00H
        MOV     AL,12H
        INT     10H
        MOV     AH,0BH
        MOV     BH,00H
        MOV     BL,07H
        INT     10H
        RET
B10MODE ENDP

C10DISP PROC    NEAR
        MOV     BX,00H
        MOV     CX,50
        MOV     DX,50

C20:    MOV     AH,0CH
        MOV     AL,BL
        INT     10H
        INC     CX
        CMP     CX,600
        JNE     C20
        MOV     CX,50
        INC     BL
        INC     DX
        CMP     DX,430
        JNE     C20
        RET
C10DISP ENDP

D10KEY  PROC    NEAR
        MOV     AH,10H
        INT     16H
        RET
D10KEY  ENDP
        END     BEGIN




MYCODE  SEGMENT PARA 'CODE'
MYPROC  PROC    FAR
        ASSUME  CS:MYCODE,DS:MYDATA,SS:STACK
        PUSH    DS
        SUB     AX,AX
        PUSH    AX
        MOV     AX,MYDATA
        MOV     DS,AX

        SETSCREEN

AGAIN:  LEA     BX,SINE
        MOV     AX,ANGLE
        CMP     AX,180
        JLE     NEWQUAD
        SUB     AX,180

NEWQUAD:CMP     AX,90
        JLE     SECQUAD
        NEG     AX
        ADD     AX,180
SECQUAD:ADD     BX,AX
        MOV     AL,SINE[BX]
        CMP     ANGLE,180
        JGE     BIGDIS
        NEG     AL
        ADD     AL,100
        JMP     READY

BIGDIS: ADD     AL,99
READY:  MOV     TEMP,AL

        WRITEDOT

        ADD     ANGLE,1
        CMP     ANGLE,360
        JLE     AGAIN

        MOV     AH,07
        INT     21H
        MOV     AH,00
        MOV     AL,03
        INT     10H

        RET

MYPROC  ENDP
MYCODE  ENDS

        END

