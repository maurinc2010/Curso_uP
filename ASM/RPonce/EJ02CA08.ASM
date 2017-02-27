;************************************************************************
; Nombre del programa:   EJ02CA08.ASM
; Fecha de creaci¢n  :   Junio 28 de 1992
; Autor              :   J.A. Rojas Ponce
; Objetivo           :   Programa que genera la huella de un archivo.
;*************************************************************************
; COMANDO DE ENSAMBLE    : Masm EJ02CA08;
; COMANDO DE LINKEAR     : Link EJ02CA08;
; COMANDO DE EJECUCION   : EJ02CA08 [Enter]
;*************************************************************************
;
; NOTA : se procura usar SOLO las instrucciones que se han visto o explicado.
;        El objetivo es con fines educativos y NO de optimizaci¢n o eficien-
;        cia. Por favor, NO SE DESEPERE y est£dielo. NOTE TAMBIEN de que
;        se definen las MACROS a usar internamente en el programa.
;**************************************************************************
;
; RESTRICCIONES DEL PROGRAMA :
;
;          - S¢lo puede trabajar con archivos de hasta 64K
;          - S¢lo procesa un archivo a la vez.
;**************************************************************************

  DOSSEG
  .MODEL  small

; ---------------------------------------------------------------------
;                       M   A   C  R  O  S
;----------------------------------------------------------------------

; ---------------------------------------------------------------------
; MACRO  : CARGA
; Carga registros sencillos, de palabra y de doble palabra.
; 0 o 2 = Palabra
; 4     = Doble palabra
; ---------------------------------------------------------------------

CARGA MACRO Valor
    IF   TYPE (Valor) EQ 2
        xor  cx,cx
        mov  dx, dub
    ELSEIF TYPE (Valor) EQ 4
        mov  cx, dub[2]
        mov  dx, dub[0]
    ELSEIF TYPE (Valor) EQ 0
        xor     cx,cx
        mov     dx, valor
    ELSE
        .ERR
        %OUT Argumento ILEGAL....
    ENDIF
ENDM

; ----------------------------------------------------------------------
; MACRO   :   DESP_CADENA
; Despliega una cadena de caracteres.
;
; Al entrar   :
;               AH    = 09H
;               DS:DX = Apuntador a la cadena.
;
; Al regresar :
;               NADA.
; ---------------------------------------------------------------------

@DESP_CADENA MACRO Cadena
    mov     ah, 9
    mov     dx,OFFSET Cadena
    int     21h
ENDM

;------------------------------------------------------------------------------
; MACRO  :  LEE_ARCH
; Lee una cierta cantidad de bytes de un archivo o dispositivo.
;
; Al entrar   :
;               AH  = 3FH
;               BX  = Canal asignado al archivo (cuando se abri¢).
;               CX  = Numero de bytes a leer.
;            DS:DX  = Apuntador al buffer donde se guardar n los bytes le¡dos.
;
; Al regresar :
;               Si todo estuvo bien, CF = 0 y AX = al n£mero de bytes REALMENTE
;               le¡dos. De lo contrario, CF <> 0 y AX = C¢digo de error.
; -------------------------------------------------------------------------------


@LEE_ARCH MACRO Canal, Bytes, Buffer_Arch
    mov     bx, Canal
    mov     cx, bytes
    mov     ds, BUFFER_ARCH
    mov     dx, 0
    mov     ah, 3Fh
    int     21h
ENDM

; -------------------------------------------------------------------------
; MACRO   :   ABRE_ARCHIVO
; Abre un archivo.
;
; Al entrar   :
;               AH  = 3DH
;               AL  = Modo de operaci¢n.
;            DS:DX  = Apuntador al nombre del archivo.
;
; Al regresar :
;               Si todo estuvo bien, CF = 0 y AX = el canal asignado al
;               archivo. De lo contrario, CF <> 0 y AX = C¢digo de error.
; -------------------------------------------------------------------------

@ABRE_ARCHIVO  MACRO Ruta, Operacion
    push    es
    pop     ds
    mov     dx, Ruta
    mov     ax, 3D00h + (Operacion AND 0FFh)
    int     21h
ENDM

; -------------------------------------------------------------------------
; MACRO   :   CIERRA_ARCH
; Cierra un archivo.
;
; Al entrar   :
;               AH  = 3EH
;               BX  = Canal asignado al archivo.
;
; Al regresar :
;               Si hubo error, CF <> 0 y AX = C¢digo de error.
; -------------------------------------------------------------------------


@CIERRA_ARCH MACRO Canal
    mov     bx, Canal
    mov     ah, 3Eh
    int     21h
ENDM

