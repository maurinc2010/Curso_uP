;=============================================================================
; Nombre del programa:   EJ02CA07.ASM
; Fecha de creaci¢n  :   Junio 28 de 1993
; Autor              :   J.A. Rojas Ponce
; Objetivo           :   Programa que transmite caracteres a trav‚s del
;                        puerto serial a otra PC.
;=============================================================================
; COMANDO DE ENSAMBLE    : Masm EJ02CA07;
; COMANDO DE LINKEAR     : Link EJ02CA07;
; COMANDO DE EJECUCION   : EJ02CA07 [Enter]
;
; NECESITA EL DOS.INC y BIOS.INC de la versi¢n del MASM 5.1.
;=============================================================================
;
; NOTA : Este programa contiene TECNICAS de programaci¢n del hardware
;        que no han sido cubiertas en ESTE libro. Sin embargo, el programa
;        se presenta para que usted pueda apreciar la forma en que se
;        manipulan las INTERRUPCIONES. No se desespere y  ESTUDIELO.
;=============================================================================
        DOSSEG

        .MODEL        small

        INCLUDE       \MASM\dos.inc
        INCLUDE       \MASM\bios.inc

        .STACK        100h

        .DATA

Bienvenida      db      ' Programa    : TRANSMISOR (Emula una terminal TONTA).',13,10
                db      ' Escrito por : J.A. Rojas Ponce',13,10
                db      ' Desde este momento, todo lo que se digite en esta terminal ser  mandado al ',13,10
                db      ' puerto serial. Cualquier byte que se encuentre en el buffer de recepci¢n ',13,10
                db      ' (enviado por otra terminal), ser  desplegado. Para terminar la sesi¢n,   ',13,10
                db      ' oprima la tecla de ESCAPE <ESC>.',13,10,13,10,'$'

Despedida       db      07h,' Todo ha sido LIBERADO y regresado a su estado NATURAL.$'
mens_err        db      07h,'COM1 no se encuentra instalado.',13,10,'$'
Version         db      07h,'Versi¢n de DOS incorrecta (necesito 2.x o mayor).',13,10,'$'
Buffer          db      1024 dup (?)   ; buffer de almacenamiento.
Buffer_emp      dw      OFFSET        Buffer
Buffer_fin      dw      OFFSET        Buffer_emp
Buffer_cab      dw      OFFSET  Buffer
Buffer_cola     dw      OFFSET  Buffer
Dir_UART        dw        ?
INT0C           dd        ?
Numero          db        4 dup(0),'$'

        .CODE

INICIA:
        mov        ax,@data ; permite el acceso al segmento de datos.
        mov        ds,ax

; Ajusta SS y SP relativos a DGROUP..

        cli                     ; inhibe interrupciones.
        mov        ss,ax        ; pon a SS y SP relativos a DGROUP..
        mov        sp,OFFSET STACK
        sti                     ; Habilita interrupciones de nuevo..

; Ajusta la memoria usada..

        mov        bx,sp        ; convierte el SP a p rrafos..
        mov        cl,4
        shr        bx,cl
        add        ax,bx
        mov        bx,es
        sub        ax,bx
        @ModBlok ax

; Checa la version de DOS.

        @Getver
        cmp        al,2          ; es mayor o igual a 2.x ?
        jge        TODO_BIEN ; si..
        @Cls
        @Dispstr  Version        ; Error de versi¢n, necesito 2.x o mayor..
        @Exit    1               ; termina con c¢digo de error 1.

; Ahora empieza lo bueno. Primero checa en memoria de BIOS la
; direcci¢n del puerto COM 1. Si ‚ste existe contin£a de lo con-
; trario termina con un c¢digo de error 2.


