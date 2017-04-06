                                                                          
.MODEL SMALL                        ;definicion del modelo de memoria a usar 

.STACK                              ;definicion del segmento de pila

.DATA                               ;segmento de datos  
    C_X     DW  ?
    C1_X    DW  ?
    C_Y     DW  ?
    C1_Y    DW  ?
    D_X     DW  ?
    D_Y     DW  ? 
    AUX     DW  ?  
    AUX2    DW  ?
    AUX3    DW  ?  
    CORX    DW  ?
    CORY    DW  ? 
    EST     DW  ? 
    MENSAJE1 DB  'ESCRIBA',13,10,'$' 
    MSM2    DB   'CLICK',13,10,'$' 
    MSM3    DB   'SALIDA',13,10,'$' 
    MSM4    DB   'SENO',13,10,'$'
    MSM5    DB   'CUADRADA',13,10,'$'
    MSM6    DB   'TRIANGUAR',13,10,'$'  
    corx2    dW  000EH,010EH,0192H,000EH,000EH,000EH
    cory2    dW  0012h,0010h,0010h,002FH,005DH,008BH 
    corx1   dW   00EEH,0167H,025EH,009FH,009FH,009FH
    cory1   dW   0024H,0024H,0024H,0042H,006FH,009FH 
    NAME1   DW   0,2,4,6,8,00AH      
    NUM     DW  0000   
    cadena1 db 9,0,9 dup(?),'$'         
    ;sinn    db   
    cuad1    db  30 dup(33H)
    cuad2    db  30 dup(170) 
    ;trian
    
.CODE 

INICIO:
                                    ;segmento de codigo
    MOV AX,@DATA
    MOV DS,AX
    MOV ES,AX
    
    MOV AL,13H
    MOV AH,0
    INT 10H      
    
   
    

	   
;---- SECCION PARA GRAFICAR LAS CAJAS --------- 
     
    MOV C_X,6H     ;PUNTO DE INCIO EN X DEL CUADRO
    MOV C1_X,78H   ;PUNTO FINAL EN X
    MOV C_Y,12H    ;PUNTO DE INICIO EN Y
    MOV C1_Y,25H   ;PUNTO FINAL EN Y
    MOV D_X,73H    ;LONGITUD DE LOS LADOS SOBRE X
    MOV D_Y,13H    ;LONGITUD DE LOS LADOS SOBRE Y
    CALL    BOX  


    mov Dh,1H  ;fila
	mov Dl,3H  ;columna
	mov Ah, 2
	Int 10h			;ubica el cursor en la posicion Dh=filas, Dl=columnas
	mov Dx, Offset MENSAJE1  ; carga el offset de la cadena mensaje
    mov Ah, 9                
    int 21h      

 
    MOV C_X,86H
    MOV C1_X,0B4H  
    MOV C_Y,10H
    MOV C1_Y,25H
    MOV D_X,2EH
    MOV D_Y,15H
    CALL    BOX 
    mov Dh,3H  ;fila
	mov Dl,11H  ;columna
	mov Ah, 2
	Int 10h			;ubica el cursor en la posicion Dh=filas, Dl=columnas
	mov Dx, Offset MSM2  ; carga el offset de la cadena mensaje
    mov Ah, 9                
    int 21h       

	
    MOV C_X,0C8H
    MOV C1_X,130H  
    MOV C_Y,10H
    MOV C1_Y,25H
    MOV D_X,68H
    MOV D_Y,15H
    CALL    BOX 
    ;mov DH,0  ;fila
	;mov DL,0  ;columna
	;mov Ah, 2
	;Int 10h			;ubica el cursor en la posicion Dh=filas, Dl=columnas
	;mov Dx, Offset MSM3  ; carga el offset de la cadena mensaje
    ;mov Ah, 9                
    ;int 21h  

                  
    MOV C_X,6H
    MOV C1_X,50H  
    MOV C_Y,30H
    MOV C1_Y,45H
    MOV D_X,4BH
    MOV D_Y,15H
    CALL    BOX
     mov Dh,7H  ;fila
	mov Dl,3H  ;columna
	mov Ah, 2
	Int 10h			;ubica el cursor en la posicion Dh=filas, Dl=columnas
	mov Dx, Offset MSM4  ; carga el offset de la cadena mensaje
    mov Ah, 9                
    int 21h     
	

    
    MOV C_X,6H 
    MOV C1_X,50H 
    MOV C_Y,60H
    MOV C1_Y,75H
    MOV D_X,4BH
    MOV D_Y,15H
    CALL    BOX 
     mov Dh,0DH  ;fila
	mov Dl,1H  ;columna
	mov Ah, 2
	Int 10h			;ubica el cursor en la posicion Dh=filas, Dl=columnas
	mov Dx, Offset MSM5  ; carga el offset de la cadena mensaje
    mov Ah, 9                
    int 21h     
    
    MOV C_X,6H 
    MOV C1_X,50H 
    MOV C_Y,90H
    MOV C1_Y,0A5H
    MOV D_X,4BH
    MOV D_Y,15H
    CALL    BOX 
    mov Dh,13H  ;fila
	mov Dl,1H  ;columna
	mov Ah, 2
	Int 10h			;ubica el cursor en la posicion Dh=filas, Dl=columnas
	mov Dx, Offset MSM6  ; carga el offset de la cadena mensaje
    mov Ah, 9                
    int 21h    
 
 
    MOV C_X,60H 
    MOV C1_X,130H 
    MOV C_Y,30H
    MOV C1_Y,0AEH
    MOV D_X,0D0H
    MOV D_Y,7EH
    CALL    BOX 
    
    mov AUX,00D0H
    MOV AUX2,60H 
    mov AUX3,006FH
    CALL lin_h1
    
    
