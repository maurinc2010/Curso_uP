;=============================================================================
; Nombre del programa:   EJER12.ASM
; Objetivo           :   Demostrar el uso de FCB'S para ACCEDER archivos.
;                        El programa permite la captura y consulta de
;                        los registros en un archivo.
;=============================================================================
; COMANDO DE ENSAMBLE    : Masm EJER12;
; COMANDO DE LINKEAR     : Link EJER12;
; COMANDO DE EJECUCION   : EJER12 [Enter]
;=============================================================================
;
; NOTA : Se procura usar SOLO las instrucciones que se han visto o explicado.
;        El objetivo es con fines educativos y NO de optimizaci¢n o eficien-
;        cia. Por favor, NO SE DESEPERE y est£dielo.
;
; EL PROGRAMA HA SUFRIDO BREVES MODIFICACIONES QUE NO PUDIERON SER INCLUIDAS
; EN EL TEXTO ORIGINAL. TODAS AQUELLAS MODIFICACIONES SE ENCUENTRAN DOCU-
; NTADAS, PRECEDIDAS POR TRES ASTERISCOS *** Y EN MAYUSCULAS.
;=============================================================================

INCLUDE MACROBIB.001               ; biblioteca de macros

;--- Define el modelo de memoria

.MODEL SMALL

;--- Los Datos

.Data

;-----------------------------------------------------------------------------
; Define mensajes y variables de uso general.
;-----------------------------------------------------------------------------

Mensaje  DB  'Bienvenidos a EJ01CA08. Programa que le permite manejar '
         DB  ' ARCHIVOS FCB. Usted', 13,10,'puede capturar y consultar la in'
         DB  'formaci¢n grabada en el archivo. Para poder',13,10
         DB  'continuar OPRIMA CUALQUIER TECLA....'
         DB  13,10,'$'
Selec    DB  'SELECCIONE-> (1) - Captura Nombre, (2) - Consulta Registros y (3) - Terminar : $'
No_Esp   DB  'ERROR : no hay espacio en el directorio para el ARCHIVO. Oprima CUALQUIER TECLA.$'
No_Cerr  DB  'ERROR : no pude CERRAR el archivo. Oprima CUALQUIER TECLA.$'
No_Esc   DB  'ERROR : no pude GRABAR el REGISTRO. Oprima CUALQUIER TECLA.$'
No_Lee   DB  'ERROR : no pude LEER el REGISTRO. Oprima CUALQUIER TECLA.$'
No_Tecla DB  'ERROR : opciones VALIDAS son del 1 al 3. Oprima CUALQUIER TECLA.$'
Fin_Arc  DB  'He llegado al FIN DE ARCHIVO. Oprima CUALQUIER TECLA.$'
Cod_Err  DB  0                     ; C¢digo de error
Cta_Act  DW  0                     ; Cuenta actual de bytes procesados
Borra    DB  '                                                                               $'
Un_Espa  DB  ' '                   ; Un espacio
Funcion  DB  0                     ; Funci¢n a realizar
Rango1   DB  0                     ; Primer rango de verificaci¢n
Rango2   DB  0                     ; Segundo rango de verificaci¢n
Mens1    DB  'AGREGANDO REGISTROS............$'
Mens2    DB  'CONSULTANDO REGISTROS..........$'
Nombre   DB  'NOMBRE   :  $'
Telef    DB  'TELEFONO :  $'

;-----------------------------------------------------------------------------
; Define el buffer a usar para la INT 21 funci¢n 0AH.
;-----------------------------------------------------------------------------

BufferT  DB     31                 ; Cantidad de bytes del buffer
Buf_Cta  DB     ?                  ; Cuenta de bytes procesados
BufferR  DB     31 DUP (' ')       ; Buffer real de los datos

;-----------------------------------------------------------------------------
; Define el FCB del archivo
;-----------------------------------------------------------------------------

FCB_Drive DB    0                  ; Unidad l¢gica a usar
FCB_Nom   DB    'COMPUTEC'         ; Nombre del archivo
FCB_Ext   DB    'DAT'              ; Extensi¢n del archivo
FCB_BA    DW    0                  ; Bloque actual
FCB_TR    DW    0                  ; Tama¤o del registro
FCB_TA    DW    2 DUP(?)           ; Tama¤o de archivo
FCB_Fecha DW    ?                  ; Fecha del archivo
          DB    10 DUP (?)
FCB_RA    DB    0                  ; Registro actual
FCB_RR    DW    2 DUP (?)          ; Registro relativo

;-----------------------------------------------------------------------------
; Los campos de la base de datos. Aqu¡ se pueden agregar m s campos
; siempre y cuando se ajuste la misma.
;-----------------------------------------------------------------------------

