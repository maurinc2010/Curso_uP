                                                                          
.MODEL SMALL 
                       ;definicion del modelo de memoria a usar 
.STACK                              ;definicion del segmento de pila

.DATA                               ;segmento de datos
    PORT DW 188h
    PA   DW 0100h 
    PB   DW 0108h
    PC   DW 0180h 
    USO  DW 0000   
    dato       dB  00
.CODE       
    MOV     USO,0080h 
    MOV     DX,188H
    mov     AX,USO
    out     DX,AX   
    
    ;mov Ah, 9                
    ;int 21h 
    
looop:
    call    DELAY    
    MOV     al,00000000b
    MOV     DX,100h
    out     DX,Al   
    
    CALL    DELAY 
    MOV     al,10000001b
    MOV     DX,100h
    out     DX,Al   
    
    call    DELAY
    MOV     al,01000010b
    MOV     DX,100h
    out     DX,Al
    
    CALL    DELAY
    MOV     al,00100100b
    MOV     DX,100h
    out     DX,Al
    
    CALL    DELAY
    MOV     al,00011000b 
    MOV     DX,100h
    out     DX,Al  
    
    CALL    DELAY
    MOV     al,00011000b 
    MOV     DX,180h
    out     DX,Al 
    
    JMP     looop
    


   
 
 
 
    
DELAY1 PROC 
    MOV AX,10000       
    MOV CX,AX
CASSS1:   
    DEC CX
    JNZ CASSS1 
    ret
DELAY1 ENDP 
    

   
        
DELAY PROC 
    MOV AX,700       
    MOV CX,AX
CASSS:   
    DEC CX
    JNZ CASSS 
    ret
DELAY ENDP
END