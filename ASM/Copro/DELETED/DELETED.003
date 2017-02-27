;*****************************************************************************
; Nombre del programa:   EJER10.ASM
; Objetivo           :   Convierte una cadena de caracteres en min£sculas
;                        a una cadena de caracteres en may£sculas.
;*****************************************************************************
; COMANDO DE ENSAMBLE    : Masm EJER10;
; COMANDO DE ENLACE      : Link EJER10;
; COMANDO DE EJECUCION   : EJER10 [Enter]
;*****************************************************************************
; NOTA : En el c¢digo anterior se ha procurado usar SOLO las instrucciones
;        ya explicadas. El objetivo es educativo y NO de optimizaci¢n o
;        eficiencia. Por favor, NO SE DESESPERE y est£dielo.
;*****************************************************************************

; Define el modelo de memoria

.MODEL SMALL

.Data
  Cadena   DB  15,0,15 DUP(?)  ; Variable que almacena la cadena
  Cadena1  DB  80 DUP(?)       ; cadena convertida a may£sculas
  Mensaje  DB  'Bienvenidos a EJ01CA06. Programa ejemplo que'
           DB  'convierte una cadena de caracteres en min£sculas a una'
           DB  'cadena de caracteres en may£sculas.',13,10
           DB  13,10,'$'
  Error    DB  7,7,7,13,10,'ERROR: cadena no puede ser NULA.'
           DB  13,10,13,10,'$'
  Final    DB  'FIN'
  CadUnoM  DB  13,10,13,10,'Digite CADENA por CONVERTIR: $'

.CODE                    ; Area de c¢digo

Empieza:                 ; Etiqueta de comienzo de programa

;-----------------------------------------------------------------------------
; BORRA LA PANTALLA CAMBIANDO LA MODALIDAD DE VIDEO. ESTA FORMA DE BORRAR
; LA PANTALLA ES MUY PECULIAR Y SE CONSIDERA UN "TRUCO". SE BASA EN EL
; HECHO DE QUE AL CAMBIAR LA MODALIDAD DE VIDEO, EL PROPIO BIOS (HARDWARE) 
; BORRA LA PANTALLA AUTOMATICAMENTE. ES UN METODO BURDO PERO MUY EFICIENTE.
;-----------------------------------------------------------------------------

  Mov  Ah, 0Fh             ; Obtiene modalidad de video actual
  Int  10h
  Mov  Ah, 0               ; Cambia a la modalidad de video obtenida
  Int  10h
  mov  Ax,@Data            ; Inicializa DS con la direcci¢n de @Data
  mov  Ds, Ax
  mov  Dx, Offset Mensaje  ; Despliega el mensaje de bienvenida
  Mov  Ah, 9
  Int  21h
  Push Ds
  Pop  Es                  ; ES = DS

;-----------------------------------------------------------------------------
; SE CAPTURA LA CADENA Y SE GUARDA EN LA VARIABLE CORRESPONDIENTE. LA
; CAPTURA SE BASA EN LA FUNCION 0AH DE LA INT 21H. DICHA FUNCION
; ESTABLECE QUE EL REGISTRO AH CONTENGA 0AH Y EL REGISTRO PAR DS:DX
; APUNTE A LA DIRECCION DE LA VARIABLE QUE ALMACENARA LA ESTRUCTURA DEL
; BUFFER (MEMORIA INTERMEDIA), LA CUAL DEBE ESTAR CONSTRUIDA DE LA
; SIGUIENTE MANERA:
;  BYTE 1  = CANTIDAD DE BYTES POR LEER
;  BYTE 2  = (LLENADO POR MS-DOS) ES LA CANTIDAD DE BYTES REALMENTE LEIDOS.
;  BYTE 3  = BUFFER DONDE SE ALMACENA EL RESULTADO Y DEBE
;            ENCOTRARSE INICIALIZADO A LA MISMA CANTIDAD DE BYTES
;            ESPECIFICADOS POR EL BYTE 1.
;-----------------------------------------------------------------------------

; Captura la cadena a ser convertida.

