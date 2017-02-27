;*****************************************************************************
; Nombre del programa:   EJ00CA06.ASM
; Fecha de creaci¢n  :   Junio 5 de 1993
; Autor              :   J.A. Rojas Ponce
; Objetivo           :   Encuentra la primera ocurrencia de un
;                        car cter dentro de una cadena de caracteres.

;*****************************************************************************
; COMANDO DE ENSAMBLE    : Masm EJ00CA06;
; COMANDO DE ENLACE      : Link EJ00CA06;
; COMANDO DE EJECUCION   : EJ00CA06 [Enter]
;*****************************************************************************

; NOTA : En el c¢digo anterior se procura usar SOLO las instrucciones
; ya explicadas. El objetivo es educativo y NO de optimizaci¢n o
; eficiencia. Por favor, NO SE DESESPERE y est£dielo.
;*****************************************************************************

; Define el modelo de memoria

.MODEL SMALL

.Data

  Cadena   DB  15,0,15 DUP(?)  ; Variable que almacena la cadena
  Car cter DB  0
  Mensaje  DB  'Bienvenidos a EJ00CA06. Programa ejemplo que'
           DB  'encuentra la primera ocurrencia de un caracter en una'
           DB  'cadena. Digite FIN para terminar el programa.',13,10
           DB  13,10,'$'
  Error    DB  7,7,7,13,10,'ERROR: cadena/car cter no puede ser NULA/NULO.'
           DB  13,10,13,10,'$'
  Final    DB  'FIN'
  TodoBIEN DB  7,7,7,13,10,'Car cter ENCONTRADO EN CADENA.'
           DB  13,10,13,10,'$'
  TodoMAL  DB  7,7,7,13,10,'Car cter NO ENCONTRADO EN CADENA.'
           DB  13,10,13,10,'$'
  CadUnoM  DB  13,10,13,10,'Digite CADENA por BUSCAR: $'
  CadDosM  DB  13,10,13,10,'Digite car cter por buscar en CADENA: $'

.CODE                      ; Area de c¢digo

Empieza:                   ; Etiqueta de comienzo de programa

;-----------------------------------------------------------------------------
; BORRA LA PANTALLA CAMBIANDO LA MODALIDAD DE VIDEO. ESTA MANERA DE BORRAR
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
; BUFFER (MEMORIA INTERMEDIA), LA CUAL DEBE DE ESTAR CONSTRUIDO DE LA
; SIGUIENTE MANERA:
;  BYTE 1  = CANTIDAD DE BYTES A LEER
;  BYTE 2  = (LLENADO POR MS-DOS) ES LA CANTIDAD DE BYTES REALMENTE
;  LEIDOS.
;  BYTE 3  = BUFFER DONDE SE ALMACENA EL RESULTADO; DEBE ENCONTRARSE
;  INICIALIZADO A LA MISMA CANTIDAD DE BYTES ESPECIFICADOS POR EL BYTE 1.
;-----------------------------------------------------------------------------

; Captura la cadena

CAPCAD01:
  Mov  Dx, Offset CadUnoM  ; Mensaje de captura de cadena
  Mov  Ah, 9
  Int  21h
  Mov  Ah, 0Ah             ; Captura la cadena (hasta 15 bytes)
  Mov  Dx, Offset Cadena
  Push Dx                  ; Guarda la direcci¢n de la variable
  Int  21h
  Pop  Dx
  Inc  Dx                  ; Obtiene la cantidad de bytes realmente le¡dos
                           ; que se encuentra en el byte 1 del buffer
  Mov  Si, Dx
  Cmp  Byte ptr [Si], 0    ; ¨Es 0?
  Jnz  CAPCAD02            ; No, as¡ que prosigue
  Mov  Dx, Offset Error    ; Despliega mensaje de error y captura la
  Mov  Ah, 9               ; cadena de nuevo (la cadena fue nula)
  Int  21h
  Jmp  SHORT CAPCAD01

;-----------------------------------------------------------------------------
; PRIMERO REVISA SI LA CADENA TIENE LA ETIQUETA "FIN" QUE ESPECIFICA EL
; DESEO DEL USUARIO DE TERMINAR ESTE PROGRAMA. SI LO ANTERIOR ES CIERTO EL
; PROGRAMA TERMINA, DE LO CONTRARIO CAPTURA EL CARACTER QUE SERA BUSCADO EN
; LA CADENA Y PROSIGUE. "FIN" DEBE ESTAR EN MAYUSCULAS.
;-----------------------------------------------------------------------------

CAPCAD02:
  Inc  Dx                  ; Primer byte del buffer (memoria intermedia) de CADENA 1
  Mov  Cx, 3               ; Vamos a revisar 3 bytes.
  Mov  Si, Dx              ; Cadena capturada
  Mov  Di, Offset Final    ; Mensaje de final
  Repe Cmpsb               ; ¨Se digit¢ "FIN"?
  Jcxz TERMINA             ; S¡, as¡ que termina este programa.

CAPCAD03:
  Mov  Dx, Offset CadDosM  ; Mensaje de captura de car cter
  Mov  Ah, 9
  Int  21h
  Mov  Ah, 01
  Int  21h
  Mov  Car cter, AL        ; Guarda car cter
  Cmp  AL, 0
  Jnz  CAPCAD04            ; No, as¡ que prosigue
  Mov  Dx, Offset Error    ; Despliega mensaje de error y captura la
  Mov  Ah, 9               ; cadena de nuevo
  Int  21h
  Jmp  SHORT CAPCAD03

;-----------------------------------------------------------------------------
; BUSCA CARACTER EN CADENA.
;-----------------------------------------------------------------------------

CAPCAD04:
  Xor  Ch, Ch                   ; CH = 0 por si acaso.
  Mov  Si, Offset Cadena + 1    ; Bytes realmente le¡dos
  Mov  Cl, byte ptr [Si]        ; Cx tiene bytes le¡dos 
  Inc  Cl                       ; Ajusta CL debido a la naturaleza de
                                ; la instrucci¢n de comparaci¢n y a la
                                ; manera en que se comporta la funci¢n
                                ; 9 de la INT 21H.
  Inc  Si                       ; Regresa a direcci¢n de cadena
  Cld                           ; Direcci¢n hacia adelante
  Mov  Al, Caracter             ; Al = car cter que se buscar  en la cadena

BUSCA:
  Cmp  Cl, 0                    ; ¨Llegamos a fin de cadena?
  Jz   CAPCAD05                 ; Parece que s¡.
  Cmp  Al, Byte Ptr [Si]        ; ¨Al es = byte actual de cadena?
  Jz   CAPCAD06                 ; Si, as¡ que car cter fue encontrado.
  Inc  Si                       ; Vete al siguiente car cter de cadena
  Dec  Cl                       ; Decrementa cuenta de caracteres buscados
  Jmp  SHORT BUSCA              ; Regresa a revisar el siguiente

CAPCAD05:
  Mov  Dx, Offset TodoMAL       ; No encontramos caracter dentro de la
  Mov  Ah, 9                    ; cadena, as¡ que despliega mensaje de error.
  Int  21h
  Jmp  SHORT CAPCAD01          

CAPCAD06:
  Mov  Dx, Offset TodoBIEN      ; Car cter fue encontrado dentro de cadena.
  Mov  Ah, 9
  Int  21h
  Jmp  SHORT CAPCAD01

;-----------------------------------------------------------------------------
; TERMINA EL PROGRAMA
;-----------------------------------------------------------------------------

TERMINA:
  Mov  Ax, 4C00h                ; Termina el programa sin errores.
  Int  21h

  .STACK
  End  Empieza