; -----------------------------------------------------------------------------
; MACRO    :   TAMANO_ARCH
; Obtiene el tama¤o del archivo.
;
; Al entrar   :
;               AH  = 42H
;               AL  = Punto de partida del movimiento.
;               BX  = Canal asignado al archivo.
;            CX:DX  = Distancia en bytes a mover el apuntador.
;
; Al regresar :
;               Si todo estuvo bien, CF = 0 y DX:AX = localizaci¢n actual
;               del apuntador. De lo contrario, CF <> 0 y AX = C¢digo de error.
; ------------------------------------------------------------------------------

@TAMANO_ARCH MACRO Canal
    mov     bx, Canal
    xor     cx,cx
    xor     dx,dx
    mov     ax, 4202h
    int     21h
    push    dx
    push    ax
    xor     dx,dx
    mov     ax, 4200h
    int     21h
    pop     ax
    pop     dx
ENDM

; ------------------------------------------------------------------------------
; MACRO   :  MUEVE_APUNTA
; Mueve el apuntador del archivo.
; 
; Al entrar   :
;               AH  = 42H
;               AL  = Punto de partida del movimiento.
;               BX  = Canal asignado al archivo.
;            CX:DX  = Distancia en bytes a mover el apuntador. 
;
; Al regresar :
;               Si todo estuvo bien, CF = 0 y DX:AX = localizaci¢n actual 
;               del apuntador. De lo contrario, CF <> 0 y AX = C¢digo de error.
; --------------------------------------------------------------------------------

@MUEVE_APUNTA MACRO Canal, Distancia
    IFNB    <distancia>
        CARGA <distancia>
    ENDIF
    mov     bx, handle
    mov     ax, 4200h
    int     21h
ENDM


; ---------------------------------------------------------------------------
; MACRO   : SALTE
; Termina programa.
;
; Al entrar   :
;               AH  = 4CH
;               AL  = C¢digo de retorno.
;
; Al regresar :
;               NADA.
; ----------------------------------------------------------------------------

@SALTE MACRO Codigo_error
    IFB     <Codigo_error>
        mov     ah, 4Ch
    ELSE
        mov     ax, 4C00h + (Codigo_error AND 0FFh)
    ENDIF
    int     21h
ENDM


; ----------------------------------------------------------------------------
; MACRO   :  SOLICITA_BLOQUE
; Solicita bloque de memoria.
;
; Al entrar   :
;              AH =  48H
;              ES =  Segmento del bloque.
;
; Al regresar :
;               Si todo estuvo bien, CF = 0 . De lo contrario, CF <> 0
;               y AX = C¢digo de error.
; ----------------------------------------------------------------------------

@SOLICITA_BLOQUE  MACRO Parrafos
    mov     bx, Parrafos
    mov     ah, 48h
    int     21h
ENDM

; ----------------------------------------------------------------------------
; MACRO   :  MODIFICA_BLOQUE
; Modifica un bloque de memoria.
;
; Al entrar   :
;              AH =  4AH
;              ES =  Segmento del bloque.
;              BX =  P rrafos.
;
; Al regresar :
;               Si todo estuvo bien, CF = 0 . De lo contrario, CF <> 0
;               y AX = C¢digo de error.
; ----------------------------------------------------------------------------

@MODIFICA_BLOQUE MACRO Parrafos
    mov     bx, Parrafos
    mov     ah, 4Ah
    int     21h
ENDM


; ----------------------------------------------------------------------------
; MACRO   : VERSION_DOS
; Averigua la versi¢n de DOS.
;
; Al entrar   :
;              AH =  30H
;
; Al regresar :
;              NADA.
; ----------------------------------------------------------------------------

@VERSION_DOS MACRO
    mov     ah, 30h
    int     21h
ENDM

; ----------------------------------------------------------------------------
; MACRO   : BORRA_PANTALLA
; Borra la pantalla.
;
; Al entrar   :
;              AH =  0FH y 0.
;
; Al regresar :
;              NADA.
; ----------------------------------------------------------------------------

@BORRA_PANTALLA   MACRO
            mov    ah,0fh          ; Borra la pantalla...
            int    10h
            mov    ah,0
            int    10h
            ENDM


; --------------------------------------------------------------------------
;                A  R  E  A     D  E     P  I  L  A
;
;   Declara 256 bytes para uso de la pila.
; ---------------------------------------------------------------------------

  .STACK  100h

  .DATA

; --------------------------------------------------------------------------
;                A  R  E  A     D  E     D  A  T  O  S
;
;   Contiene la declaraci¢n de los datos y variables a usar dentro del pro-
;   grama. Los errores regresados por el sistema y que pueden ser interpre
;   tados por archivos .BAT se encuentran detallados en las variables ERRORX.
; ---------------------------------------------------------------------------

; Mensajes...

