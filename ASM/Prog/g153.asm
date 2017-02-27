PAGE    40,132

;               UPTC SECCIONAL SOGAMOSO
;             CURSO DE MICROPROCESADORES
;             ING. WILSON JAVIER PEREZ H.
;                 27 DE MAYO DE 2002

TITLE  BOX320 - DIBUJA UN MARCO DE 150 X 150
COMMENT *       DESCRIPCION: Esta rutina dibuja un marco
                de 150 x 150 con marca de divisiones.
                                                      *
                                ;
DATBOX  SEGMENT PARA PUBLIC 'DATA'
        PUBLIC  XBEG,XEND,X2,X3,YBEG,YEND,Y2,Y3,XT,YT,XMAX,XMIN,YMAX
        PUBLIC  YMIN,X,Y,COUNT
                                ;
XBEG    DW      75              ;Esquinas del marco
X2      DW      125
X3      DW      175
XEND    DW      225
YBEG    DW      25
Y2      DW      75
Y3      DW      125
YEND    DW      175
XT      DW      105,135,165,195 ;Marca de divisiones del eje X
YT      DW      100             ;Marca de divisiones del eje Y
XMAX    Dw      77              ;Longitud entre marcas
XMIN    DW      73
YMAX    DW      177
YMIN    DW      173
Y       DW      0               ;Variables ficticias (dummy)
X       DW      0
COUNT   DW      6               ;Numero de marcas horizontales + 1
MODE    DB      ?
DATBOX  ENDS

CBOX    SEGMENT PARA PUBLIC 'CODE'
        PUBLIC  BOX1,TICK1
BOX1    PROC    FAR
        ASSUME  CS:CBOX,DS:DATBOX
        CALL    IMODE

        PUSH    DS
                               
        MOV     AX,SEG DATBOX
        MOV     DS,AX

        MOV     BH,0
        INT     10H

        MOV     AX,YBEG
        MOV     Y,AX
        CALL    LINEH
        MOV     AX,Y2
        MOV     Y,AX
        CALL    LINEH
        MOV     AX,Y3
        MOV     Y,AX
        CALL    LINEH
        MOV     AX,YEND
        MOV     Y,AX
        CALL    LINEH


        MOV     AX,XBEG
        MOV     X,AX
        CALL    LINEV
        MOV     AX,X2
        MOV     X,AX
        CALL    LINEV
        MOV     AX,X3
        MOV     X,AX
        CALL    LINEV
        MOV     AX,XEND
        MOV     Y,AX
        MOV     X,AX
        CALL    LINEV
        POP     DS
        CALL    LEERT
        CALL    LLENAR
        CALL    LEERT
        CALL    RMODE
        CALL    VOLVER
        RET
BOX1    ENDP

TICK1   PROC    FAR
        PUSH    DS

        MOV     AX,SEG DATBOX
        MOV     DS,AX

        MOV     AX,YT
        MOV     Y,AX
        MOV     AX,XMIN
        MOV     XBEG,AX
        MOV     AX,XMAX
        MOV     XEND,AX
        CALL    LINEH

        MOV     AX,YMIN
        MOV     YBEG,AX
        MOV     AX,YMAX
        MOV     YEND,AX
        MOV     SI,0
D01:
                MOV     AX,XT[SI]
                MOV     X,AX
                CALL    LINEV
                ADD     SI,2
                CMP     SI,COUNT
                JBE     D01

        POP     DS
        RET
TICK1   ENDP

LINEH   PROC    NEAR

        MOV     DX,Y            ;Coord Y inicial
        MOV     CX,XBEG         ;Coord X inicial
D02:
                MOV     AH,12
                MOV     AL,1
                INT     10H
                ADD     CX,1
                CMP     CX,XEND  ;Coord X final
                JNE     D02
        RET
LINEH   ENDP

;************************

LLENAR  PROC    NEAR

        MOV     DX,75    ;Coord Y inicial   (75)
LL3:    MOV     CX,125   ;Coord X inicial   (125)
LL2:
                MOV     AH,12
                MOV     AL,2
                INT     10H
                ADD     CX,1
                CMP     CX,175   ;Coord X final  (175)
                JNE     LL2
                ADD     DX,1
                CMP     DX,125   ;Coord Y final  (125)
                JNE     LL3
        RET
LLENAR  ENDP

;*********************
                

LINEV   PROC    NEAR
        MOV     CX,X
        MOV     DX,YBEG
D03:
                MOV     AH,12
                MOV     AL,1
                INT     10H
                ADD     DX,1
                CMP     DX,YEND
                JNE     D03
        RET
LINEV   ENDP

LEERT   PROC    NEAR            ;Causa detenci¢n hasta
        MOV     AH,10H          ;pulsaci¢n de tecla
        INT     16H
        RET
LEERT   ENDP

IMODE   PROC    NEAR            ;Inicializa modo de video
        MOV     AH,0FH          ;Guardar configuraci¢n actual de
        INT     10H             ;video en el
        MOV     MODE,AL         ;registro MODE

        MOV     AH,00H          ;Establecer modo gr fico EGA/VGA
        MOV     AL,12H          ;640x480 16 colores
        INT     10H

        MOV     AH,0BH          ;Designar paleta para
        MOV     BH,00H          ;Fondo
        MOV     BL,00H          ;
        INT     10H

        MOV     AH,0BH          ;Petici¢n de color
        MOV     BH,01           ;Selecci¢n de paleta
        MOV     BL,01           ;Numero 0 (verde, rojo, cafe)
        INT     10H

        RET
IMODE   ENDP

RMODE   PROC    NEAR            ;Retorna modo de video a 
        MOV     AH,00H          ;configuraci¢n original
        MOV     AL,MODE
        INT     10H
        RET
RMODE   ENDP

VOLVER  PROC    NEAR            ;Devuelve el control al DOS
        MOV     AX,4C00H
        INT     21H
        RET
VOLVER  ENDP

CBOX    ENDS
        END     BOX1
