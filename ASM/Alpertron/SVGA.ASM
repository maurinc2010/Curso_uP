; Este programa muestra una animacion de circulos en la pantalla 
; en el modo 13h (VGA 320x200 con 256 colores).
; En este modo el video utiliza en buffer de 320*200=64000 bytes que
; comienza en la direccion 0A000h.
;
; Operaciones:
;
; 1) Para escribir un pixel (x,y): Escribir el byte de color en la posicion
;    y*320+x.
;
; 2) Para leer la paleta R-G-B de un color especifico:
;    mov al,color
;    mov dx,3C7h
;    out dx,al
;    mov dx,3C9h
;    in al,dx
;    mov rojo,al
;    in al,dx
;    mov verde,al
;    in al,dx
;    mov azul,al
;
; 3) Para grabar la paleta R-G-B para un color especifico:
;
;    mov al,color
;    mov dx,3C8h
;    out dx,al
;    mov dx,3C9h
;    mov al,rojo
;    out dx,al
;    mov al,verde
;    out dx,al
;    mov al,azul
;    out dx,al
;
; Si se desean grabar todas las paletas, como en el caso de este programa,
; basta con escribir en el port 3C8h el valor cero y luego escribir 768
; bytes (tres bytes para RGB del color 0, tres bytes para RGB del color 1,...
; y tres bytes para RGB del color 255) en el port 3C9h.
;
; Para la animacion se utiliza buffer doble.
;
; Hecho por Dario Alejandro Alpern el 14 de abril de 2002
;
CANTIDAD_MAXIMA_CIRCULOS EQU 256
CANTIDAD_COLORES         EQU 256
FILAS    EQU 28*16       ;Las 32 lineas de abajo estan ocupadas por texto.
COLUMNAS EQU 640

; La estructura que esta abajo esta copiada de la especificacion VESA 1.2
;
ModeInfoBlock   STRUC

; mandatory information

        ModeAttributes      dw  ?  ; mode attributes
        WinAAttributes      db  ?  ; window A attributes
        WinBAttributes      db  ?  ; window B attributes
        WinGranularity      dw  ?  ; window granularity
        WinSize             dw  ?  ; window size
        WinASegment         dw  ?  ; window A start segment
        WinBSegment         dw  ?  ; window B start segment
        WinFuncPtr          dd  ?  ; pointer to windor function
        BytesPerScanLine    dw  ?  ; bytes per scan line

; formerly optional information (now mandatory)

        XResolution         dw  ?  ; horizontal resolution
        YResolution         dw  ?  ; vertical resolution
        XCharSize           db  ?  ; character cell width
        YCharSize           db  ?  ; character cell height
        NumberOfPlanes      db  ?  ; number of memory planes
        BitsPerPixel        db  ?  ; bits per pixel
        NumberOfBanks       db  ?  ; number of banks
        MemoryModel         db  ?  ; memory model type
        BankSize            db  ?  ; bank size in kb
        NumberOfImagePages  db  ?  ; number of images
        Reserved            db  ?  ; reserved for page function

; new Direct Color fields

        RedMaskSize         db  ?  ; size of direct color red mask in bits
        RedFieldPosition    db  ?  ; bit position of LSB of red mask
        GreenMaskSize       db  ?  ; size of direct color green mask in bits
        GreenFieldPosition  db  ?  ; bit position of LSB of green mask
        BlueMaskSize        db  ?  ; size of direct color blue mask in bits
        BlueFieldPosition   db  ?  ; bit position of LSB of blue mask
        RsvdMaskSize        db  ?  ; size of direct color reserved mask in bits
        DirectColorModeInfo db  ?  ; Direct Color mode attributes
        Reserved2           db  216 dup(?)      ; remainder of ModeInfoBlock
ModeInfoBlock   ENDS

circulo  struc
posX     dd ?             ;Posicion X izquierda del circulo * 65536.
posY     dd ?             ;Posicion Y superior del circulo * 65536.
incX     dd ?             ;Incremento X en 1/18,2 segundo (* 65536)
                          ;Este numero tiene signo.
