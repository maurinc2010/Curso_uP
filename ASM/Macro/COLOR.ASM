.model tiny
.stack 64
.data 10
.code
mov ax, @data
mov ds,ax
mov ax,13h
int 10h
mov ax,0a00h
mov es,ax
cld
mov di,0
mov al,0
call band
mov al,64h
call band
mov al,128
call band
mov al,192
call band
mov ah,1
int 21
mov ax,3
int 10h
 band proc near
 mov bh,40
 band1:
      push ax
      mov cx,64
band2:
      mov bl,5
band3:
      stosb            
      dec bl
      jnz band3
      inc al
      loop band2
      pop ax
      dec bh
      jnz band1
      add di,320*10
      ret
band endp
mov ax,4c00
int 21h
     end
           