INSTALA   db       07h,0dah,20 dup(0c4h),' GENERADOR DE HUELLAS/DOS    Versi¢n 1.0 '
          db       17 dup (0c4h),0bfh
          db       0b3h,78 dup(20h),0b3h
          db       0b3h,' PROPOSITO  : Generar un checksum de un archivo determinado.                  ',0b3h
          db       0b3h,78 dup(20h),0b3h
          db       0b3h,' SINTAXIS   : EJ02CA08 [Nombre de archivo] <CR>.                              ',0b3h
          db       0b3h,78 dup(20h),0b3h
          db       0c0h,13 dup(0c4h),' ------------------> por Jorge Alberto Rojas Ponce ',14 dup(0c4h),0d9h
          db       13,10,13,10,'$'

ERROR1    db      07h,13,10,"Necesito DOS 2.0 o mayor !!!",13,10,"$"
ERROR2    db      07h,13,10,"NO puedo procesar el archivo, est  muy grande !!!.",13,10,"$"
ERROR3    db      07h,13,10,'NO PUDE leer el archivo !!!.',13,10,'$'
ERROR4    db      07h,13,10,'NO TENGO SUFICIENTE memoria para procesar el archivo !!!.',13,10,'$'
ERROR5    db      07h,13,10,'ERROR GRAVE, NO puedo ejecutar el programa... !!!.',13,10,'$'
ERROR6    DB      07h,13,10,'NO EXISTE el archivo...!!!$'
ABORTA    db      07h,13,10,'***  ABORTANDO EL PROGRAMA  ***$'
CHECKSUM  db      07h,13,10, '*** EL CHECKSUM DEL ARCHIVO ES :       ','$'

; Variables..

CANAL     DW      ?                ; Canal asignado al archivo.
TAMA_ARCH DW      ?                ; Tama¤o del archivo.
SEG_BUF   DW      ?                ; segmento del buffer del archivo.
LONG_BUF  DW      ?                ; Longitud del buffer.


; --------------------------------------------------------------------
;             S E C C I O N    D E     C O D I G O
; --------------------------------------------------------------------

.CODE

; ---------------------------------------------------------------------
; Establece el acceso de nuestros datos e inicializa el STACK.
;-----------------------------------------------------------------------

EMPIEZA:

        mov  ax,@DATA              ; Inicializa el segmento de datos.
        mov  ds,ax
        cli                        ; Deshabilita interrucpiones.
        mov  ss,ax                 ; Convierte SS y
        mov  sp,OFFSET STACK       ; SP relativos a DGROUP
        sti

;------------------------------------------------------------------------
; Primero vamos a liberar la memoria que no estamos usando. Posterior-
; mente solicitamos 64K para usar como buffer de procesamiento del archi-
; vo.
;-----------------------------------------------------------------------

       mov  bx,sp                  ; Convierte el SP a p rrafos.
       mov  cl,4                   ; para obtener el tama¤o del stack.
       shr  bx,cl
       add  ax,bx                  ; S£male SS para obtener el final del programa.
       mov  bx,es                  ; Obt‚n el principio del programa.
       sub  ax,bx                  ; Memoria usada = Principio - Final.
       @MODIFICA_BLOQUE ax         ; Libera memoria NO USADA.

; ---------------------------------------------------------------------
; Solicita memoria para el buffer del archivo. Si todo va bien, guarda
; el segmento de memoria asignado por DOS, as¡ como la longitud del
; buffer (esta longitud es en realidad el tama¤o del buffer en p rra-
; fos).
; ---------------------------------------------------------------------

          @SOLICITA_BLOQUE 0FFFH
          jnc     MEM_01
          @BORRA_PANTALLA
          @DESP_CADENA  ERROR4
          @SALTE   1
MEM_01:
          mov  SEG_BUF,ax          ; Guarda el segmento del buffer.
          mov  LONG_BUF,bx         ; Guarda la longitud del buffer.

; ---------------------------------------------------------------------
; Versi¢n de DOS debe ser mayor a 2.0
; ---------------------------------------------------------------------

          @VERSION_DOS             ; Versi¢n de DOS.
          cmp  al,2                ; Necesitamos 2.0 o mayor..
          jge  CONTINUA
          @BORRA_PANTALLA
          @DESP_CADENA ERROR1
          @SALTE  2

; -----------------------------------------------------------------------
; Averigua si hay algo en la l¡nea de comandos. Si lo hay t¢malo como
; el nombre del archivo. Si no hay nada, despliega instrucciones y s lte
; con un c¢digo de error 3. La l¡nea de comando empieza en el byte offset
; 80H (cantidad de bytes) y de 81H hasta X tiene la cola de comandos.
;
; PARA TU INFORMACION :
;                      Al iniciar la ejecuci¢n de este programa, CS apunta
; al primer byte de c¢digo despu‚s del PSP, DS y ES apuntan al PSP. Como DS
; ya ha sido inicializado al segmento de datos (ya no APUNTA al PSP) s¢lo
; podemos usar ES para accesar la cola de comandos (que se encuentra en el
; PSP).
; ------------------------------------------------------------------------