incY     dd ?             ;Incremento Y en 1/18,2 segundo (* 65536).
                          ;Este numero tiene signo.
radio    dd ?             ;Radio del circulo.
color    db ?             ;Color del circulo.
circulo ends

paleta   struc            ;Definicion de paleta de 18 bits de VGA.
rojo     db ?             ;Vale entre 00h y 3Fh.
verde    db ?             ;Vale entre 00h y 3Fh.
azul     db ?             ;Vale entre 00h y 3Fh.
paleta   ends
        .386
        assume cs:codigo, ds:datos
datos   segment use16
circulos circulo CANTIDAD_MAXIMA_CIRCULOS dup(<0,0,0,0,0>)
paleta_original paleta CANTIDAD_COLORES   dup(<0,0,0>)
colores         paleta CANTIDAD_COLORES   dup(<0,0,0>)
cambio_paleta   paleta CANTIDAD_COLORES   dup(<0,0,0>)

paleta_variable db 0     ;Si es cero, no se cambia la paleta.
                         ;Si es uno, se cambia continuamente.
semilla dd 0             ;Semilla para numeros pseudoaleatorios.
cant_circulos dw 0
cadena1  db "ENTER:nuevo circulo, P:paleta, ESC:salir"
long_cadena1 equ $-cadena1
cadena2  db "Hecho por Dario Alpern el 14-Abr-2002"
long_cadena2 equ $-cadena2
SVGA_info  ModeInfoBlock <>

datos   ends

pila   segment use16 stack
       dw 512 dup (?)
pila   ends

codigo segment use16
inicio:
       mov ax,datos
       mov ds,ax
  ;Iniciar semilla de numeros pseudoaleatorios.
       mov ax,40h        ;Apuntar a RAM BIOS
       mov es,ax
       mov eax,es:[6Ch]  ;Obtener cantidad de tics (1/18,2 seg) desde
                         ;medianoche,
       mov semilla,eax   ;Almacenarlo en la semilla de nros pseudoaleatorios.
  ;Obtener informacion sobre el modo de video.
       mov ax,4F01h      ;Funcion para obtener informacion de modo de video.
       mov cx,0101h      ;Modo grafico de 640x480 pixels, 256 colores.
       mov di,offset SVGA_info
       push ds        
       pop es            ;ES:DI = Puntero al buffer donde va la informacion.
       int 10h           ;Llamar al BIOS de la tarjeta SVGA.

  ;Cambiar modo de video.
       mov ax,4F02h      ;Funcion para cambiar de modo de video.
       mov bx,0101h      ;Modo grafico de 640x480 pixels, 256 colores.
       int 10h           ;Llamar al BIOS de la tarjeta SVGA.
  ;Obtener paleta original.
       mov si,offset paleta_original
       mov cl,0
ciclo_obtener_paleta:
       mov al,cl         ;Obtener el numero de color.
       mov dx,3C7h       ;Darselo al controlador de VGA.
       out dx,al
       mov dx,3C9h
       in al,dx          ;Obtener la componente roja del color.
       mov [si+rojo],al  ;Almacenarla.
       in al,dx          ;Obtener la componente verde del color.
       mov [si+verde],al ;Almacenarla.
       in al,dx          ;Obtener la componente azul del color.
       mov [si+azul],al  ;Almacenarla.
       add si,size paleta
       inc cl            ;Incrementar numero de color.
       jnz ciclo_obtener_paleta
  ;Mostrar textos.
       mov ah,13h        ;Mostrar cadena.
       mov al,0          ;Especifica que el atributo se encuentra en BL.
       mov bh,00h        ;Pagina.
       mov bl,07h        ;Atributo (blanco sobre negro).
       mov cx,long_cadena1 ;Longitud de la cadena.
       mov dh,28         ;Fila donde se mostrara la cadena.
       mov dl,(80-long_cadena1)/2  ;Para centrar la cadena.
       push ds
       pop es
       mov bp,offset cadena1  ;ES:BP = Puntero a la cadena.
       int 10h           ;Llamar a servicio de video de BIOS.
       mov ah,13h        ;Mostrar cadena.
       mov al,0          ;Especifica que el atributo se encuentra en BL.
       mov bh,00h        ;Pagina.
       mov bl,07h        ;Atributo (blanco sobre negro).
       mov cx,long_cadena2 ;Longitud de la cadena.
       mov dh,29         ;Fila donde se mostrara la cadena (fila inferior).
       mov dl,(80-long_cadena2)/2  ;Para centrar la cadena.
       push ds
       pop es
       mov bp,offset cadena2  ;ES:BP = Puntero a la cadena.
       int 10h           ;Llamar a servicio de video de BIOS.

