; Realizar un programa en formato .COM que pase a modo protegido.
; Debe haber un segmento de datos que ocupe el primer MB de memoria. 
; Llenar las posiciones de memoria 0B8000h-0B87FFh con la secuencia
; 31h, 07h, 31h, 07h, ... (esta es la zona del buffer de video).
; Al finalizar, volver a modo real y terminar el programa.
;
; Hecho por Dario Alejandro Alpern el 13 de abril de 1998.
;
CANT_DESCRIPTORES_GDT EQU 2 ; Cantidad de descriptores en la GDT.
   
          .386P           ;Este programa corre en 80386 o uP posterior.
                          ;Se agrega la "P" ya que se van a ejecutar
                          ;instrucciones privilegiadas.
codigo    segment use16   ;El segmento es de 16 bits.
                          ;Todos los programas DOS en 386 deben tener USE16.
          assume cs:codigo,ds:codigo
          org 100h        ;Todo programa .COM debe tener esta directiva ya
                          ;que los primeros 256 bytes del segmento estan
                          ;reservados para el Program Segment Prefix (PSP).
comienzo: jmp short inicio ;Saltear la zona de datos.
imagen_GDTR label fword   ;Indica que la imagen del GDTR ocupa 6 bytes.
                          ;La directiva LABEL no reserva espacio en memoria.
limite_GDTR dw CANT_DESCRIPTORES_GDT*8-1
                          ;El limite del GDTR es uno menos que la longitud
                          ;de la GDT (Tabla de Descriptores Globales).
base_GDTR dd 0            ;Se llena en tiempo de ejecucion.

GDT      db 8 dup (0)     ;El primer descriptor de la GDT nunca se usa.
         dw 0FFFFh        ;Bits 15-0 del limite del segmento de datos.
         dw 0000h         ;Bits 15-0 de la base del segmento de datos.
         db 00h           ;Bits 23-16 de la base del segmento de datos.
         db 10010010b     ;Byte de derechos de acceso.
                          ;   Bit 7 = Present (1 = si)
                          ;   Bits 6-5 = Descriptor Privilege Level (00).
                          ;   Bit 4 = Segment Descriptor (1 = datos o codigo).
                          ;   Bit 3 = Executable (0 = datos).
                          ;   Bit 2 = Expansion Direction (0: offset<=limite).
                          ;   Bit 1 = Writeable (1 = se puede escribir).
                          ;   Bit 0 = Accessed (0 = el segmento no se accedio).
         db 0Fh           ;Byte miscelaneo.
                          ;   Bit 7 = Granularidad (0 = limite x1).
                          ;   Bit 6 = Default Instruction (0 = 16 bits).
                          ;   Bits 5-4 = No usados.
                          ;   Bits 3-0 = Bits 19-16 del limite.
         db 00h           ;Bits 31-24 del limite.

inicio: 
;
; Lo primero que hay que hacer es inicializar el valor base de GDTR.
; El valor absoluto depende de donde el DOS puso el programa en memoria,
; por eso hay que leer el registro de segmento CS para saber cual es el
; valor del segmento donde se encuentra la Global Descriptor Table.
;
         mov ax,cs                ; AX = Segmento de la GDT.
         mov bx,offset GDT        ; BX = Offset de la GDT.
         movzx eax,ax             ; Extender a 32 bits.
         movzx ebx,bx
         shl eax,4                ; Base GDT = Segmento GDT * 16 + Offset GDT
         add eax,ebx              ; EAX = Base de la GDT.
         mov base_GDTR,eax        ; Almacenar la base de la GDT.
         cli                      ; Deshabilitar interrupciones.
         lgdt imagen_GDTR         ; Cargar el GDTR con la base y limite de GDT.
         smsw ax                  ; Leer la Machine Status Word (MSW).
         or al,1                  ; Poner a uno el bit Protection Enable (PE).
         lmsw ax                  ; Almacenar la MSW. En este momento el uP
                                  ; corre en modo protegido.
         jmp short $+2            ; Vaciar la cola de instrucciones.
         mov ax,8                 ; AX = Selector del segmento de datos.
         mov ds,ax                ; Cargar el nuevo segmento de datos.
         mov edx,0B8000h          ; Direccion inicial donde se van a poner
                                  ; los datos.
         mov cx,800h/2            ; Cantidad de palabras (words) a poner.
ciclo_llenado:
         mov word ptr [edx],0731h ; Dato a poner en memoria.
         add edx,2                ; Apuntar a la siguiente palabra.
         loop ciclo_llenado       ; LOOP siempre usa CX como contador.
         mov eax,cr0              ; Obtener el valor del registro de control 0.
         and al,0FEh              ; Poner a cero el bit Protection Enable (PE).
         mov cr0,eax              ; Cargarlo. En este momento el uP esta en
                                  ; modo real nuevamente.
         jmp short $+2            ; Vaciar la cola de instrucciones.
         sti                      ; Volver a habilitar interrupciones.
         mov ax,4C00h             ; Funcion de DOS para terminar el programa.
         int 21h
codigo   ends                     ; Final del unico segmento.
         end comienzo