CAPCAD01:
  Mov  Dx, Offset CadUnoM  ; Mensaje de captura de cadena
  Mov  Ah, 9
  Int  21h
  Mov  Ah, 0Ah             ; Captura la cadena (hasta 15 bytes)
  Mov  Dx, Offset Cadena
  Push Dx                  ; Guarda la direcci¢n de la variable
  Int  21h
  Pop  Dx
  Inc  Dx                  ; Obtiene la cantidad de bytes realmente
                           ; le¡dos que se encuentra en el byte 1 de 
                           ; la memoria intermedia
  Mov  Si, Dx
  Cmp  Byte ptr [Si], 0    ; ¨Es 0?
  Jnz  CAPCAD02            ; No, as¡ que prosigue
  Mov  Dx, Offset Error    ; Despliega mensaje de error y captura la
  Mov  Ah, 9               ; cadena de nuevo (cadena fue nula)
  Int  21h
  Jmp  SHORT CAPCAD01

;-----------------------------------------------------------------------------
; PRIMERO REVISA SI LA CADENA TIENE LA ETIQUETA "FIN" QUE ESPECIFICA EL
; DESEO DEL USUARIO DE TERMINAR ESTE PROGRAMA. SI LO ANTERIOR ES CIERTO EL
; PROGRAMA TERMINA, DE LO CONTRARIO CAPTURA EL CARACTER QUE SERA BUSCADO EN 
; LA CADENA Y PROSIGUE. "FIN" DEBE DE ESTAR EN MAYUSCULAS.
;-----------------------------------------------------------------------------

CAPCAD02:
  Inc  Dx                  ; Primer byte del buffer (memoria intermedia)
 			   ; de CADENA 1 			
  Mov  Cx, 3               ; Vamos a revisar 3 bytes.
  Mov  Si, Dx              ; Cadena capturada
  Mov  Di, Offset Final    ; Mensaje de final
  Repe Cmpsb               ; ¨Se digit¢ "FIN"?
  Jcxz TERMINA             ; S¡, as¡ que termina este programa.

CAPCAD03:
  Xor  Ch, Ch                   ; CH = 0, por si acaso.
  Mov  Si, Offset Cadena + 1    ; Bytes realmente le¡dos
  Mov  Cl, byte ptr [Si]        ; Cx tiene bytes le¡dos 
  Inc  Cl                       ; Ajusta CL debido a la naturaleza de
                                ; la instrucci¢n de comparaci¢n y a la
                                ; manera en que se comporta la funci¢n                            
                                ; 9 de la INT 21H.
  Inc  Si                       ; Regresa a direcci¢n de cadena
  Cld                           ; Direcci¢n hacia adelante
  Lea  Di, Cadena1

CONVIERTE:
  Lodsb                         ; Obtiene un byte de cadena
  Cmp  AL,"a"                   ; ¨es "a"?
  Jb   SALTA                    ; S¡, as¡ que prosigue.
  Cmp  AL,"z"                   ; ¨es "z"?
  Ja   SALTA                    ; S¡, as¡ que prosigue.
  And  AL,0DFH                  ; Convierte a may£sculas.

SALTA:
  Stosb                         ; Almacena car cter de vuelta
  Loop CONVIERTE                ; Itera hasta que CX = 0
  Mov  Al, '$'                  ; Convierte cadena1 en cadena
  Stosb                         ; reconocible por MS-DOS.
  Call Linea                    ; Despliega un CR y LF
  Call Linea                    ; Despliega otro CR y LF
  Mov  Dx, Offset Cadena1       ; Despliega cadena en may£sculas
  Mov  Ah, 9                    ; As¡ que despliega mensaje de error
  Int  21h
  Jmp  SHORT CAPCAD01

;-----------------------------------------------------------------------------
; TERMINA EL PROGRAMA
;-----------------------------------------------------------------------------

TERMINA:
  Mov  Ax, 4C00h          ; Termina el programa sin errores.
  Int  21h

;-----------------------------------------------------------------------------
; RUTINA     : Linea
; PROPOSITO  : Desplegar un CR y un LF
; PARAMETROS : Ninguno
; REGRESA    : Nada
;-----------------------------------------------------------------------------

Linea  PROC  Near
  Push  Ax            ; Guarda en la pila los registros que ser n
  Push  Dx            ; alterados.
  Mov   Dl, 0Dh       ; C¢digo de un CR
  Mov   Ah, 2
  Int   21h
  Mov   Dl, 0Ah       ; C¢digo de un LF
  Mov   Ah, 2
  Int   21h
  Pop   Dx            ; Restaura registros empujados a la pila
  Pop   AX
  Ret
Linea  ENDP

  .STACK
  End  Empieza