nuevo_circulo:
       mov ax,cant_circulos ;Obtener cantidad de circulos.
       cmp ax,CANTIDAD_MAXIMA_CIRCULOS
       jz animacion
       mov ax,size circulo           ;Obtener longitud de la estructura.
       mul cant_circulos
       add ax,offset circulos
       mov si,ax                     ;SI = Offset de informacion del circulo.
   ;Inicializar posicion X.
       mov ebx,100*65536
       call obtener_nro_aleatorio    ;EAX = Numero aleatorio menor que EBX.
       add eax,(COLUMNAS-100)/2*65536
       mov [si+posX],eax
   ;Inicializar posicion Y.
       mov ebx,100*65536
       call obtener_nro_aleatorio    ;EAX = Numero aleatorio menor que EBX.
       add eax,(FILAS-100)/2*65536
       mov [si+posY],eax
   ;Inicializar direccion X.
       mov ebx,8*65536
       call obtener_nro_aleatorio    ;EAX = Numero aleatorio menor que EBX.
       sub eax,4*65536
       mov [si+incX],eax
   ;Inicializar direccion Y.
       mov ebx,8*65536
       call obtener_nro_aleatorio    ;EAX = Numero aleatorio menor que EBX.
       sub eax,4*65536
       mov [si+incY],eax
   ;Inicializar radio.
       mov ebx,20
       call obtener_nro_aleatorio    ;EAX = Numero aleatorio menor que EBX.
       add eax,10
       mov [si+radio],eax
   ;Inicializar diametro.
       mov ebx,255                   ;No elegir color cero = negro.
       call obtener_nro_aleatorio    ;EAX = Numero aleatorio menor que EBX.
       inc eax
       mov [si+color],al
       inc cant_circulos             ;Indicar que hay un circulo mas.

animacion:
       cmp paleta_variable,0         ;Hay que cambiar la paleta?
       jz esperar_timer_tick         ;Saltar si no es asi.
  ;Actualizar los colores de la paleta.
       mov si,offset colores
       mov di,offset cambio_paleta
       mov cx,size cambio_paleta   ;Cantidad de componentes de colores a
                                   ;procesar.
ciclo_cambiar_paleta:
       mov al,[si]                 ;Obtener componente de color (R, G o B).
       add al,[di]                 ;Cambiar componente.
       cmp al,40h                  ;Ver si esta en rango 00h-3Fh
       jc componente_color_OK      ;Saltar si esta.
       neg byte ptr [di]           ;Invertir direccion de cambio de color.
       mov al,[si]                 ;Obtener componente de color (R, G o B).
       add al,[di]                 ;Cambiar componente.
componente_color_OK:
       mov [si],al                 ;Guardar nuevo componente de color.
       inc di
       inc si
       loop ciclo_cambiar_paleta

  ;Entregar estos colores al controlador de VGA.
       call esperar_retrazado_vertical
       mov si,offset colores
       mov cl,0
       mov al,0
       mov dx,3C8h       ;Darselo al controlador de VGA.
       out dx,al
ciclo_grabar_paleta:
       mov dx,3C9h
       mov al,[si+rojo]  ;Obtener la componente roja del color.
       out dx,al         ;Entregarsela al controlador de VGA.
       mov al,[si+verde] ;Obtener la componente verde del color.
       out dx,al         ;Entregarsela al controlador de VGA. 
       mov al,[si+azul]  ;Obtener la componente azul del color.
       out dx,al         ;Entregarsela al controlador de VGA.
       add si,size paleta
       inc cl            ;Incrementar numero de color.
       jnz ciclo_grabar_paleta
