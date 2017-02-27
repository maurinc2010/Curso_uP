TITLE   A166 (COM) INT 10H para desplegar el conjunto de caracteres ASCII
        .MODEL  SMALL
        .CODE
        ORG     100H
BEGIN:  JMP     SHORT   MAIN
CTR     DB      00
COL     DB      24
ROW     DB      04
MODE    DB      ?

MAIN    PROC    NEAR
        CALL    B10MODE
        CALL    C10CLR
A20:
        CALL    D10SET
        CALL    E10DISP
        CMP     CTR,0FFH
        JE      A30
        INC     CTR
        ADD     COL,02
        CMP     COL,56
        JNE     A20
A30:
        CALL    F10READ
        CALL    G10MODE
        MOV     AX,4C00H
        INT     21H
MAIN    ENDP

B10MODE PROC    NEAR
        MOV     AH,0FH
        INT     10H
        MOV     MODE,AL
        MOV     AH,00H
        MOV     AL,03
        INT     10H
        RET
B10MODE ENDP

C10CLR  PROC    NEAR
        MOV     AH,08H
        INT     10H
        MOV     BH,AH
        MOV     AX,0600H
        MOV     CX,0000
        MOV     DX,184FH
        INT     10H
        MOV     AX,0610H
        MOV     BH,17H
        MOV     CX,0418H
        MOV     DX,1336H
        INT     10H
        RET
C10CLR  ENDP

D10SET  PROC    NEAR
        MOV     AH,02H
        MOV     BH,00
        MOV     DH,ROW
        MOV     DL,COL
        INT     10H
        RET
D10SET  ENDP

E10DISP PROC    NEAR
        MOV     AH,0AH
        MOV     AL,CTR
        MOV     BH,00
        MOV     CX,01
        INT     10H
        RET
E10DISP ENDP

F10READ PROC    NEAR
        MOV     AH,10H
        INT     16H
        RET
F10READ ENDP

G10MODE PROC    NEAR
        MOV     AH,00H
        MOV     AL,MODE
        INT     10H
        RET
G10MODE ENDP
        END     BEGIN

