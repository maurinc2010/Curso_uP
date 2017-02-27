;************************************************************************
; Nombre del programa:   EJ01CA07.ASM
; Fecha de creaci¢n  :   Junio 28 de 1993
; Autor              :   J.A. Rojas Ponce
; Objetivo           :   Permite capturar una cadena (el nombre de usted) y
;                    :   desplegarla utilizando una biblioteca de macros
;*************************************************************************
; COMANDO DE ENSAMBLE    : Masm EJ01CA07;
; COMANDO DE LINKEAR     : Link EJ01CA07;
; COMANDO DE EJECUCION   : EJ01CA07 [Enter]
;*************************************************************************
;
; NOTA : se ha procurado usar SOLO las instrucciones ya vistas explicadas.
;        El objetivo es educativo y NO de optimizaci¢n o eficiencia.
;        Por favor, NO SE DESEPERE y est£dielo.
;**************************************************************************



INCLUDE MACROBIB.BIB       ; biblioteca de macros

; Define el modelo de memoria

.MODEL SMALL

.Data

Nombre   DB  40,0,40 DUP(?)  ; Variable que almacena la cadena
Buffer   DB  40 DUP(?)
Mensaje  DB  'Bienvenidos a EJ01CA07. Programa que le permite capturar'
         DB  ' una cadena de caracteres (su nombre) y desplegarla. El'
         DB  ' prop¢sito es demostrar el uso de MACROS !.',13,10
         DB  'Para FINALIZAR EL PROGRAMA DIGITE FIN en may£sculas.',13,10
         DB  13,10,'$'
Error    DB  7,7,7,'ERROR : cadena no puede ser NULA. Oprima CUALQUIER'
         DB ' TECLA !$'
BorraL   DB  '                                                          $'
Final    DB  'FIN'
CadUnoM  DB  'Digite su NOMBRE : $'
CadUnoD  DB  'Nombre capturado : $'

.CODE                    ; Area de c¢digo


Empieza:                 ; Etiqueta de comienzo de programa

;--------------------------------------------------------------------
; BORRA LA PANTALLA CAMBIANDO LA MODALIDAD DE VIDEO. ESTA FORMA DE BORRAR
; LA PANTALLA ES MUY PECULIAR Y SE CONSIDERA UN "TRUCO". SE BASA
; EN EL HECHO DE QUE AL CAMBIAR LA MODALIDAD DE VIDEO EL PROPIO BIOS
; (HARDWARE) BORRA LA PANTALLA POR NOSOTROS. ES UN METODO BURDO PERO
; MUY EFICIENTE.
;---------------------------------------------------------------------

     mov  Ax,@Data            ; Inicializa DS con la direcci¢n de @Data
     mov  Ds, Ax
     Push Ds
     Pop  Es
     Borra_Pantalla
     Pon_Cursor 1,1
     Despliega_Mens Mensaje

;-------------------------------------------------------------------------
; SE CAPTURA LA CADENA QUE SERA EXAMINADA Y SE GUARDA EN LA VARIABLE
; CORRESPONDIENTE. LA CAPTURA SE BASA EN LA FUNCION 0AH DE LA INT 21H.
; DICHA FUNCION ESTABLECE QUE EL REGISTRO AH CONTENGA 0AH Y EL REGISTRO
; PAR DS:DX APUNTE A LA DIRECCION DE LA VARIABLE QUE ALMACENARA LA
; ESTRUCTURA DEL BUFFER, EL CUAL DEBE ESTAR CONSTRUIDO DE LA SIGUIENTE
; FORMA:
;       BYTE 1  = CANTIDAD DE BYTES A LEER
;       BYTE 2  = (LLENADO POR MS-DOS) ES LA CANTIDAD DE BYTES REALMENTE
;                 LEIDOS.
;       BYTE 3  = BUFFER DONDE SE ALMACENA EL RESULTADO. DEBE ENCONTRARSE
;                 INICIALIZADO CON LA MISMA CANTIDAD DE BYTES
;                 ESPECIFICADOS POR EL BYTE 1.
;--------------------------------------------------------------------------

; Captura nombre

CAPNOM01:
     Pon_cursor 10,1
     Despliega_Mens CadUnoM
     Pon_Cursor 10,19
     Despliega_Mens BorraL
     Pon_Cursor 10,19
     Mov  Dx, OFFSET Nombre
     Mov  Ah, 0Ah             ; Captura la cadena (hasta 15 bytes)
     Int  21h
     Inc  Dx                  ; Obtiene la cantidad de bytes realmente le¡dos
                              ; que se encuentra en el byte 1 del buffer
     Mov  Si, Dx
     Xor  Bh, Bh
     Mov  Bl, Byte Ptr [Si]   ; guarda bytes
     Cmp  Bl , 0              ; Es 0 ?
     Push Bx
     Jnz  CAPNOM02            ; No, as¡ que prosigue
     Pon_Cursor 20,1
     Despliega_Mens Error
     Mov  Ah, 0
     Int  16h
     Pop  Bx
     Pon_Cursor 20,1
     Despliega_Mens BorraL
     Jmp  CAPNOM01

;-----------------------------------------------------------------
; PRIMERO REVISA SI LA CADENA TIENE LA PALABRA "FIN" CON LA CUAL EL
; USUARIO ESPECIFICA QUE DESEA TERMINAR EL PROGRAMA. SI LO ANTERIOR ES
; CIERTO EL PROGRAMA TERMINA; DE LO CONTRARIO DESPLIEGA EL NOMBRE
; CAPTURADO.
;------------------------------------------------------------------

CAPNOM02:
     Pop  Bx
     Inc  Dx                  ; Primer byte del nombre
     Mov  Cx, 3               ; Vamos a revisar 3 bytes.
     Mov  Si, Dx              ; Cadena capturada
     Mov  Di, Offset Final    ; Mensaje de final
     Repe Cmpsb               ; Se digit¢ "FIN" ?
     Jcxz TERMINA             ; S¡, as¡ que termina el programa
     Copia_Buffer Nombre, Buffer, Bx
     Mov   Buffer[Bx], 024h   ; agrega $
     Pon_cursor 20,1
     Despliega_Mens CadUnoD
     Pon_Cursor 20,19
     Despliega_Mens BorraL
     Pon_Cursor 20,19
     Despliega_Mens Buffer
     Jmp  CAPNOM01

;--------------------------------------------------------
; TERMINA EL PROGRAMA
;--------------------------------------------------------

TERMINA:
     Borra_Pantalla
     Mov  Ax, 4C00h          ; Termina el programa sin errores.
     Int  21h

.STACK
    End  Empieza