Nom_Buf   DB    30 DUP (?)         ; Buffer para el nombre capturado
Tel_Buf   DB    10 DUP (?)         ; Buffer para el tel‚fono
Nom_Desp  DB    30 DUP (?)         ; Campo de despliegue al consultar (nombre)
          DB    10 DUP (?)         ; 10 espacios entre cada campo del registro
Tel_Desp  DB    10 DUP (?)         ; Campo de despliegue al consultar (tel‚fono)
          DB    13, 10, '$'        ; Cr y Lf.

;-----------------------------------------------------------------------------
;           C O M I E N Z A      E L      C O D I G O
;-----------------------------------------------------------------------------

.CODE                              ; EMPIEZA el c¢digo
Empieza:                           ; Etiqueta de comienzo de programa
                                   ; .. MARCA EL PRINCIPIO,..

;-----------------------------------------------------------------------------
; Establece el direccionamiento de los datos (mensajes y variables) y
; despliega el mensaje de bienvenida.
;-----------------------------------------------------------------------------

        Mov     Ax,@Data           ; Obt‚n la direcci¢n del segmento de
        Mov     Ds, Ax             ; .. datos, DS = Segmento de datos
        Push    Ds                 ; .. emp£jalo a la pila y establece
        Pop     Es                 ; .. que ES = DS.
        Borra_Pantalla             ; Borra la pantalla y despliega el mensaje
        Despliega_Mens Mensaje     ; .. de bienvenida.

;-----------------------------------------------------------------------------
; Espera a que el usuario digite una tecla para poder seguir.
;-----------------------------------------------------------------------------

        Lee_Tecla Funcion, Rango1, Rango2

;-----------------------------------------------------------------------------
; Abre el archivo y empieza a procesar las opciones. Si existe alg£n
; error, el PROGRAMA TERMINA.
;-----------------------------------------------------------------------------

        Cld                        ; Direcci¢n de cadenas ADELANTE...
                                   ; .. (STRINGS FORWARD).
        Call    Abre_Arch          ; Abre el archivo
        Test    Cod_Err, 1         ; Hubo error ?
        Jz      CA08_001           ; NO, as¡ que prosigue.
        Jmp     TERMINA            ; SI, por lo tanto TERMINA.

;-----------------------------------------------------------------------------
; Selecciona opci¢n a procesar (1 = Agrega registro, 2 = Consulta y
; 3 = termina el programa). Cualquier otro valor es INVALIDO.
;-----------------------------------------------------------------------------

CA08_001:
        Borra_Pantalla             ; Borra la pantalla de nuevo y despliega
        Despliega_Mens Selec       ; .. el men£ de opciones.
        Mov  Funcion, 1            ; Obliga a validar el rango.
        Mov  Rango1, 31H           ; Establece el rango inferior y despu‚s el
        Mov  Rango2, 33H           ; .. superior (1 a 3).
        Lee_Tecla Funcion, Rango1, Rango2
        Cmp  Funcion, -1           ; Hubo error ?
        Jnz  CA08_002              ; NO, as¡ que contin£a..
        Pon_Cursor 23,1            ; De lo contrario vete a la posici¢n del
        Despliega_Mens Borra       ; .. despliegue de error, borra el conte-
        Pon_Cursor 23,1            ; .. nido anterior, reposiciona el cursor y
        Despliega_Mens No_Tecla    ; .. despliega el mensaje de error.
        Mov  Funcion, 0            ; Espera a que el usuario digite una tecla.
        Lee_Tecla Funcion, Rango1, Rango2
        Jmp  CA08_001              ; Itera de nuevo hasta tener una opci¢n
                                   ; .. v lida.

;-----------------------------------------------------------------------------
; Procesa la opci¢n seleccionada.
;-----------------------------------------------------------------------------

CA08_002:
        Cmp  Funcion, 33H          ; Terminar ?.
        Jnz  CA08_003              ; NO, defina cu l es.
        Jmp  TERMINA               ; SI, ya no hay m s que hacer.
CA08_003:
        Cmp  Funcion, 31H          ; Agregar ?.
        Jz   CA08_004              ; SI.
        Cmp  Funcion, 32H          ; Consultar ?.
        Jz   CA08_111              ; SI.
        Jmp  CA08_001              ; Selecci¢n INVALIDA, sigue iterando.
CA08_111:
        Jmp  CA08_005

;-----------------------------------------------------------------------------
; Procesa LA OPCION 1 (Agrega registros)
;-----------------------------------------------------------------------------

