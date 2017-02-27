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

STACK   SEGMENT PARA STACK 'STACK'
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


