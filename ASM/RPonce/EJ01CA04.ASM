;**************************************************************************
; Nombre del programa: EJ01CA04.ASM
; Fecha de creaci¢n  : Abril 26 de 1993
; Autor              : J.A. Rojas Ponce
; Objetivo           : Demostrar como se usan las instrucciones para
;                      movimiento de datos, c¢mo se usa la pila y c¢mo se
;		       mueven e inicializan bloques de memoria. El programa
;		       crea una tabla de 26 bytes que se inicializa con una
;		       serie de X. Despu‚s llena la tabla con las letras
;		       A a Z en min£sculas. Lee de nuevo la tabla
;		       convirtiendo las letras a may£sculas y finalmente
;		       la despliega.
;
;**************************************************************************
;
; Se necesita el MASM Versi¢n 5.x o mayor.
;
; COMANDO DE ENSAMBLE    : Masm EJ01CA04;
; COMANDO DE ENLACE      : Link EJ01CA04;
; COMANDO DE EJECUCION   : EJ01CA04 [Enter]
;**************************************************************************

; -------------------------------------------------------------------------
; INICIA EL PROGRAMA. SE DEFINE EL MODELO DE MEMORIA Y SE INICIALIZA
; EL SEGMENTO DE DATOS QUE PERMITIRA EL ACCESO A LOS DATOS. USANDO
; LAS INSTRUCCIONES DE 'PUSH' Y 'POP' SE INICIALIZA EL REGISTRO 'ES'.
; LA INSTRUCCION MOV AH, 0 Y LA INT 16H LE INDICAN AL PROGRAMA QUE DEBE
; ESPERAR HASTA QUE EL USUARIO DIGITE UNA TECLA. LAS INSTRUCCIONES
; ANTERIORES FORMAN PARTE DE LAS INTERRUPCIONES DEL BIOS.
; -------------------------------------------------------------------------

     .MODEL    SMALL          ; Modelo de memoria
     .CODE                    ; Area de c¢digo

Empieza:                      ; Etiqueta de comienzo de programa

     Mov  Ax, @Data           ; Permite el acceso a los datos inicializando
     Mov  Ds, Ax              ; el registro DS con la direcci¢n adecuada
                              ; del segmento de datos (@Data).
     Push Ds                  ; ES=DS, se inicializa empujando el valor
     Pop  Es                  ; de DS a la pila y extray‚ndolo en ES.
     Mov  Dx, Offset Mensaje  ; Despliega el mensaje de bienvenida usando
     Mov  Ah, 9               ; la funci¢n 9 de la Int 21.
     Int  21h
     Mov  Ah, 0               ; Espera a que el usuario digite cualquier
     Int  16h                 ; tecla usando la Int 16h del BIOS.
     Lea  Dx, Mensaje1        ; Despliega el mensaje de 'Desplegando tabla
     Mov  Ah, 9               ; original...' usando la instrucci¢n LEA
     Int  21h                 ; en lugar de OFFSET.

; -------------------------------------------------------------------------
; EL SIGUIENTE CODIGO AGREGA EL SIMBOLO '$' AL FINAL DE LA ESTRUCTURA
; 'TABLA' PARA QUE MS-DOS PUEDA DESPLEGAR LA TABLA USANDO LA FUNCION
; 9 DE LA INT 21H. USA LA INSTRUCCION 'STOSB' PARA LOGRARLO. ESTA
; INSTRUCCION ALMACENA EL CONTENIDO DEL REGISTRO 'AL' EN LA DIRECCION
; APUNTADA POR EL REGISTRO DI. EL PRIMER PASO ES MOVER AL REGISTRO 'AL'
; EL SIMBOLO '$' Y CALCULAR LA DIRECCION DE 'TABLA'. UNA VEZ
; OBTENIDA LA DIRECCION, SE LE SUMA LA CANTIDAD DE 25 PARA LLEGAR
; AL FINAL DE LA TABLA (DE 0 A 25 SON 26). ES AQUI DONDE SE
; ALMACENA EL SIMBOLO '$'.
; -------------------------------------------------------------------------

     Mov  Al, '$'                 ;  Agrega a Tabla el s¡mbolo '$'
     Mov  Di, Offset Tabla + 26   ;  para que MS-DOS pueda ejecutar la
     Stosb                        ;  funci¢n 9 de la Int 21h. Dicho
     Mov  Di, Offset Tabla_1 + 26 ;  s¡mbolo es generado tambi‚n para
     Stosb                        ;  Tabla_1.

; -------------------------------------------------------------------------
; DESPLIEGA LA TABLA ORIGINAL INICIALIZADA CON UNA SERIE DE X.
; -------------------------------------------------------------------------

     Mov  Ah,9
     Mov  Dx, Offset Tabla    ; Usa el comando Offset para desplegar la
     Int  21h                 ; tabla original inicializada con una 
     			      ; serie de 'X'.

; -------------------------------------------------------------------------
; DESPLIEGA EL MENSAJE 'INICIALIZANDO TABLA....' Y ESPERA A QUE EL
; USUARIO OPRIMA CUALQUIER TECLA.
; -------------------------------------------------------------------------

     Mov  Ah, 9
     Mov  Dx, Offset Mensaje2 ; Usa el comando Offset para desplegar el
     Int  21h                 ; mensaje sobre inicializaci¢n de la tabla.
     Mov  Ah,0
     Int  16h