CA08_004:

        Borra_Pantalla             ; Borra el contenido de la pantalla.
        Pon_Cursor 1,1             ; Posiciona el cursor en 1,1 y despliega
        Despliega_Mens Mens1       ; .. lo que nos encontramos haciendo.
        Call  Captu_Nom            ; Captura nombre
        Cmp   Buf_Cta, 0           ; Terminamos ?
        Jne   CA08_011             ; NO !.
        Jmp   CA08_001             ; SI !.
CA08_011:

; *** LAS SIGUIENTES DOS LINEAS FUERON AGREGADAS

        IniCampo Nom_Buf, 30, Un_Espa   ; Inicializa el campo de captura
        IniCampo Tel_Buf, 10, Un_Espa   ; Inicializa el campo de captura
        Copia_Buffer BufferR, Nom_Buf, Cta_Act
        Call  Captu_Tel
        Copia_Buffer BufferR, Tel_Buf, Cta_Act
        Call  Escribe_Reg
        Test  Cod_Err, 1

; *** SE AGREGARON LAS SIGUIENTES DOS LINEAS EN LUGAR DE "Jz    CA08_004".
;     TAMBIEN, SE AGREGO LA ETIQUETA CA08_0020.

        Jnz   CA08_020
        Jmp   CA08_004

CA08_020:

        Mov   Funcion, 0           ; Espera a que el usuario digite una tecla.
        Lee_Tecla Funcion, Rango1, Rango2
        Jmp   TERMINA

;-----------------------------------------------------------------------------
; Procesa LA OPCION 2 (Consulta registros)
;-----------------------------------------------------------------------------

CA08_005:

        Borra_Pantalla             ; Borra el contenido de la pantalla.
        Pon_Cursor 1,1             ; Posiciona el cursor en 1,1 y despliega
        Despliega_Mens Mens2       ; .. el mensaje de operaci¢n seleccionada
        Mov  FCB_BA, 0             ; Empieza a partir del registro 0
        Mov  FCB_TR, 40            ; Tama¤o de registro es 40 bytes
        Mov  FCB_RA, 0             ; Registro actual
        Pon_Cursor 3,0
CA08_006:
        Call Lee_Reg
        Test Cod_Err, 1
        Jz   CA08_012
        Mov  Funcion, 0            ; Espera a que el usuario digite una tecla.
        Lee_Tecla Funcion, Rango1, Rango2
        Jmp  CA08_001
CA08_012:
        Copia_Buffer Nom_Buf, Nom_Desp, 30
        Copia_Buffer Tel_Buf, Tel_Desp, 10
        Despliega_mens Nom_Desp
        Jmp  CA08_006


;============================================================================
;                 R U T I N A S     D E    S O P O R T E
;============================================================================

;-----------------------------------------------------------------------------
; Abre el archivo FCB
;-----------------------------------------------------------------------------

Abre_Arch       PROC

        Push   Ax                  ; Guarda registros
        Push   Dx                  ; .. IDEM.
        Lea    Dx, FCB_Drive       ; Abre el archivo en la unidad
        Mov    Ah, 0FH             ; .. especificada por FCB_Drive.
        INT    21H

; *** SE CORRIGIO LA SIGUIENTE INSTRUCCION (EN LUGAR DE SER OR AL,AL DEBE
;     DE SER OR AL,0).

        Or     Al, 0               ; Si AL = 0 entonces el archivo fue
        Jz     Abre_arch_02        ; .. encontrado. De lo contrario hay que
        Lea    Dx, FCB_Drive       ; .. crearlo.
        Mov    Ah, 16H             ; Funcion para crear archivo
        INT    21H

; *** LA MISMA CORRECCION ANTERIOR SE HIZO EN LA SIGUIENTE LINEA.

        Or     Al, 0               ; Si AX = 0 todo esta bien
        Jz     Abre_arch_01
        Despliega_Mens No_Esp      ; Hubo error. Despliega el mensaje y
        Mov     Cod_Err, 1         ; .. prende bandera de error.
        Jmp     Abre_Arch_02

Abre_Arch_01:

        Mov     FCB_RA, 0          ; Registro actual

Abre_Arch_02:

        Mov     FCB_TR, 40         ; Tama¤o de registro
        Pop     Dx                 ; Restaura registros
        Pop     Ax
        Ret

Abre_Arch       ENDP

;-----------------------------------------------------------------------------
; Cierra el archivo FCB
;-----------------------------------------------------------------------------

Cierra_Arch     PROC

        Push    Ax                 ; Guarda registros
        Push    Dx
        Lea     Dx, FCB_Drive      ; Drive usado
        Mov     Ah, 10h            ; Funci¢n para cerrar archivo
        INT     21H                ; Invoca a MS-DOS
        Or      Al, 0              ; Hubo error ?
        Jz      Cierra_Arch_01     ; Todo Bien.
        Despliega_Mens No_Cerr     ; Despliega error y prende la bandera
        Mov     Cod_Err, 1         ; .. de errores.