CONTINUA:

          cmp     byte ptr es:[80H],0  ; hay algo en la cola de comandos ?
          jnz     CONTINUA_01      ; SI !, de lo contrario despliega
          @BORRA_PANTALLA          ; las instrucciones y s lte con un
          @DESP_CADENA INSTALA     ; C¢digo de error 3.
          @SALTE  3

CONTINUA_01:

          mov     bl,es:[80H]      ; obt‚n la cantidad de bytes en la cola
          xor     bh,bh            ; y considera esto el nombre del archivo.
          mov     WORD PTR es:[bx+81H],0  ; convierte nombre a ASCIIZ.
          push    ds
          @ABRE_ARCHIVO 82h,0      ; Abre archivo..
          pop     ds
          jc      NOHAY            ; si no existe o ERROR SALTE..
          mov     CANAL,ax         ; de lo contrario, guarda el canal.
          jmp     CONTINUA_02

; No hay archivo

NOHAY:    @BORRA_PANTALLA
          @DESP_CADENA  ERROR6
          @SALTE  4

; ------------------------------------------------------------------------
; Checa el tama¤o del archivo. NO PUEDE SER > a 64K. Sabemos que es mayor
; 64K si DX <> 0 (CX es la parte menos significativa del tama¤o, por lo
; tanto su m xima capacidad es de 64K). Una vez sabiendo que el archivo es
; menor a 64K, lo convertimos en p rrafos y checamos si el espacio en me-
; moria que nos fue asignado por DOS, es mayor  o igual al tama¤o del ar-
; chivo.
; ------------------------------------------------------------------------

CONTINUA_02:

         @TAMANO_ARCH CANAL        ; Tama¤o del archivo.
         or   dx,dx                ; mayor a 64K ?
         jne  GRANDE               ; S¡ !.
         mov  TAMA_ARCH,ax         ; Guarda el tama¤o.
         mov  cx,4                 ; Convierte a p rrafos y checa
         shr  ax,cl                ; que quepa en el espacio que nos
         cmp  ax,LONG_BUF          ; asign¢ DOS.
         jle  CONTINUA_03

GRANDE:
         @BORRA_PANTALLA
         @DESP_CADENA  ERROR2
         @SALTE   5

; ------------------------------------------------------------------------
; Lee al buffer de memoria la cantidad de bytes especificadas por el
; tama¤o del archivo.
; ------------------------------------------------------------------------

CONTINUA_03:

         push  ds
         @LEE_ARCH Canal, TAMA_ARCH, SEG_BUF
         pop  ds
         jnc  CONTINUA_04
         @BORRA_PANTALLA
         @DESP_CADENA ERROR3
         @SALTE  6

; ------------------------------------------------------------------------
; Calcula el checksum.
; ------------------------------------------------------------------------


CONTINUA_04:

        push   bx
        push   si
        push   es
        mov    ax,SEG_BUF
        mov    es,ax
        xor    ax,ax
        mov    bx,ax
        mov    si,0
        mov    cx,TAMA_ARCH

OTRO_BYTE:

        mov    bl,es:[si]
        add    ax,bx
        inc    si
        loop   OTRO_BYTE
        pop    es
        pop    si
        pop    bx

; ------------------------------------------------------------------------
; Pon resultados en video. Primero convierte el checksum a hexadecimal y
; despu‚s ponlo en la l¡nea de resultado. AX tiene el checksum.
; ------------------------------------------------------------------------

        push   ds                  ; permite el acceso a la l¡nea de
        pop    es                  ; resultados mediante ES.
        mov    di, OFFSET CHECKSUM + 35
        push   cx
        push   di
        mov    cx,4                ; d¡gitos..
        cld

MAS_BYTES:

        rol    ax,1                ; nibble alto en los 4 bits bajos.
        rol    ax,1
        rol    ax,1
        rol    ax,1
        push   ax
        and    al,0FH              ; aisla el nibble bajo..
        or     al,30H              ; convierte a ASCII.
        cmp    al,39H              ; ajusta por si es d¡gito > 9.
        jbe    GUARDALO
        add    al,7                ; Letra A-F..

GUARDALO:

        stosb
        pop     ax
        loop    MAS_BYTES
        pop     di
        pop     cx

; Despliega resultado..

        @BORRA_PANTALLA
        @DESP_CADENA  INSTALA
        @DESP_CADENA  CHECKSUM
        @SALTE

END   EMPIEZA
