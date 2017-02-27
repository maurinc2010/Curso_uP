PAGE    60,132
TITLE   MOTOR.ASM   "PROGRAMA PARA UNA TARJETA DEL COMPUTADOR" 
;---------------------
INICIA  MACRO
        MOV AX, DATA           
        MOV DS, AX
        MOV ES, AX    
        ENDM
;----------------------
BRILLO  MACRO
        MOV AH,09H
        MOV AL,'-'
        MOV BH,00H     ;ILUMINA PANTALLA
        MOV BL,0F0H
        MOV CX,79
        INT 10H
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
MEN9    DB '1998                                                ',13,10,'$'
MEN10   DB 'TARJETA DE ADQUISICION DE DATOS                     ',13,10,'$'
MEN11   DB 'TABLA DE DATOS CAUDAL                               ',13,10,'$'
MEN12	DB 'CAUDAL DESEADO(O DE REFERENCIA)=                    ',13,10,'$'
MEN13	DB 'CAUDAL ACTUAL=                                      ',13,10,'$'
MEN14	DB 'VALOR DE LAS SENAL DE CONTROL ENVIADA               ',23,10,'$'

TABLA   DB 05H, 06H, 0AH, 09H
MI      DW 0FFFFH
MIN     DW 0
MINI    DB 05H ;04H
MAXI    DW 01BFH;01BFH
AUX     DB 0H
TEMP    DB 0H,0H,0H,0H,0H,0H,0H,0H
DATA    ENDS
;-----------------------------------
CODE    SEGMENT PARA PUBLIC 'CODE'
MAIN    PROC FAR
        ASSUME CS:CODE,DS:DATA,ES:DATA,SS:STACK
        INICIA        
;DIRECCION 031C PARA EL PUERTO 'A' DE LA PPI 
;DIRECCION 031D PARA EL PUERTO 'B' DE LA PPI 
;DIRECCION 031E PARA EL PUERTO 'C' DE LA PPI 
;DIRECCION 031F PARA EL REGISTRO DE CONTROL DE LA PPI
 	MOV DX, 031FH           ; SE PROGRAMA A LA PPI                            
        MOV AL, 10010001B       ;        'A' ENTRADA
        OUT DX, AL              ;        'B' SALIDA
        MOV SI,00H              ;        'C' PC4-PC7 SALIDA
                                ;            PC0-PC3 ENTRADA
        MOV DX, 031FH           ;  PARA EL CANAL CERO "0"
        MOV AL, 00001011B       ;  PC5  "0" 
        OUT DX, AL              
        MOV AL, 00001100B       ;  PC6  "0" 
        OUT DX, AL                 
        MOV AL, 00001110B       ;  PC7  "0"
        OUT DX, AL  

 ;---------------PCL-------------------------
        MOV AX,0600H
        CALL LIMPIAR
        POSICION 1,1
        BRILLO
        
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
        BRILLO
	MOV AH,01H
        INT 21H
        OR AL,AL
	
	MOV AX,0600H
        CALL LIMPIAR
        POSICION 1,1
        BRILLO	

	MOV CH,10H
	MOV CL,10H
        PUSH CX
	MOV AL,019H      ;033H      ;BORRARRRRRRRR
	MOV AL,05H
SALT:   DEC AL
        CMP AL,01H
        JNZ SALT

RECIB:  MOV DX, 031CH           ; PREGUNTO EL DATO DE LA CONVERSION
        IN AL,  DX 
        MOV SI,05H      ;
        MOV AL,00H 
CICLO:	MOV [TEMP+SI], AL
	MOV AH,[TEMP+SI]
	INC AL
        DEC SI
        CMP SI,01H
        JNZ CICLO      
	MOV SI,00H 
        ;DEBE CONTINUAR LA ORGANIZADA Y VISUALIZADA DE LOS DATOS RECIBIDOS
	POSICION 4,24
	MENSAGE MEN11  
	POSICION 8,12
	MENSAGE MEN12	
	POSICION 12,12
	MENSAGE MEN13	
        POSICION 16,12
	MENSAGE MEN14
	
	POSICION 24,1
        BRILLO
	  
        
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
CODE    ENDS
        END 

