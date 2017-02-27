page 60,132
title letra.asm;
;-----------------------------------------------
stacks segment para stack 'stack'
           dw   32   dup(0)
stacks ends
;-----------------------------------------------
datos segment para 'data'
flda    dw     250
fldb    dw     125
fldc    dw     ?
datos ends
;-----------------------------------------------
codigo segment para 'code'
procd1   proc  far
      assume ss: stacks,ds:datos,cs:codigo
      mov   ax,datos
      mov ds,ax
      mov ax,flda
      add ax,fldb
      mov fldc,ax
      mov ax,4c00h
      int 21h
procd1 endp
codigo ends
       end procd1
  
  