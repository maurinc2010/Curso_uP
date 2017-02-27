;DUVAN MEJIA
;LILIANA CAMARGO


PAGE    40,132
TITLE   CLINE2 - VERIFICA GRAFICA DE LINEAS (CLINE1.ASM)
COMMENT *       DESCRIPCION:
                Esta rutina llama a BOX320.ASM, CONNL1.ASM
                y comprueba su operaci¢n.    *

        EXTRN BOX1:FAR,TICK1:FAR,CONNL1:FAR ;Hace la declarac¡on de
                                            ;invocaci¢n a procedimientos
                                            ;externos

STACK   SEGMENT PARA STACK 'STACK'          
        DB      64 DUP ('STACK')
STACK   ENDS

SEGCOD  SEGMENT PARA PUBLIC 'CODE'
CC_LIN  PROC    FAR
        ASSUME  CS:SEGCOD,SS:STACK

        PUSH    DS
        SUB     AX,AX
        PUSH    AX

        CALL    BOX1            ;Dibuja el rectangulo
        CALL    TICK1           ;Dibuja marcas
        MOV     DH,175          ;YSTART
        MOV     DL,25           ;YEND
        MOV     CX,225          ;XEND
        MOV     BX,75           ;XSTART
        CALL    CONNL1

        MOV     CX,225
        MOV     BX,75
        MOV     DH,25
        MOV     DL,175
        CALL    CONNL1
;*******************************
        MOV     DH,100          ;YSTART
        MOV     DL,25           ;YEND
        MOV     CX,150          ;XEND
        MOV     BX,75           ;XSTART
        CALL    CONNL1

        MOV     CX,225
        MOV     BX,150
        MOV     DH,25
        MOV     DL,100
        CALL    CONNL1

        MOV     DH,175          ;YSTART
        MOV     DL,100           ;YEND
        MOV     CX,225          ;XEND
        MOV     BX,150           ;XSTART
        CALL    CONNL1

        
        MOV     CX,150
        MOV     BX,75
        MOV     DH,100
        MOV     DL,175
        CALL    CONNL1

;******************************

        MOV     DH,174          ;YSTART
        MOV     DL,137           ;YEND
        MOV     CX,187          ;XEND
        MOV     BX,149           ;XSTART
VOLVER: CALL    CONNL1
        dec     dh
        dec     dl
        dec     cx
        dec     bx
        cmp     dh,137
        ja      VOLVER

;******************************

        MOV     AH,0            ;Interrupci¢n de teclado para detener
        INT     16H             ;la panatalla. Origina una pausa para poder
                                ;observar el efecto del programa hasata que
                                ;se detecte una se¤al de teclado

        MOV     AH,0
        MOV     AL,2            ;Rtorna al modo 80x25
        INT     10H
        RET
CC_LIN  ENDP
SEGCOD  ENDS
        END     CC_LIN
