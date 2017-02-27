PAGE    40,132
TITLE   CLINE1 - VERIFICA GRAFICA DE LINEAS (CLINE1.ASM)
COMMENT *       DESCRIPCION:
                Esta rutina llama a BOX320.ASM, CONNL1.ASM,COL2.ASM
                y comprueba su operaci¢n.    *

        EXTRN BOX1:FAR,TICK1:FAR,CONNL1:FAR,COL2:FAR     ;Hace la declarac¡on de
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
        ;primera linea
        MOV     DH,175          ;YSTART
        MOV     DL,25           ;YEND
        MOV     CX,225          ;XEND
        MOV     BX,75           ;XSTART
        CALL    CONNL1
        ;segunda linea
        MOV     DH,25           
        MOV     DL,175          
        MOV     CX,225          
        MOV     BX,75           
        CALL    CONNL1
        ;*********************************
        ;primera linea2
        MOV     DH,100          ;YSTART
        MOV     DL,25           ;YEND
        MOV     CX,150          ;XEND
        MOV     BX,75           ;XSTART
        CALL    COL2
        ;segunda linea 2
        MOV     DH,100          
        MOV     DL,175          
        MOV     CX,150          
        MOV     BX,75           
        CALL    COL2

        ;*********************************
        ;primera linea3
        MOV     DH,175          ;YSTART
        MOV     DL,100          ;YEND
        MOV     CX,225          ;XEND
        MOV     BX,150           ;XSTART
        CALL    COL2
        ;segunda linea3
        MOV     DH,25           
        MOV     DL,100          
        MOV     CX,225          
        MOV     BX,150           
        CALL    COL2

        ;*********************************
        MOV     AH,0            ;Interrupci¢n de teclado para detener
        INT     16H             ;la panatalla. Origina una pausa para poder
                                ;observar el efecto del programa hasta que
                                ;se detecte una se¤al de teclado

        MOV     AH,0
        MOV     AL,2            ;Retorna al modo 80x25
        INT     10H
        RET
CC_LIN  ENDP
SEGCOD  ENDS
        END     CC_LIN
