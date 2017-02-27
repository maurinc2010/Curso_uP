PAGE    40,132
TITLE   G123

DATA1   SEGMENT PARA PUBLIC 'DATA'
        PUBLIC  CSTBL,SSINE
CSTBL   DW      10000,9999,9994,9986,9976,9962,9945,9926,9903,9877
        DW      9848,9816,9782,9744,9703,9659,9613,9563,9511,9455
        DW      9397,9336,9272,9205,9136,9063,8998,8910,8830,8746
        DW      8660,8572,8481,8387,8290,9192,9090,7986,7880,7772
        DW      7660,7547,7431,7314,7193,7071,6947,6820,6691,6561
        DW      6428,6293,6157,6018,5878,5736,5592,5446,5299,5150
        DW      5000,4848,4695,4540,4388,4226,4067,3907,3746,3584
        DW      3420,3256,3090,2924,2756,2588,2419,2250,2079,1908
        DW      1737,1564,1392,1219,1045,0872,0698,0523,0349,0175
        DW      0
SSINE   DW      0

DATA1   ENDS

ANGCS   SEGMENT PARA PUBLIC 'CODE'
        PUBLIC  COSSIN
COSSIN  PROC    FAR
        ASSUME  CS:ANGCS,DS:DATA1

        PUSH    DS

        MOV     BX,SEG DATA1
        MOV     DS,BX

        CMP     AX,90
        JNA     ELSE1
                CMP     AX,180
                JNA     ELSE2
                        CMP     AX,270
                        JNA     ELSE3
                                MOV     BX,360
                                SUB     BX,AX
                                MOV     AX,BX
                                SHL     BX,1
                                MOV     CX,CSTBL[BX]
                                MOV     SSINE,8000H
                        JMP     SHORT _IF3
ELSE3:                          SUB     AX,180
                                MOV     BX,AX
                                SHL     BX,1
                                MOV     CX,CSTBL[BX]
                                OR      CX,8000H
                                MOV     SSINE,8000H
_IF3:           JMP     SHORT _IF2

ELSE2:                  MOV     BX,180
                        SUB     BX,AX
                        MOV     AX,BX
                        SHL     BX,1
                        MOV     CX,CSTBL[BX]
                        OR      CX,8000H
                        MOV     SSINE,0
_IF2:           JMP     SHORT _IF1

ELSE1:                  MOV     BX,AX
                        SHL     BX,1
                        MOV     CX,CSTBL[BX]
                        MOV     SSINE,0
_IF1:           MOV     BX,90
                SUB     BX,AX
                SHL     BX,1
                MOV     DX,CSTBL[BX]
                OR      DX,SSINE

                POP     DS
                RET

COSSIN  ENDP
ANGCS   ENDS

        END