TODO_BIEN:

        mov        ax,40h         ; Prep rate para inspeccionar el  rea de BIOS.
        mov        es,ax          ; mediante el registro ES.
        mov        ax,word ptr es:[0]  ; Obt‚n la direcci¢n de COM1.
        mov        dir_UART,ax    ; guarda la direcci¢n para futura referencia.
        or         ax,ax          ; si COM 1 no est  instalado, entonces termina.
        jnz        SIHAY          ; si hubo .....
        @Cls
        @DispStr Mens_err
        @Exit    2

; Guarda y modifica el vector original 0ch. Apunta a nuestro vector
; de interrupci¢n, llamado "MI_INT0CH".

SIHAY:

        @Cls                        ; manda el mensaje de instrucciones y
        @DispStr   Bienvenida

        @GetInt 0ch                 ; INT de la IRQ 4 (0ch)
        mov        word ptr INT0C,bx
        mov        word ptr INT0C[2],es

        push        ds              ; guarda DS para alterar el vector original.
        push        cs
        pop        ds
        mov        ax,250ch
        mov        dx,OFFSET MI_INT0C
        int        21h
        pop        ds               ; restaura DS original..


; Inicializa el UART a 9600 sin paridad (N), 8 bits y 1 stop bit.

        mov        ax,00A3h
        xor        dx,dx
        int        14h

; Desenmascara el IRQ4 del registro de m scaras del 8259. El registro
; anterior se encuentra en el puerto 21h.


        in        al,21h
        and       al,0EFh
        out       21h,al

; Manipula directamente el UART, inicializando el IER (Interrupt enable
; register) en el cual los bits 7,6,5 y 4 siempre son 0 y :
; Bit 3 = Alg£n cambio en el pin de entrada del RS232.
; Bit 2 = Error o Break detectado.
; Bit 1 = El registro de Transmit Holding  est  vac¡o.
; Bit 0 = Dato listo en registro de recepcion (buffer).
;
; Posteriormente, habilita la interrupci¢n de datos recibidos por medio
; del bit 0 del registro de interrupciones.
;
 ; Finalmente, activa GP02, DTR y RTS por medio del registro de modem..


        mov       dx,dir_UART        ; direcci¢n del UART.
        add       dx,3               ; deshabilita DLAB en el registro
        in        al,dx              ; de la l¡nea de control del UART.
        and       al,07fh
        out       dx,al

        sub        dx,2                ; accesa el registro de interrupciones
        mov        al,1                ; y pon el bit 0 para recibir interrupciones.
        out        dx,al

        add        dx,3
        mov        al,0Bh
        out        dx,al

; Manda y recibe caracteres hasta recibir un escape..

        CALL        PROCESA


; Resetea el sistema y salte..

        mov        dx,dir_UART       ; blanquea los bits 0, 1 y 3 del registro
        add        dx,4              ; de m¢dem..
        in         al,dx
        and        al,0f4h
        out        dx,al

        sub        dx,3              ; deshabilita las interrupciones del UART.
        xor        al,al
        out        dx,al

        in        al,21h             ; enmascara int IRQ4 del 8259..
        or        al,10h             ; es el bit 4.
        out       dx,al

        push      ds
        mov       ax,250ch          ; resetea el vector 0ch
        lds       dx,[int0c]
        int       21h
        pop       ds
        @Cls
        @DispStr  Despedida
        @Exit     0

; Mi interrupci¢n y rutinas de soporte...


MI_INT0C        PROC        FAR

        push        ax
        push        bx
        push        dx
        push        ds

        mov        ax,@data
        mov        ds,ax
        mov        dx,dir_UART   ; aseg£rate de que DLAB est‚ libre..
        add        dx,3
        in         al,dx
        and        al,07fh
        out        dx,al

; Lee el car cter del UART..

        mov       dx,dir_UART
        in        al,dx                ; lee el byte..

        mov       bx,Buffer_cab   ; calcula la posici¢n donde vamos a
        mov       dx,bx           ; guardar el byte, checando que el
        inc       dx              ; buffer no se encuentre lleno.
        cmp       dx,Buffer_fin
        jne       NO_LLENO
        mov       dx,Buffer_emp

