                                                                          
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
    MOV     USO,0090h 
    MOV     DX,188H
    mov     AX,USO
    out     DX,AX   
    
    ;mov Ah, 9                
    ;int 21h 
    
looop:
    MOV     DX,0100H
    IN      AL,DX
    
    MOV     DX,0180H
    OUT     DX,AL
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