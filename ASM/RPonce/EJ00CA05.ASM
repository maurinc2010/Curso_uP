;******************************************************************************
; Nombre del programa:   EJER7.ASM
; Objetivo           :   Captura dos cadenas y las compara, reportando si
;                        son iguales o no. La cantidad de caracteres a
;                        comparar est  dada por los caracteres realmente
;                        le¡dos de la cadena 1. Es decir, para que se 
;                        consideren iguales, las dos cadenas deben ser de
;                        la misma longitud. El programa distingue entre
;			 may£sculas y min£sculas. La "A" es diferente de "a". 
;			 Con un poco m s de creatividad, este programa se 
;			 puede ampliar para que busque una cadena dentro de
;			 otra y reporte si existe o no.
;******************************************************************************
; COMANDO DE ENSAMBLE    : Masm EJER7;
; COMANDO DE ENLACE      : Link EJER7;
; COMANDO DE EJECUCION   : EJER7 [Enter]
;******************************************************************************
;
; NOTA : procure usar SOLO las instrucciones que se han visto o explicado.
;        El procedimiento (objetivo) es con fines educativos y NO de
;	 optimizaci¢n o eficiencia. Por favor, NO SE DESESPERE y est£dielo.
;******************************************************************************

; Define el modelo de memoria

.MODEL SMALL

.Data

    Cadena1  DB  15,0,15 DUP(?)      ; Variable que almacena cadena 1
    Cadena2  DB  15,0,15 DUP(?)      ; Variable que almacena cadena 2
    Mensaje  DB  'Bienvenidos a EJ00CA05. Programa ejemplo que compara'
             DB  ' dos cadenas y reporta',13,10
             DB  'si son iguales o no. Para terminar digite FIN en'
             DB  'may£sculas.'
             DB  13,10,'$'
    Error    DB  7,7,7,13,10,'ERROR   :   cadenas son DIFERENTES !!!.'
             DB  13,10,13,10,'$'
    Error1   DB  7,7,7,13,10,'ERROR   :   cadena no puede ser NULA !!!.'
             DB  13,10,13,10,'$'
    Final    DB  'FIN'
    TodoBIEN DB  7,7,7,13,10,'Cadenas son IGUALES.'
             DB  13,10,13,10,'$'
    CadUnoM  DB  13,10,13,10,'Digite primera CADENA: $'
    CadDosM  DB  13,10,13,10,'Digite Segunda CADENA: $'

.CODE                    ; Area de c¢digo


Empieza:                 ; Etiqueta de comienzo de programa

;------------------------------------------------------------------------------
; BORRA LA PANTALLA CAMBIANDO LA MODALIDAD DE VIDEO. ESTA FORMA DE BORRAR
; LA PANTALLA ES MUY PECULIAR Y ES CONSIDERADA COMO UN "TRUCO". SE BASA EN
; EL HECHO DE QUE AL CAMBIAR LA MODALIDAD DE VIDEO, EL PROPIO BIOS
; (HARDWARE) BORRA LA PANTALLA POR NOSOTROS. ES UN METODO BURDO PERO MUY
; EFICIENTE.
;------------------------------------------------------------------------------

     Mov  Ah, 0Fh             ; Obtiene modalidad de video actual
     Int  10h                      
     Mov  Ah, 0               ; Cambia a la modalidad de video que se obtuvo
     Int  10h
     mov  Ax,@Data            ; Inicializa DS con la direcci¢n de @Data
     mov  Ds, Ax
     mov  Dx, Offset Mensaje  ; Despliega el mensaje de bienvenida
     Mov  Ah, 9
     Int  21h
     Push Ds
     Pop  Es                  ; ES = DS

;------------------------------------------------------------------------------
; SE CAPTURAN LAS CADENAS Y SE GUARDAN EN SUS RESPECTIVAS VARIABLES PARA
; PODER TRABAJAR CON ELLAS MAS ADELANTE. LA CAPTURA SE BASA EN LA FUNCION
; 09 DE LA INT 21H. DICHA FUNCION ESTABLECE QUE EL REGISTRO AH CONTENGA 09
; Y EL REGISTRO PAR DS:DX APUNTE A LA DIRECCION DE LA VARIABLE QUE
; ALMACENARA LA ESTRUCTURA DEL BUFFER. ESTE DEBE DE ESTAR CONSTRUIDO DE LA 
; SIGUIENTE MANERA:
;
;  BYTE 1  = CANTIDAD DE BYTES A LEER
;  BYTE 2  = (LLENADO POR MS-DOS) ES LA CANTIDAD DE BYTES REALMENTE
;  LEIDOS.
;  BYTE 3  = BUFFER DONDE SE ALMACENA EL RESULTADO. DEBE ENCONTRARSE
;            INICIALIZADO CON LA MISMA CANTIDAD DE BYTES ESPECIFICADOS
;            POR EL BYTE 1.
;
; LAS CANTIDADES CAPTURADAS REPRESENTAN UNA CADENA QUE ES NECESARIO
; CONVERTIR A BINARIO ANTES DE PODER OPERAR SOBRE ELLA. MAS ADELANTE
; QUEDARA CLARO LO ANTERIOR.
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; CAPTURA PRIMER CADENA
;------------------------------------------------------------------------------

