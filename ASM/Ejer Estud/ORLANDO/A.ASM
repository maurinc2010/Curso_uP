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
        CALL    C12
        CALL    C11
        CALL    C10

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
        MOV     AH,0BH   ;CAMBIAR PALETA DE COLORES
        MOV     BH,00H   ;FONDO DE PANTALLA
        MOV     BL,04H   ;ATRIBUTO DE COLOR
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
        CMP     CX,320
        JNE     C20
        MOV     CX,50
        INC     BL
        INC     DX
        CMP     DX,235
        JNE     C20
        RET
C10DISP ENDP

;;************************************
C10     PROC    NEAR
        MOV     BX,00H
        MOV     CX,330     ;POSICION INICIO COLUMNA
        MOV     DX,245     ;POSICION INICIO RENGLON

C21:    MOV     AH,0CH
        MOV     AL,BL
        INT     10H
        INC     CX
        CMP     CX,600
        JNE     C21
        MOV     CX,330
        INC     BL
        INC     DX
        CMP     DX,430
        JNE     C21
        RET
C10     ENDP

;*************************************
;/////////////////////////////////////

C11     PROC    NEAR
        MOV     BX,00H
        MOV     CX,50
        MOV     DX,245

C22:    MOV     AH,0CH
        MOV     AL,BL
        INT     10H
        INC     DX
        CMP     DX,430
        JNE     C22
        MOV     DX,245
        INC     BL
        INC     CX
        CMP     CX,320
        JNE     C22
        RET
C11     ENDP

;;************************************
C12     PROC    NEAR
        MOV     BX,00H
        MOV     CX,330
        MOV     DX,50

C23:    MOV     AH,0CH
        MOV     AL,BL
        INT     10H
        INC     DX
        CMP     DX,235
        JNE     C23
        MOV     DX,50
        INC     BL
        INC     CX
        CMP     CX,600
        JNE     C23
        RET
C12     ENDP

;*************************************

;/////////////////////////////////////
D10KEY  PROC    NEAR
        MOV     AH,10H
        INT     16H
        RET
D10KEY  ENDP
        END     BEGIN