LOOP_INF:
    mov ax, 3       ;obtener el estado del Mouse
	int 33h
	mov CORX,CX
	mov CORY,DX 
	MOV EST,BX 
	CMP BX,0
	JNZ LOOP_BUSCAR
	JZ LOOP_INF            
    
    
LOOP_BUSCAR:
    SUB AX,AX
    MOV NUM,AX
    MOV CX,7 
CASS:        
    MOV BX,OFFSET corx2
    ADD BX,NUM
    MOV AX,[BX]
    CMP CORX,AX
    JNS SIPP
    JZ  SIPP 
CASSS:
    INC NUM
    INC NUM
    LOOP CASS
    jmp LOOP_INF

SIPP:
    MOV BX,OFFSET corx1
    add bx,NUM
    mov ax,[bx]
    cmp AX,CORX
    JZ  sippy
    JNS sippy
    jmp CASSS
         
sippy:
    mov BX,OFFSET cory2
    add bx,NUM
    MOV AX,[BX]
    CMP CORY,AX
    JZ  SIPPPY
    JNS SIPPPY
    JMP CASSS
    
SIPPPY:
    MOV BX,OFFSET cory1
    add bx,NUM
    MOV AX,[BX]
    CMP AX,CORY
    JNS LISTO
    JZ  LISTO
    JMP CASSS



LISTO:
    MOV BX,OFFSET NAME1
    ADD BX,NUM
    MOV AX,[BX] 
    mov NUM,AX
   
    CMP NUM,0
    JNZ NOES
    mov Dh,3H  ;fila
	mov Dl,2H  ;columna
	mov Ah, 2
	Int 10h
    Mov  Ah,0Ah               ; Captura la cantidad (hasta 15 bytes)
    Mov  Dx,offset cadena1    ; Guarda direcci¢n de variable
    Int  21h 
    JMP LOOP_INF
    
    
NOES:
    CMP NUM,2
    JNZ NOES1 
    mov Dh,3H  ;fila
	mov Dl,17H  ;columna
	mov Ah, 2
	Int 10h			;ubica el cursor en la posicion Dh=filas, Dl=columnas
	mov Dx, Offset cadena1  ; carga el offset de la cadena mensaje
    mov Ah, 9                
    int 21h   
    jmP LOOP_INF
    
NOES1:
    CMP NUM,6
    jnz NOES2
    
    
NOES2:
    CMP NUM,8
    JNZ NOES3
    mov AUX,0030H
    MOV AUX2,60H 
    mov AUX3,0032H
    CALL lin_h1
    mov  AUX,7AH
    CALL lin_v1 
    mov  AUX,30H
    CALL lin_h1
    mov  AUX,7AH 
    CALL lin_v2
    MOV  AUX,30H
    CALL lin_h1 
    mov  AUX,7AH
    CALL lin_v1 
    MOV  AUX,30H
    CALL lin_h1 
    mov  AUX,7AH 
    CALL lin_v2
    jmp LOOP_INF
    
NOES3:
    CMP NUM,000AH
    JNZ LOOP_INF    
   
 
    
     
    