esperar_timer_tick:
  ;Limpiar buffer doble.
       mov bx,buffer_doble   ;Apuntar al segmento del buffer doble.
       mov es,bx
       mov ax,0              ;Poner todo el buffer a negro.
       mov cx,32768          ;Cantidad de words a limpiar.
       mov di,0              ;inicio del buffer doble.
       cld
       rep stosw
       mov bx,buffer_doble2
       mov es,bx
       mov cx,32768          ;Cantidad de words a limpiar.
       rep stosw
       mov bx,buffer_doble3
       mov es,bx
       mov cx,32768          ;Cantidad de words a limpiar.
       rep stosw
       mov bx,buffer_doble4
       mov es,bx
       mov cx,32768          ;Cantidad de words a limpiar.
       rep stosw
       mov bx,buffer_doble5
       mov es,bx
       mov cx,45056/2        ;Cantidad de words a limpiar.
       rep stosw
  ;Esperar que venga el proximo timer tick.
       mov ax,40h
       mov es,ax
       mov al,es:[6Ch]       ;Obtener LSB del timer tick.
espera_timer_tick:
       cmp al,es:[6Ch]       ;Ver si cambio.
       jz espera_timer_tick  ;Volver si no es asi.
  ;Poner los circulos en el buffer doble.
       mov ax,size circulo
       mul cant_circulos
       add ax,offset circulos
       mov si,ax
ciclo_mostrar_circulos:
       sub si,size circulo
       mov cl,[si+color]
       mov al,byte ptr [si+radio]
       mov ch,al             ;Almacenar el radio.
       mul al
       mov di,ax             ;Almacenar el cuadrado del radio.
       mov ax,COLUMNAS
       mul word ptr [si+posY+2]
       add ax,word ptr [si+posX+2] ;Offset posicion superior izquierda circulo.
       adc dx,0              ;DX:AX = Offset del pixel.
       shld dx,ax,12         ;DX = Offset del pixel / 16.
       add dx,buffer_doble   ;DX = Segmento del buffer doble.
       mov es,dx
       and ax,000Fh          ;AX = Offset del primer pixel del circulo.
       mov bx,ax
       mov dl,ch
       neg dl
       inc dl                ;Valor de Y en el circulo.
ciclo_dibujo_circulo_eje_Y:
       mov dh,ch
       neg dh
       inc dh                ;Valor de X en el circulo.
       push bx               ;Salvar offset de columna izquierda.
ciclo_dibujo_circulo_eje_X:
   ;Si X^2 + Y^2 < R^2 el pixel se encuentra en el circulo, por lo que
   ;en este caso se debe utilizar el color del circulo.
       mov al,dl             ;Obtener valor de X.
       imul al               ;Hallar el cuadrado de X.
       mov bp,ax             ;Almacenarlo.
       mov al,dh             ;Obtener valor de Y.
       imul al               ;Hallar el cuadrado de Y.
       add bp,ax             ;BP = X^2 + Y^2
       cmp bp,di             ;Comparar contra el cuadrado del radio.
       jae apuntar_a_proxima_columna ;Saltar si fuera del circulo.
       mov es:[bx],cl        ;Poner el color del circulo.
