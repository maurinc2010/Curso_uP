;
;               UPTC SECCIONAL SOGAMOSO
;             CURSO DE MICROPROCESADORES
;             ING. WILSON JAVIER PEREZ H.
;                 29 DE MAYO DE 2002
;SANDRO JAVIER MORENO PRECIADO COD. 49965422 

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
        CALL    C7DISP
        CALL    C8DISP
        CALL    C9DISP
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
        MOV     BL,02H
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
        INC     DX
        CMP     DX,200
        JNE     C20
        MOV     DX,50
        INC     BL
        INC     CX
        CMP     CX,250
        JNE     C20
        RET
C10DISP ENDP

C9DISP  PROC    NEAR
        MOV     BX,00H
        MOV     CX,50
        MOV     DX,300

C15:    MOV     AH,0CH
        MOV     AL,BL
        INT     10H
        INC     CX
        CMP     CX,250
        JNE     C15
        MOV     CX,50
        INC     BL
        INC     DX
        CMP     DX,450
        JNE     C15
        RET
C9DISP  ENDP

C8DISP  PROC    NEAR
        MOV     BX,00H
        MOV     CX,300
        MOV     DX,50

C14:    MOV     AH,0CH
        MOV     AL,BL
        INT     10H
        INC     CX
        CMP     CX,500
        JNE     C14
        MOV     CX,300
        INC     BL
        INC     DX
        CMP     DX,200
        JNE     C14
        RET
C8DISP  ENDP

C7DISP  PROC    NEAR
        MOV     BX,00H
        MOV     CX,300
        MOV     DX,300

C13:    MOV     AH,0CH
        MOV     AL,BL
        INT     10H
        INC     DX
        CMP     DX,450
        JNE     C13
        MOV     DX,300
        INC     BL
        INC     CX
        CMP     CX,500
        JNE     C13
        RET
C7DISP  ENDP

D10KEY  PROC    NEAR
        MOV     AH,10H
        INT     16H
        RET
D10KEY  ENDP
        END     BEGIN

