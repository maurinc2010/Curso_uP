;PAGE    60,132
;TITLE   COMPARACION ASM   "COMPARA UN DATO CON UNA LISTA DE DATOS" 
;---------------------
MENSAGE MACRO MENSA
        MOV AH, 09H
        LEA DX, MENSA
        INT 21H
        ENDM
;-----------------------------------
STACK   SEGMENT PARA STACK 'STACK'
        DB      64 DUP ('STACK')
STACK   ENDS
;-----------------------------------
DATA    SEGMENT PARA PUBLIC 'DATA'
MEN1    DB ' MI DATO ES 05                                      ',13,10,'$'
MEN2    DB ' EL NUMERO DE VECES REPETIDAS SON:                  ',13,10,'$'

TABLA   DB 05H, 05H, 0AH, 09H
DATO    DB 05H
CUENTA  DB 30H 
DATA    ENDS
;-----------------------------------
CODE    SEGMENT PARA PUBLIC 'CODE'
MAIN    PROC FAR
        ASSUME CS:CODE,DS:DATA,ES:DATA,SS:STACK

        MOV AX, DATA           
        MOV DS, AX
        MOV ES, AX    

        MOV SI,0FFFFH
        MOV DI,00H 
SALTO:  INC SI
        MOV AL,[ TABLA + SI ]
        CMP SI, 04H
        JZ SAL
        CMP DATO,AL
        JZ SALTO
        INC CUENTA
        JMP SALTO

SAL:    ;MENSAGE MEN1 
        ;MENSAGE MEN2 
        MOV AH, 02H
        MOV AL, CUENTA
        MOV DL, AL
        INT 21H

        MOV AH, 4CH     ;TERMINAR
        INT 21H         ;DEL DOS
        RET
MAIN    ENDP
CODE    ENDS
        END
