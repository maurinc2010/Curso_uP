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
        PUBLIC  XBEG,XEND,YBEG,YEND,XT,YT,XMAX,XMIN,YMAX
        PUBLIC YMIN,X,Y,COUNT
                                ;
XBEG    DW      75              ;Esquinas del marco
XEND    DW      225
YBEG    DW      25
YEND    DW      175
;XT      DW      105,135,165,195 ;Marca de divisiones del eje X
XT      DW      150 			;Marca de divisiones del eje X
YT      DW      100             ;Marca de divisiones del eje Y
XMAX    Dw      77              ;Longitud entre marcas
XMIN    DW      73
YMAX    DW      177
YMIN    DW      173
Y       DW      0               ;Variables ficticias (dummy)
X       DW      0
COUNT   DW      6               ;N£mero de marcas horizontales + 1
DATBOX  ENDS

CBOX    SEGMENT PARA PUBLIC 'CODE'
        PUBLIC BOX1,TICK1
BOX1    PROC    FAR
        ASSUME  CS:CBOX,DS:DATBOX

        PUSH    DS
                                ;
        MOV     AX,SEG DATBOX
        MOV     DS,AX
                                ;Este procedimiento dibuja el rectangulo
                                ;limpia la pantalla
        MOV     AH,6            ;Cambio (scroll) de pagina
        MOV     AL,0            ;Pone en blanco toda la ventana
        MOV     CX,0            ;Inicia esquina superior izquierda
        MOV     DH,23           ;Esquina inferior derecha
        MOV     DL,79
        MOV     BH,7            ;Atributo blanco sobre negro
        INT     10H
        MOV     AH,0
        MOV     AL,5
        INT     10H

        MOV     AX,YBEG
        MOV     Y,AX
        CALL    LINEH
        MOV     AX,YEND
        MOV     Y,AX
        CALL    LINEH

        MOV     AX,XBEG
        MOV     X,AX
        CALL    LINEV
        MOV     AX,XEND
        MOV     Y,AX
        MOV     X,AX
        CALL    LINEV

        POP     DS
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

        MOV     DX,Y
        MOV     CX,XBEG
D02:
                MOV     AH,12
                MOV     AL,1
                INT     10H
                ADD     CX,1
                CMP     CX,XEND
                JNE     D02
        RET
LINEH   ENDP
                
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

CBOX    ENDS
        END     BOX1
