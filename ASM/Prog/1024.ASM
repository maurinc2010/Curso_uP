PAGE    40,132
TITLE  BOX320 - DIBUJA UN MARCO DE 150 X 150
COMMENT *       DESCRIPCION: Esta rutina dibuja un marco
                de 150 x 150 con marca de divisiones.*
;
DATBOX  SEGMENT PARA PUBLIC 'DATA'
        PUBLIC  XBEG,XEND,YBEG,YEND,XT,YT,XMAX,XMIN,YMAX
        PUBLIC YMIN,X,Y,COUNT
                                ;
XBEG    DW      75             ;Esquinas del marco
x1      dw      100
X2      DW      125
x3      dw      150
X4      DW      175
x5      dw      200
XEND    DW      225
YBEG    DW      75
y1      dw      100
Y2      DW      125
y3      dw      150
Y4      DW      175
y5      dw      200
YEND    DW      225
XT      DW      105,135,165,195 ;Marca de divisiones del eje X
YT      DW      100             ;Marca de divisiones del eje Y
XMAX    Dw      77              ;Longitud entre marcas
XMIN    DW      73
YMAX    DW      177
YMIN    DW      173
Y       DW      0               ;Variables ficticias (dummy)
X       DW      0
COUNT   DW      6               ;N£mero de marcas horizontales + 1
MODE    DB      ?
DATBOX  ENDS

CBOX    SEGMENT PARA PUBLIC 'CODE'
        PUBLIC BOX1,TICK1
BOX1    PROC    FAR
        ASSUME  CS:CBOX,DS:DATBOX
        CALL    IMODE
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

        MOV     AH,4FH         ;Selecii¢n del modo de video
        MOV     AL,02H         ;AH=4F HI RES, AL=02
        MOV     BH,01H
        MOV     BL,00H        ;BL=00 .. 05 -> 640X480 800X600 1024X800
        INT     10H

        MOV     AX,YBEG
        MOV     Y,AX
        CALL    LINEH
        MOV     AX,YBEG
        MOV     Y,AX
        CALL    LINEH
        mov     ax,y1
        MOV     Y,AX
        CALL    LINEH
        MOV     AX,Y2
        MOV     Y,AX
        CALL    LINEH
        MOV     AX,Y3
        MOV     Y,AX
        CALL    LINEH
        mov     ax,y4
        MOV     Y,AX
        CALL    LINEH
        mov     ax,y5
        MOV     Y,AX
        CALL    LINEH
        MOV     AX,YEND
        MOV     Y,AX
        CALL    LINEH

        MOV     AX,XBEG
        MOV     X,AX
        CALL    LINEV
        mov     ax,x1
        MOV     X,AX
        CALL    LINEV
        MOV     AX,X2
        MOV     X,AX
        CALL    LINEV
        MOV     AX,X3
        MOV     X,AX
        CALL    LINEV
        mov     ax,x4
        MOV     X,AX
        CALL    LINEV
        mov     ax,x5
        MOV     X,AX
        CALL    LINEV
        MOV     AX,XEND
        MOV     Y,AX
        MOV     X,AX
        CALL    LINEV
        MOV     AX,Y2
        MOV     Y,AX
        MOV     AX,X2
        MOV     X,AX
        call    MIRRE

        POP     DS
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

        MOV     DX,Y
        MOV     CX,XBEG
D02:
                MOV     AH,12   ; 12 para desplear pixeles
                MOV     AL,2    ; 1  para atributos del pixel
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
                MOV     AL,6
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
        MOV     AH,0FH
        INT     10H
        MOV     MODE,AL
        MOV     AH,00H
        MOV     AL,03
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
;-------------------------------------------------------------
MIRRE   PROC    NEAR

        MOV     DX,Y
D06:    MOV     CX,X
D05:
                MOV     AH,12   ; 12 para desplear pixeles
                MOV     AL,5    ; 1  para atributos del pixel
                INT     10H
                ADD     CX,1
                CMP     CX,X4
                JNE     D05
                ADD     DX,1
                CMP     DX,Y4
                JNE     D06
        RET
MIRRE   ENDP

;-------------------------------------------------------------
CBOX    ENDS
        END     BOX1

