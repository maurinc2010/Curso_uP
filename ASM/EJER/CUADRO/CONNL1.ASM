PAGE 40,132

;               UPTC SECCIONAL SOGAMOSO
;             CURSO DE MICROPROCESADORES
;             ING. WILSON JAVIER PEREZ H.
;                 27 DE MAYO DE 2002

TITLE   CONNL1.ASM - DIBUJO DE LINEAS UNIDAS
COMMENT *       DESCRIPCION:
                La rutina usa los siguientes datos para dibujar una
                l¡nea continua entre los ountos (XSTART,YSTART) y
                (XEND,YEND):DX=(YSTART,YEND),BX=XSTART y CX=XEND.
                                                                *
DLINE   SEGMENT PARA PUBLIC 'DATA'
Y0      DW      0
Y       DW      0
Y1      DW      0
X0      DW      0
X       DW      0
X1      DW      0
NCOUNT  DW      0
SIGN    DW      0
M       DW      0
DLINE   ENDS

CLINE   SEGMENT PARA PUBLIC 'CODE'
        PUBLIC  CONNL1
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

        MOV     AL,DH
        MOV     AH,0
        MOV     Y0,AX
        MOV     Y,AX
        MOV     AL,DL
        MOV     AH,0
        MOV     Y1,AX
        MOV     X0,BX
        MOV     X,BX
        MOV     X1,CX

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


