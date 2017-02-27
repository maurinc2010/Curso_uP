;
;               UPTC SECCIONAL SOGAMOSO
;             CURSO DE MICROPROCESADORES
;             ING. WILSON JAVIER PEREZ H.
;                 29 DE MAYO DE 2002
;

;Este programa muestra el uso del modo gr fico para el despliegue en
;pantalla de lineas de diferentes colores de acuerdo al incremento de
;una variable de control que determina el atributo del pixel a visualizar

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
        CALL    C9DISP
        CALL    C8DISP
        CALL    C7DISP
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
        MOV     BL,05H
        INT     10H
        RET
B10MODE ENDP

C10DISP PROC    NEAR
        MOV     BX,02H
        MOV     CX,50
        MOV     DX,50

C20:    MOV     AH,0CH
        MOV     AL,BL
        INT     10H
        INC     CX
        CMP     CX,280
        JNE     C20
        MOV     CX,50
        INC     BL
        INC     DX
        CMP     DX,230
        JNE     C20
        RET
C10DISP ENDP
;**********************************
C9DISP PROC    NEAR
        MOV     BX,02H
        MOV     CX,320
        MOV     DX,260

C19:    MOV     AH,0CH
        MOV     AL,BL
        INT     10H
        INC     CX
        CMP     CX,550
        JNE     C19
        MOV     CX,320
        INC     BL
        INC     DX
        CMP     DX,450
        JNE     C19
        RET
C9DISP ENDP

;**************************************
C8DISP PROC    NEAR
        MOV     BX,02H
        MOV     CX,50
        MOV     DX,260

C18:    MOV     AH,0CH
        MOV     AL,BL
        INT     10H
        INC     DX
        CMP     DX,450
        JNE     C18
        MOV     DX,260
        INC     BL
        INC     CX
        CMP     CX,280
        JNE     C18
        RET
C8DISP ENDP

C7DISP PROC    NEAR
        MOV     BX,02H
        MOV     CX,320
        MOV     DX,50

C17:    MOV     AH,0CH
        MOV     AL,BL
        INT     10H
        INC     DX
        CMP     DX,230
        JNE     C17
        MOV     DX,50
        INC     BL
        INC     CX
        CMP     CX,550
        JNE     C17
        RET
C7DISP ENDP




D10KEY  PROC    NEAR
        MOV     AH,10H
        INT     16H
        RET
D10KEY  ENDP
        END     BEGIN

