PAGE    60,132
TITLE   PROBAR.ASM   "PROGRAMA PARA UNA TARJETA I/O DEL COMPUTADOR" 
;---------------------
INICIA  MACRO
        MOV AX, DATA           
        MOV DS, AX
        MOV ES, AX    
        ENDM
;---------------------
MENSAGE MACRO MENSA
        MOV AH, 09H
        LEA DX, MENSA
        INT 21H
        ENDM
;-----------------------------------
POSICION MACRO X,Y 
        MOV AH,02H
        MOV BH,00H
        MOV DH,X
        MOV DL,Y
        INT 10H
        ENDM
;-----------------------------------
STACK   SEGMENT PARA STACK 'STACK'
        DB      64 DUP ('STACK')
STACK   ENDS
;-----------------------------------
DATA    SEGMENT PARA PUBLIC 'DATA'
MEN1    DB 'PROYECTO DE MICROPROCESADORES:                      ',13,10,'$'
MEN2    DB '                                                    ',13,10,'$'
MEN3    DB 'YESID A. AMAYA C. COD.49-970101                     ',13,10,'$'
MEN4    DB 'DARY Y. BARRERA H. COD 49-970136                    ',13,10,'$'
MEN5    DB 'ING. JUAN MAURICIO SALAMANCA                        ',13,10,'$'
MEN6    DB 'UNIVERSIDAD PEDAGOGICA Y TECNOLOGICA DE COLOMBIA    ',13,10,'$'
MEN7    DB 'ESCUELA DE INGENIERIA ELECTRONICA                   ',13,10,'$'
MEN8    DB 'SOGAMOSO                                            ',13,10,'$'
MEN9    DB '2001                                                ',13,10,'$'
MEN10   DB 'TARJETA DE ADQUISICION DE DATOS                     ',13,10,'$'
MEN11   DB 'INICIANDO  PROCESO DE CONTROL                       ',13,10,'$'
MEN12	DB 'CAUDAL DESEADO(O DE REFERENCIA)=                    ',13,10,'$'
MEN13	DB 'CAUDAL ACTUAL=                                      ',13,10,'$'
MEN14	DB 'VALOR DE LAS SENAL DE CONTROL ENVIADA               ',13,10,'$'

MINI    DB 'DIGITE EL CAUDAL DESEADO                            ',13,10,'$'
TABLA   DB 05H, 06H, 0AH, 09H
MI      DW 0FFFFH
MIN     DW 0
MAXI    DW 01BFH;01BFH
AUX     DB 0H
TEMP    DB 0H,0H,0H,0H,0H,0H,0H,0H
DATA    ENDS
;-----------------------------------
CODE    SEGMENT PARA PUBLIC 'CODE'
MAIN    PROC FAR
        ASSUME CS:CODE,DS:DATA,ES:DATA,SS:STACK
        INICIA        
;---------------PCL-------------------------
        MOV AX,0600H
	CALL LIMPIAR
	POSICION 1,1
        
	POSICION 4,24
        MENSAGE MEN10
        POSICION 11,26
        MENSAGE MEN3
        POSICION 12,25
        MENSAGE MEN4
        POSICION 13,28
        MENSAGE MEN5
        POSICION 19,16
        MENSAGE MEN6
        POSICION 20,24
        MENSAGE MEN7
        POSICION 21,37
        MENSAGE MEN8
        POSICION 22,39
        MENSAGE MEN9
        POSICION 24,1
    
	MOV AH,01H
        INT 21H
        OR AL,AL

PAGINA2:
	MOV AX,0600H
        CALL LIMPIAR
	POSICION 1,1

       	POSICION 4,24
	MENSAGE MINI  
	POSICION 24,1
	
	POSICION 12,28
	CALL TECLADO
	
	MOV AH,01H
        INT 21H
        OR AL,AL

	;TERCERA PAGINA
	MOV AX,0600H
        CALL LIMPIAR
	POSICION 1,1


       	POSICION 4,24
	MENSAGE MEN11  
	POSICION 8,12
	MENSAGE MEN12	
	POSICION 12,12
	MENSAGE MEN13	
        POSICION 16,12
	MENSAGE MEN14
        POSICION 8,52
        
	
	MOV AX,BP
	MOV DL,AL
	MOV AH,06H
	INT 21H

	MOV AX,SI
	MOV DL,AL
	MOV AH,06H
	INT 21H
	
	POSICION 24,1
        MOV AH, 4CH     ;TERMINAR
        INT 21H         ;DEL DOS
        RET     
MAIN    ENDP                          
;---------------------   
LIMPIAR PROC NEAR
        MOV BH,17H
        MOV CX,0000H
        MOV DX,184FH
        INT 10H
        RET
LIMPIAR ENDP
;---------------------
TECLADO PROC NEAR
       	XOR BP,BP
	MOV CX,2
	MOV BH,10
LEER:	
	CALL TECLA
	CMP AL,'0'
	JB LEER
	CMP AL,'9'
	JA LEER
        MOV DL,AL
	INT 21H
	CMP CX,2
	JNE DIGT2
	XOR AH,AH
	MOV BP,AX
	LOOP LEER
DIGT2:	
	XOR AH,AH
	MOV SI,AX 
	LOOP LEER
	RET
TECLADO ENDP
;---------------------
TECLA   PROC NEAR
       	MOV AH,06H
	MOV DL,0FFH
        INT 21H
        JE  TECLA		
	RET
TECLA   ENDP
;--------------------------------
CODE    ENDS
        END 

