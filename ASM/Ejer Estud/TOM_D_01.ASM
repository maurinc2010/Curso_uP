;
;               UPTC SECCIONAL SOGAMOSO
;             CURSO DE MICROPROCESADORES
;             ING. WILSON JAVIER PEREZ H.
;               CRAKEADO POR TOMAS BARRERA Y DIANA MORENO
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
        CALL    D10KEY
        POP     AX
        MOV     AH,00H
        INT     10H
        MOV     AX,4C00H
        INT     21H
BEGIN   ENDP

B10MODE PROC    NEAR
        MOV     AH,00H     ;00H ESTABLECE EL MODO DE VIDEO
        MOV     AL,12H
        INT     10H
        MOV     AH,0BH
        MOV     BH,00H
        MOV     BL,01H
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
        CMP     CX,300
        JNE     C20
        MOV     CX,50
        INC     BL
        INC     DX
        CMP     DX,200
        JNE     C20
        MOV     BX,00H          ;------
        MOV     CX,50
        MOV     DX,250
C21:    MOV     AH,0CH
        MOV     AL,BL
        INT     10H
        INC     CX
        CMP     CX,590
        JNE     C21
        MOV     CX,320
        INC     BL
        INC     DX
        CMP     DX,390
        JNE     C21
                                ;------------
        MOV     BX,00H
        MOV     CX,50
        MOV     DX,250
C22:    MOV     AH,0CH
        MOV     AL,BL
        INT     10H
        INC     DX
        CMP     DX,390
        JNE     C22
        MOV     DX,250
        INC     CX
        INC     BL
        CMP     CX,300
        JNE     C22

        MOV     BX,00H
        MOV     CX,320
        MOV     DX,50
C23:    MOV     AH,0CH
        MOV     AL,BL
        INT     10H
        INC     DX
        CMP     DX,200
        JNE     C23
        MOV     DX,50
        INC     CX
        INC     BL
        CMP     CX,590
        JNE     C23

        RET
C10DISP ENDP

D10KEY  PROC    NEAR
        MOV     AH,10H
        INT     16H
        RET
D10KEY  ENDP
        END     BEGIN