apuntar_a_proxima_columna:
       inc bx                ;Apuntar a proxima columna.
       inc dh                ;Incrementar X en uno.
       cmp dh,ch             ;Ver si se termino la fila.
       jl ciclo_dibujo_circulo_eje_X ;Saltar si no es asi.
                             ;Atencion: como DH contiene un numero en
                             ;complemento a dos, la instruccion
                             ;JB no funciona aqui.
       pop bx                ;Restaurar offset de columna izquierda.
       add bx,COLUMNAS       ;Incrementar fila.
       inc dl                ;Incrementar Y en uno.
       cmp dl,ch             ;Ver si se termino la fila.
       jl ciclo_dibujo_circulo_eje_Y ;Saltar si no es asi.
  ;Actualizar posicion del circulo.
       mov eax,[si+posY]     ;Obtener fila superior del circulo.
       add eax,[si+incY]     ;Actualizar posicion.
       js choco_contra_fila_borde ;Saltar si choco contra el borde superior.
       shld ebx,eax,16       ;BX = Nueva fila superior del circulo.
       add bx,word ptr [si+radio]
       add bx,word ptr [si+radio] ;BX = Fila siguiente al inferior del circulo.
       cmp bx,FILAS          ;Ver si llego al limite inferior.
       jb guardar_nueva_fila
choco_contra_fila_borde:
       neg dword ptr [si+incY]   ;Rebotar.
       mov eax,[si+posY]     ;Obtener fila superior del circulo.
       add eax,[si+incY]     ;Actualizar posicion.
guardar_nueva_fila:
       mov [si+posY],eax     ;Guardar nueva fila superior del circulo.

       mov eax,[si+posX]     ;Obtener columna izquierda del circulo.
       add eax,[si+incX]     ;Actualizar posicion.
       js choco_contra_col_borde ;Saltar si choco contra el borde izquierdo.
       shld ebx,eax,16       ;BX = Nueva columna izquierda del circulo.
       add bx,word ptr [si+radio]
       add bx,word ptr [si+radio] ;BX = Columna siguiente a la derecha del
                             ;circulo.
       cmp bx,COLUMNAS       ;Ver si llego al limite derecho.
       jb guardar_nueva_columna
choco_contra_col_borde:
       neg dword ptr [si+incX]   ;Rebotar.
       mov eax,[si+posX]     ;Obtener columna izquierda del circulo.
       add eax,[si+incX]     ;Actualizar posicion.
guardar_nueva_columna:
       mov [si+posX],eax     ;Guardar nueva columna izquierda del circulo.

       cmp si,offset circulos
       jnz ciclo_mostrar_circulos
  ;Enviar el buffer doble a la pantalla.
       push ds
       pop fs                ;FS apunta al segmento de datos.
       mov bx,300            ;Cantidad de KB del buffer doble (640*480/1024).
       mov ax,buffer_doble
       mov ds,ax
       mov es,word ptr fs:SVGA_info[WinASegment]  ;Segmento de graficos de VGA.
       xor dx,dx             ;Poner a cero el numero de pagina.
ciclo_copia:
       push bx
       push dx
       mov ax,4F05h          ;Funcion para seleccionar pagina de video.
       mov bx,0000h          ;Seleccionar ventana "A" (unica disponible).
       int 10h               ;Llamar a BIOS de tarjeta SVGA.
       pop dx
       pop bx
       xor si,si
       xor di,di
       mov cx,bx
       cmp cx,word ptr fs:SVGA_INFO[WinGranularity]
       jb ultima_pagina
       mov cx,word ptr fs:SVGA_INFO[WinGranularity]
       shl cx,9
       jmp copiar_buffer
ultima_pagina:
       shl cx,9
       sub cx,COLUMNAS*32/2   ;No copiar zona reservada para texto.
copiar_buffer:
       cld
       rep movsw
       mov ax,ds
       mov cx,word ptr fs:SVGA_INFO[WinGranularity]
       shl cx,6
       add ax,cx
       mov ds,ax
       inc dx                ;Incrementar el numero de pagina.
       sub bx,word ptr fs:SVGA_INFO[WinGranularity]
       ja ciclo_copia
       mov ax,datos
       mov ds,ax
  ;Ver si se apreto alguna de las tres teclas (P, Enter o Escape).
       mov ah,01h            ;Servicio para ver si se apreto una tecla.
       int 16h               ;Llamar al servicio de teclado de BIOS.
       jz animacion          ;Volver a la animacion si no se apreto nada.
       mov ah,00h            ;Servicio para obtener tecla presionada.
       int 16h               ;Llamar al servicio de teclado de BIOS.
       cmp al,"p"            ;Se presiono tecla de cambiar paleta?
       jz cambiar_paleta     ;Saltar si es asi.
       cmp al,"P"            ;Se presiono tecla de cambiar paleta?
       jnz no_cambiar_paleta ;Saltar si no es asi.
