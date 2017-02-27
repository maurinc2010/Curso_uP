PAGE 40,132

;               UPTC SECCIONAL SOGAMOSO
;             CURSO DE MICROPROCESADORES
;             ING. WILSON JAVIER PEREZ H.
;                 27 DE MAYO DE 2002

TITLE   CONNL1.ASM - DIBUJO DE LINEAS UNIDAS
COMMENT *       DESCRIPCION:
                La rutina usa los siguientes datos para dibujar una
                l¡nea continua entre los puntos (XSTART,YSTART) y
                (XEND,YEND):DX=(YSTART,YEND),BX=XSTART y CX=XEND.
                                                                *
DLINE   SEGMENT PARA PUBLIC 'DATA'
Y0      DW      0       ;Y inicial
Y       DW      0       ;Y din mica
Y1      DW      0       ;Y final
X0      DW      0       ;X inicial
X       DW      0       ;X dinamica
X1      DW      0       ;X final
NCOUNT  DW      0       ;N£mero de puntos en la l¡nea
SIGN    DW      0       ;Signo de la pendiente
M       DW      0
DLINE   ENDS

CLINE   SEGMENT PARA PUBLIC 'CODE'
        PUBLIC  CONNL1               ;Declarado como procedimiento PUBLIC,
                                     ;lo que permite que sea invocado por
                                     ;otros programas
CONNL1  PROC    FAR
        ASSUME  CS:CLINE,DS:DLINE

        PUSH    DS
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        PUSH    DI
        PUSH    SI

        MOV     AX,SEG DLINE
        MOV     DS,AX
                                      ;Carga coordenadas de la pantalla  
        MOV     AL,DH                 ;DH contiene YSTART  
        MOV     AH,0                  ;Limpia la mitad superior de AX
        MOV     Y0,AX                 ;Punto inicial de Y
        MOV     Y,AX                  ;Tambien se salva YSTART en Y
        MOV     AL,DL                 ;DL contine YEND
        MOV     AH,0                  ;Limpia la mitad superior de AX
        MOV     Y1,AX                 ;Punto final de Y
        MOV     X0,BX                 ;Punto inicial de X
        MOV     X,BX                  ;Salva XSTART en X
        MOV     X1,CX                 ;Punto final de X

                                      ;Genera indice de cuenta
        MOV     AX,X1
        SUB     AX,X0
        MOV     NCOUNT,AX

        MOV     DX,0

        MOV     AX,Y1
        SUB     AX,Y0
        JB      ELSE1
                MOV     CX,100
                MOV     DX,0

                MUL     CX
                MOV     M,AX
                MOV     AX,1
                MOV     SIGN,AX
                JMP     _IF1
ELSE1:
                MOV     AX,Y0
                SUB     AX,Y1
                MOV     CX,100
                MOV     DX,0
                MUL     CX
                MOV     M,AX
                MOV     AX,0
                MOV     SIGN,AX
_IF1:
DO1:
                MOV     AX,X
                SUB     AX,X0
                MOV     DX,0

                MUL     M
                DIV     NCOUNT

                MOV     CX,100
                CMP     AX,CX
                JB      ELSE2
                        MOV     DX,0
                        DIV     CX
                        JMP     _IF2
ELSE2:
                        MOV     AX,0
_IF2:
                 MOV    BX,SIGN
                 CMP    BX,1
                 JB     ELSE3
                        MOV     BX,Y0
                        ADD     AX,BX
                        JMP     _IF3
ELSE3:
                        MOV     BX,Y0
                        SUB     BX,AX
                        MOV     AX,BX
_IF3:
                MOV     CX,X
                MOV     DX,AX
                MOV     AH,12
                MOV     AL,2
                INT     10H

                INC     X
                MOV     BX,X
                CMP     BX,X1
                JBE     DO1

        POP     SI
        POP     DI
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        POP     DS
        RET
CONNL1  ENDP

CLINE   ENDS
        END     CONNL1


