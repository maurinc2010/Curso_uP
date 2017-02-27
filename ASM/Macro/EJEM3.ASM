page 60,132
title letra.asm;
;-----------------------------------------------
stacks segment para stack 'stack'
           dw   1   dup(?)
stacks ends
;-----------------------------------------------
datos segment para 'data'
         dw    1    dup(?)
AVISO  db 'TE AMO CON TODO MI CORAZON LORENA QUINTANA DE AVENDA¥O','$'
	datos ends
;-----------------------------------------------
codigo segment para 'code'
LEAR     proc  far
      assume ss: stacks,ds:datos,cs:codigo
      mov   ax,datos
      mov ds,ax
      jmp despliegue
RUT1:
despliegue: lea dx,AVISO
        
      mov ah,09h
      int 21h
      mov ah,4ch
      int 21h
LEAR endp
codigo ends
       end LEAR
  
  