CAPCAD01:
  Mov  Dx, Offset CadUnoM  ; Mensaje de captura de cadena 1
  Mov  Ah, 9
  Int  21h
  Mov  Ah, 0Ah             ; Captura la cantidad (hasta 15 bytes)
  Mov  Dx, Offset Cadena1
  Push Dx                  ; Guarda direcci¢n de variable
  Int  21h
  Pop  Dx
  Inc  Dx                  ; Obtiene cantidad de bytes realmente le¡dos
                           ; que se encuentra en el byte 1 del buffer
  Mov  Si, Dx
  Cmp  Byte ptr [Si], 0    ; ¨Es 0?
  Jnz  CAPCAD02            ; No, as¡ que prosigue
  Mov  Dx, Offset Error1   ; Despliega mensaje de error y captura la
  Mov  Ah, 9               ; cadena de nuevo
  Int  21h
  Jmp  CAPCAD01

;------------------------------------------------------------------------------
; PRIMERO COMPRUEBA SI LA CADENA 1 TIENE LA CADENA "FIN" QUE ESPECIFICA
; TERMINAR ESTE PROGRAMA. SI LO ANTERIOR ES VERDADERO EL PROGRAMA TERMINA,
; DE LO CONTRARIO CAPTURA LA SEGUNDA CADENA Y PROSIGUE. "FIN" DEBE DE ESTAR
; EN MAYUSCULAS.
;------------------------------------------------------------------------------

CAPCAD02:
  Inc  Dx                  ; Primer byte del buffer de CADENA 1
  Mov  Cx, 3               ; Vamos a revisar 3 bytes.
  Mov  Si, Dx              ; Cadena capturada
  Mov  Di, Offset Final    ; Mensaje de final
  Repe Cmpsb               ; ¨Digitaron "FIN"?
  Jcxz TERMINA             ; Si; as¡ que termina este programa

CAPCAD03:
  Mov  Dx, Offset CadDosM  ; Mensaje de captura de cadena 2
  Mov  Ah, 9
  Int  21h
  Mov  Ah, 0Ah             ; Captura la segunda cadena
  Mov  Dx, Offset Cadena2
  Push Dx                  ; Guarda direcci¢n de variable
  Int  21h
  Pop  Dx
  Inc  Dx                  ; Obtiene cantidad de bytes realmente le¡dos
                           ; que se encuentra en el byte 1 del buffer
  Mov  Si, Dx
  Cmp  Byte ptr [Si], 0    ; ¨Es 0?
  Jnz  CAPCAD04            ; No, as¡ que prosigue
  Mov  Dx, Offset Error1   ; Despliega mensaje de error y captura la
  Mov  Ah, 9               ; cadena de nuevo
  Int  21h
  Jmp  CAPCAD03

;------------------------------------------------------------------------------
; YA SE TIENEN LAS DOS CADENAS CAPTURADAS, AHORA PROCEDEMOS A COMPARARLAS Y
; DESPLEGAR EL MENSAJE ADECUADO.
;------------------------------------------------------------------------------

CAPCAD04:
  Xor  Ch, Ch                   ; CH = 0 por si acaso.
  Mov  Si, Offset Cadena1 + 1   ; Bytes realmente le¡dos de cadena 1
  Mov  Cl, byte ptr [Si]        ; Cx tiene bytes le¡dos de cadena 1
  Inc  Cl                       ; Ajusta CL debido a la naturaleza de
                                ; la instrucci¢n de comparaci¢n, y a
                                ; manera en que se comporta 
                                ; la funci¢n 9 de la INT 21H.
  Inc  Si                       ; Regresa a direcci¢n de cadena 1
  Mov  Di, Offset Cadena2 + 2   ; Direcci¢n de cadena 2
  Cld
  Repe Cmpsb                    ; Compara cadenas
  Jcxz CAPCAD05                 ; ¨Son iguales?
  Mov  Dx, Offset Error         ; No, despliega mensaje
  Mov  Ah, 9
  Int  21h
  Jmp  CAPCAD01

CAPCAD05:
  Mov  Dx, Offset TodoBIEN      ; Cadenas son iguales
  Mov  Ah, 9
  Int  21h
  Jmp  CAPCAD01
;------------------------------------------------------------------------------
; TERMINA EL PROGRAMA
;------------------------------------------------------------------------------

TERMINA:
  Mov  Ax, 4C00h                ; Termina el programa sin errores.
  Int  21h

  .STACK
  End  Empieza