Cierra_Arch_01:

        Pop     Dx                 ; Restaura registros
        Pop     Ax
        Ret

Cierra_Arch     ENDP

;-----------------------------------------------------------------------------
; Captura el nombre
;-----------------------------------------------------------------------------

Captu_Nom       PROC

        Push    Bx                     ; Guarda registro
        Pon_Cursor 10,1                ; Posiciona el cursor en 10, 1

; *** EN LA SIGUIENTE LINEA SE CAMBIO ' ' POR LA VARIABLE "Un_Espa".

        IniCampo BufferR, 31, Un_Espa  ; Inicializa el campo de captura
        Despliega_Mens Nombre          ; Despliega el campo de captura
        Pon_Cursor 10, 12              ; Reposiciona el cursor
        Obten_Info BufferT, 30         ; Obtiene la informacion del campo
        Mov     Bl, Buf_Cta            ; Caracteres leidos. BL = cuenta de
        Mov     Bh, 0                  ; .. cars. leidos y BH = 0.
        Mov     Cta_Act, Bx            ; Gu rdalos
        Pop     Bx                     ; Restaura registro
        Ret

Captu_Nom        ENDP

;-----------------------------------------------------------------------------
; Captura el Telefono
;-----------------------------------------------------------------------------

Captu_Tel       PROC

        Push    Bx                 ; Guarda registros
        Pon_Cursor 11,1            ; Posiciona cursor
        IniCampo BufferR, 31, Un_Espa  ; Inicializa campo del telefono
        Despliega_Mens Telef       ; Despliega campo de captura
        Pon_Cursor 11, 12          ; Reposiciona el cursor
        Obten_Info BufferT,10      ; Lee el campo
        Mov     Bl, Buf_Cta        ; Bytes le¡dos
        Mov     Bh, 0
        Mov     Cta_Act, Bx        ; Gu rdalos
        Pop     Bx                 ; Restaura registros
        Ret

Captu_Tel        ENDP

;-----------------------------------------------------------------------------
; Escribe el registro
;-----------------------------------------------------------------------------

Escribe_Reg     PROC

        Push    Ax                 ; Guarda registros
        Push    Dx
        Mov     Cod_err, 0         ; Inicializa c¢digo de error.
        Lea     Dx, Nom_Buf        ; Buffer para el DTA
        Mov     Ah, 1AH            ; Establece DTA a trav‚s de MS-DOS
        INT     21H                ; Invoca a MS-DOS
        Lea     Dx, FCB_Drive      ; Establece drive de operaciones
        Mov     Ah, 15H            ; Escribe registro
        INT     21H

; *** LA SIGUIENTE LINEA FUE CORREGIDA. EN LUGAR DE DECIR OR AL, AL DEBE
;     DECIR OR AL, 0.

        Or      Al, 0              ; Si AL = 0 todo est  bien
        Jz      Escribe_Reg_01
        Despliega_Mens No_Esc      ; Mensaje de error de escritura
        Mov     Cod_Err, 1

Escribe_reg_01:

        Pop     Dx                 ; Restaura registros
        Pop     Ax
        Ret

Escribe_Reg     ENDP

;-----------------------------------------------------------------------------
; Lee registro del archivo
;-----------------------------------------------------------------------------

Lee_Reg    PROC
        Push  Ax
        Push  Dx                   ; Guarda registros
        Mov   Cod_err, 0
        Lea   Dx, Nom_Buf          ; Buffer del DTA
        Mov   Ah, 1AH              ; D¡le a MS-DOS cu l es nuestro DTA
        INT   21H
        Lea   Dx, FCB_Drive        ; Establece el drive de operaciones
        Mov   Ah, 14H              ; Lectura secuencial FCB
        INT   21H
        Cmp   Al, 0                ; Todo Bien ?
        Jz    Lee_Reg_02           ; SI.
        Cmp   Al, 1                ; Fin de archivo ?
        Jz    Lee_Reg_01           ; SI.
        Despliega_Mens No_Lee      ; Despliega cualquier otro error.
        Mov   Cod_Err, 1
        Jmp   Lee_Reg_02
Lee_Reg_01:
        Despliega_Mens Fin_Arc
        Mov   Cod_Err, 1

Lee_Reg_02:
        Pop   Dx
        Pop   Ax
        Ret
Lee_Reg    ENDP

TERMINA:

        Borra_Pantalla
        Call    Cierra_Arch
        Test    Cod_Err, 1
        Jnz     TERMINA_01
        Mov     Ax, 4C00H
        Jmp     TERMINA_02

TERMINA_01:

        Mov     Ax, 4C01H

TERMINA_02:

        INT     21H

.STACK
    End  Empieza