; -------------------------------------------------------------------------
; INICIALIZA LA TABLA CON EL ALFABETO. CARGA EN EL REGISTRO "AL" LA
; PRIMER LETRA QUE ES "a". EL REGISTRO CX TIENE LA LONGITUD DE LA
; TABLA. SE ITERA HASTA LLENAR LA TABLA CON EL ALFABETO EN MINUSCULAS.
; -------------------------------------------------------------------------

     Mov  Cx, 26               ; Longitud de la tabla.
     Mov  Al, 'a'              ; La letra 'a' (41H en ASCII)
     Lea  Di,Tabla             ; Direcci¢n de la tabla. Puesto que
     Cld                       ; la operaci¢n es destino se usa DI.
     
InicializaTabla:

     Stosb                     ; Almacena el contenido de Al a la
     Inc  Al                   ; direcci¢n apuntada por DI.
     Loop InicializaTabla      ; Repite hasta que Cx sea 0.
     Lea  Dx, Mensaje3         ; Despliega mensaje3 usando la instrucci¢n
     Mov  Ah,9                 ; LEA en lugar de OFFSET, usando la misma
     Int  21h                  ; funci¢n 9 de la Int 21h.
     Mov  Ah, 0                ; Espera a que el usuario digite cualquier
     Int  16h                  ; tecla usando la Int 16h del BIOS.
     Mov  Ah,9
     Mov  Dx, Offset Tabla    ; Usa el comando Offset para desplegar la
     Int  21h                 ; tabla inicializada con min£sculas.

; -------------------------------------------------------------------------
; LEE LA TABLA DE NUEVO, CONVIERTE MINUSCULAS A MAYUSCULAS, ALMACENA
; EL RESULTADO EN TABLA_1 Y DESPLIEGA.
; -------------------------------------------------------------------------

     Mov  Si, Offset Tabla    ; Direcci¢n de la tabla original (fuente).
     Mov  Di, Offset Tabla_1  ; Direcci¢n de la tabla (destino).
     Mov  Cx, 26              ; Longitud de la tabla.
     Cld                      ; Lee hacia adelante

LeeTabla:

     Lodsb                    ; Carga a Al el contenido de DS:SI.
     And  Al, 5fh             ; Convierte a may£sculas.
     Stosb                    ; Guarda de nuevo en ES:DI.
     Loop LeeTabla            ; Itera hasta que Cx sea 0.
     Lea  Si, Tabla           ; Direcci¢n de Tabla (fuente).
     Lea  Di, Tabla_1         ; Direcci¢n de Tabla_1 (destino).
     Mov  Cx, 26              ; Longitud de la(s) Tabla(s).
     Cld
     REP  Movsb               ; Mueve el bloque de DS:SI a ES:DI.

     Mov  Dx, Offset Mensaje4 ; Despliega mensaje4 usando la funci¢n
     Int  21h                 ; 9 de la interrupci¢n 21h.
     Mov  Ah,9
     Lea  Dx, Tabla_1         ; Despliega la tabla traducida a
     Int  21h                 ; may£sculas.

; -------------------------------------------------------------------------
; EL PROGRAMA TERMINA USANDO LA FUNCION 4C DE LA INT 21H. NO HAY ERROR
; ASI QUE EL CODIGO DE RETORNO ES 00.
; -------------------------------------------------------------------------

     Mov  Ax,4c00h            ; Regresa a MS-DOS por medio de la funci¢n 4c.
     Int  21h                 ; El c¢digo de regreso es 0 porque no hubo
                              ; error. En caso de existir alguno se podr¡a 
                              ; pasar un c¢digo diferente a 0 (ej. 4c01h).

; -------------------------------------------------------------------------
; INICIA SEGMENTO DE DATOS
; -------------------------------------------------------------------------

    .DATA                     ; Segmento de datos

              Mensaje  DB  13,10
              DB  'Bienvenidos al programa EJ01CA04!. En ‚ste '
              DB  'programa se demostrar  el uso del',13,10
              DB  'movimiento de BLOQUES de memoria, as¡ como '
              DB  'otro tipo de instrucciones contenidas en '
              DB  '‚ste cap¡tulo. Favor de OPRIMIR cualquier '
              DB  'TECLA cuando se encuentre listo.$'
	      Mensaje1 DB  13,10,13,10
              DB  'Desplegando Tabla ORIGINAL inicializada con XXXX...'
              DB  13,10,13,10,'$'
	      Mensaje2 DB  13,10,13,10
              DB  'Inicializando la Tabla ORIGINAL con el ALFABETO '
              DB  'completo en MINUSCULAS.',13,10
              DB  'Favor de OPRIMIR cualquier TECLA para continuar !!!$'
	      Mensaje3 DB  13,10,13,10
              DB  'TABLA INICIALIZADA. Favor de OPRIMIR'
              DB  'Cualquier tecla',13,10,'para DESPLEGARLA...',13,10
              DB  13,10,'$'
	      Mensaje4 DB  13,10,13,10
              DB  'Desplegando la TABLA DEL ALFABETO en MAYUSCULAS'
              DB  13,10,13,10,'$'
              Tabla    DB  26 DUP ('X')
              Tabla_1  DB  26 DUP (?)

; -------------------------------------------------------------------------
; INICIA SEGMENTO DE PILA
; -------------------------------------------------------------------------

     .STACK                   ; Se necesita una PILA.
     END  Empieza             ; Fin del programa
