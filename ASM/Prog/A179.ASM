TITLE   A179 (COM) Despliegue gr fico
        .MODEL SAMLL
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