NO_LLENO:

        cmp       dx,Buffer_cola  ; fin de buffer ?
        je        SALTE
        mov       [bx],al         ; guarda el byte en el buffer
        mov       Buffer_cab,dx

SALTE:

        mov        al,20h         ; indica fin de interrupci¢n al 8259..
        out        20h,al
        sti
        pop        ds
        pop        dx
        pop        bx
        pop        ax
        iret
MI_INT0C        endp


; Rutina que procesa los bytes que entran a trav‚s del buffer y manda
; caracteres al otro dispositivo..


PROCESA        PROC        NEAR

PROCESA_01:

        mov        ah,1           ; hay algo esperando en el buffer del teclado ?
        int        16h
        jz         PROCESA_02

        xor        ah,ah          ; lee el c¢digo.
        int        16h
        or         al,al          ; ignora los c¢digos extendidos..
        jz         PROCESA_02
        cmp        al,01bh ; es ESCAPE ?
        jne        PROCESA_03     ; no, as¡ que despliega..
        ret

; Despliega el car cter digitado en esta terminal y m ndalo atrav‚s
; del puerto serial.


PROCESA_03:

        push        ax
        CALL        DESPLIEGA_CAR
        pop         ax
        CALL        MANDA_CAR

; No hubo ning£n car cter pendiente en el buffer del teclado. Por lo
; tanto, checamos si existe alguno en el buffer de recepci¢n y lo
; desplegamos en esta terminal..


PROCESA_02:

        mov        ax,Buffer_cola  ; Checa si el buffer est  vac¡o.
        cmp        ax,Buffer_cab   ; Si lo est , regresa al principio
        je         PROCESA_01      ; de esta rutina para procesar el teclado de nuevo.

        CALL       LEE_CAR         ; extrae un byte del buffer..
        CALL       DESPLIEGA_CAR   ; despli‚galo en esta terminal..
        jmp        PROCESA_01      ; regresa de nuevo a procesar..
PROCESA endp


; Esta rutina espera a que exista un car cter o byte en el puerto serial,
; lo lee y lo regresa en AL.

LEE_CAR        PROC        NEAR

LEE_CAR_01:

        mov        bx,Buffer_cola  ; itera hasta que un car cter aparezca.
        cmp        bx,Buffer_cab   ; en el puerto serial..
        je         LEE_CAR_01

        cli                        ; deshabilita interrupciones.
        mov        al,[bx]         ; lee el byte del buffer.
        inc        bx              ; avanza la cola..
        cmp        bx,Buffer_fin   ; regresa al principio del buffer si es
        jne        LEE_CAR_02      ; necesario..
        mov        bx,Buffer_emp

LEE_CAR_02:

        mov        Buffer_cola,bx
        sti
        ret
LEE_CAR endp



; Esta rutina despliega un car cter en la terminal..

DESPLIEGA_CAR        PROC        NEAR

        push    cx
        xor     ch,ch
        mov     cl,al
        mov     ah,0eh
        xor     bh,bh
        int     10h
        cmp     cl,13
        jnz     DESPLIEGA_CAR_01
        mov     al,10
        xor     bh,bh
        int     10h

DESPLIEGA_CAR_01:

        pop     cx
        ret
DESPLIEGA_CAR   endp


; Esta rutina manda un byte digitado en esta terminal al puerto serial..


MANDA_CAR  PROC   NEAR

        push       ax
        mov        dx,dir_UART
        add        dx,5            ; apunta al registro de control de l¡nea.

MANDA_CAR_01:

        in        al,dx            ; lee la l¡nea.
        test      al,20h           ; itera hasta que se encuentre libre la l¡nea
        jz        MANDA_CAR_01     ; el bit 5 de este registro.

        sub       dx,5             ; manda el car cter.
        pop       ax
        out       dx,al
        ret
MANDA_CAR         endp

        END      INICIA