cambiar_paleta:
       xor paleta_variable,1 ;Cambiar de estado la variable de paleta variable.
       jz paleta_es_fija     ;Saltar si la paleta es fija.
  ;Copiar la paleta original en la paleta de colores.
       push ds
       pop es
       mov si,offset paleta_original
       mov di,offset colores
       mov cx,size colores
       cld
       rep movsb
  ;Inicializar la matriz de cambio de paleta para que se incrementen las tres
  ;componentes de color (mayor saturacion).
       mov di,offset cambio_paleta
       mov al,1
       mov cx,size cambio_paleta
       rep stosb
       jmp animacion         ;Volver a la animacion.
paleta_es_fija:
       call cambiar_a_paleta_original
       jmp animacion         ;Volver a la animacion.
no_cambiar_paleta:
       cmp al,0Dh            ;Se apreto la tecla "Enter"?
       jz nuevo_circulo      ;Generar un nuevo circulo.
       cmp al,1Bh            ;Se apreto la tecla "Escape"?
       jnz animacion         ;Volver a la animacion si no es asi.
       call cambiar_a_paleta_original
       mov ah,00h            ;Cambiar modo de video.
       mov al,03h            ;Especifica modo texto: 80x25, 16 colores.
       int 10h               ;Llamar a servicio de video de BIOS.
       mov ax,4c00h          ;Fin del programa.
       int 21h

obtener_nro_aleatorio:
       mov eax,1812433253    ;Multiplicador de Borosh y Niederreiter.
       mul semilla
       add eax,432435211
       mov semilla,eax       ;Guardar nueva semilla.
       mul ebx               ;EDX = Numero entre cero y EBX - 1.
       mov eax,edx           ;EAX = Numero entre cero y EBX - 1.
       ret

cambiar_a_paleta_original:
       call esperar_retrazado_vertical
       mov si,offset paleta_original
       mov cl,0
       mov al,0
       mov dx,3C8h       ;Darselo al controlador de VGA.
       out dx,al
ciclo_grabar_paleta_original:
       mov dx,3C9h
       mov al,[si+rojo]  ;Obtener la componente roja del color.
       out dx,al         ;Entregarsela al controlador de VGA.
       mov al,[si+verde] ;Obtener la componente verde del color.
       out dx,al         ;Entregarsela al controlador de VGA. 
       mov al,[si+azul]  ;Obtener la componente azul del color.
       out dx,al         ;Entregarsela al controlador de VGA.
       add si,size paleta
       inc cl            ;Incrementar numero de color.
       jnz ciclo_grabar_paleta_original
       ret

esperar_retrazado_vertical:
       mov dx,3DAh
esperar_fin_retrazado:
       in al,dx
       and al,08h            ;Se esta realizando el retrazado vertical?
       jnz esperar_fin_retrazado ;Saltar si es asi.
esperar_inicio_retrazado:
       in al,dx
       and al,08h            ;Se esta realizando el retrazado vertical?
       jz esperar_inicio_retrazado ;Saltar si no es asi.
       ret

codigo ends

; Buffer doble de 640 * 480 = 307200
buffer_doble segment use16
       db 65535 dup (?)   ;Buffer para animacion.
buffer_doble ends
buffer_doble2 segment use16
       db 65535 dup (?)   ;Buffer para animacion.
buffer_doble2 ends
buffer_doble3 segment use16
       db 65535 dup (?)   ;Buffer para animacion.
buffer_doble3 ends
buffer_doble4 segment use16
       db 65535 dup (?)   ;Buffer para animacion.
buffer_doble4 ends
buffer_doble5 segment use16
       db 45056 dup (?)   ;Buffer para animacion.
buffer_doble5 ends

       end inicio