;---- FUNCION PARA GRAFICAR UNA CAJA ------------                               
BOX: 
    ;MOV     BX,OFFSET NAME1+2 
    ;ADD     BX,NUM
    ;MOV     AX,NUM
    ;MOV     [BX],AX        
    MOV     AX,C_Y                   
    ;MOV     BX,OFFSET cory2+2
    ;ADD     BX,NUM
    ;mov     [bx],ax
    MOV     AUX2,AX                 ;AUX2 CONTIENE EL VALOR DE LA COORDENADA EN Y
    MOV     BX,C1_Y 
    MOV     AUX3,BX 
    ;mov     ax,AUX3                 ;AUX3 CONTIENE EL VALOR DE LA COORDENADA EN Y1
    ;MOV     BX,OFFSET cory1+2
    ;ADD     BX,NUM
    ;mov     [bx],ax
    CALL    LIN_H 

    
    MOV     AX,C_X
    MOV     AUX2,AX                 ;AUX2 CONTIENE EL VALOR DE LA COORDENADA EN X
    ;mov     bx,offset corx2+2 
    ;ADD     BX,NUM  
    ;add     ax,8h
    ;mov     [bx],ax
    MOV     BX,C1_X
    MOV     AUX3,BX                   ;AUX3 CONTIENE EL VALOR DE LA COORDENADA EN X1
    ;mov     ax,bx
    ;mov     bx,offset corx1+2 
    ;ADD     BX,NUM 
    ;add     ax,8h
    ;mov     [bx],ax
    ;inc     NUM
    ;INC     NUM
    CALL    LIN_V    

RET      

LIN_H:
    
    MOV     CX,D_X                  ;HACE EL LOOP CON EL VALOR DEL DESPLAZAMIENTO EN X        
    MOV     DX,C_X      
    MOV     AUX,DX                  ;AUX CONTIENE EL EL VALOR DE LA COORDENADA EN X

DESPX:  
    PUSH    CX
    MOV     AL, 1100b
	MOV     CX, AUX                 ;AUX INCREMENTA EL VALOR DE LA COORDENADA EN X
	MOV     DX, AUX2                ;AUX 2 CONTIENE EL VALOR DE LA COORDENADA EN Y                                
	MOV     AH, 0Ch
	INT     10h 
	MOV     CX, AUX     
	MOV     DX, AUX3                ;AUX 3 CONTIENE EL VALOR DE LA COORDENADA EN Y1                                
	MOV     AH, 0Ch
	INT     10h  
	INC     AUX
	POP     CX
    LOOP    DESPX
RET
 
LIN_V:
    
    MOV     CX,D_Y                  ;HACE EL LOOP CON EL VALOR DEL DESPLAZAMIENTO EN Y
    MOV     DX,C_Y
    MOV     AUX,DX

DESPY:  
    PUSH     CX
    MOV     AL, 1110b
	MOV     CX, AUX2                ;AUX 2 CONTIENE EL VALOR DE LA COORDENADA EN X
	MOV     DX, AUX                 ;AUX INCREMENTA EL VALOR DE LA COORDENADA EN Y
	MOV     AH, 0Ch
	INT     10h 
	MOV     CX, AUX3     
	MOV     DX, AUX                ;AUX 2 CONTIENE EL VALOR DE LA COORDENADA EN Y                                
	MOV     AH, 0Ch
	INT     10h     
	INC     AUX
	POP     CX
    LOOP    DESPY
RET                      

TEXTO:
    MOV BH, 0
	MOV AH, 2h
	INT 10h
RET   

TEXTO2:
   MOV AH,09H
   INT 21H
RET      

lin_h1 PROC
    MOV     CX, AUX
MMMM:
    push    cx
    mov     cx,AUX2         
	MOV     DX, AUX3
	MOV     AL, 0001b                ;AUX 3 CONTIENE EL VALOR DE LA COORDENADA EN Y1                                
	MOV     AH, 0Ch 
	INT     10h  
	INC     AUX2 
	pop     cx
    LOOP    MMMM  
    RET
lin_h1 endp

lin_V1 PROC
    MOV     CX,AUX
MMMM1:
    push    cx
    mov     cx,AUX2         
	MOV     DX, AUX3
	MOV     AL, 0001b                ;AUX 3 CONTIENE EL VALOR DE LA COORDENADA EN Y1                                
	MOV     AH, 0Ch 
	INT     10h  
	INC     AUX3 
	pop     cx
    LOOP    MMMM1  
    RET
lin_v1 endp     

lin_V2 PROC
    MOV     CX,AUX
MMMM2:
    push    cx
    mov     cx,AUX2         
	MOV     DX, AUX3
	MOV     AL, 0001b                ;AUX 3 CONTIENE EL VALOR DE LA COORDENADA EN Y1                                
	MOV     AH, 0Ch 
	INT     10h  
	DEC     AUX3 
	pop     cx
    LOOP    MMMM2
    RET
lin_v2 endp
 
FIN:
END