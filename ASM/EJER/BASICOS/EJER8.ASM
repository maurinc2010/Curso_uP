;******************************************************************************
; Nombre del programa   :   EJER8.ASM
; Objetivo              :   Realizar operaciones de suma, resta,
;			    multiplicaci¢n y divisi¢n sobre dos cantidades
;			    enteras sin signo y no mayores de 65535.
;******************************************************************************
; COMANDO DE ENSAMBLE   : Masm EJER8;
; COMANDO DE ENLACE     : Link EJER8;
; COMANDO DE EJECUCION  : EJER8 [Enter]
;******************************************************************************
; NOTA : se procura usar SOLO las instrucciones que se han visto o explicado.
;        El objetivo es educativo y NO de optimizaci¢n o
;        eficientar. Por favor, NO SE DESESPERE y est£dielo.
;******************************************************************************

; Define el modelo de memoria

.MODEL SMALL

.Data

  ErrorCAP DB  0     ; Bandera de error en la captura de las cantidades
  Cantidad DB  0     ; La cantidad sobre la que se opera. Si es 0 se opera
                     ; sobre la cantidad 1, si es 1 se opera sobre la
                     ; cantidad 2.
  CantUnoR DW  0     ; Variable que guarda la cantidad 1 convertida a binario.
  CantDosR DW  0     ; Variable que guarda la cantidad 2 convertida a binario.
  CantUnoN DB  6,0,6 DUP(?)  ; Variable que almacena la cantidad 1 
  CantDosN DB  6,0,6 DUP(?)  ; Variable que almacena la cantidad 2 
  Funcion  DB  0             ; Variable que guarda la funci¢n a realizar
  Resulta  DB  13,10,13,10,'El resultado es: $'
  ResultaR DB  11 DUP('?')
  Mensaje  DB  'Bienvenidos a EJ01CA05, que le permite realizar las'
  	   DB  13,10
           DB  'operaciones BASICAS de MULTIPLICACION, DIVISION, SUMA'
           DB  13,10,'y RESTA sobre dos cantidades enteras.'
           DB  13,10,13,10,'$'
  Pregunta DB  13,10,13,10,'DIGITE:',13,10,13,10
           DB  ' (1) para MULTIPLICAR.',13,10
           DB  ' (2) para DIVIDIR.',13,10
           DB  ' (3) para SUMAR.',13,10
           DB  ' (4) para RESTAR.',13,10
           DB  ' (5) para TERMINAR.',13,10,'$'
  Error    DB  7,7,7,13,10,'ERROR : en la selecci¢n de las opciones.'
           DB  13,10,13,10,'$'
  Error1   DB  7,7,7,13,10,'ERROR : d¡gito INVALIDO en CANTIDAD 1.'
           DB  13,10,13,10,'$'
  Error2   DB  7,7,7,13,10,'ERROR : d¡gito INVALIDO en CANTIDAD 2.'
           DB  13,10,13,10,'$'
  Error3   DB  7,7,7,13,10,'ERROR : cantidad fuera de RANGO ( 65535).'
  	   DB  ' !!!.'
           DB  13,10,13,10,'$'
  Error4   DB  7,7,7,13,10,'ERROR : intento de DIVISION por CERO.'
           DB  13,10,13,10,'$'

  CantunoM DB  13,10,13,10,'Digite primer CANTIDAD (debe ser < a 65535)'
  	   DB  ' : $'
  CantDosM DB  13,10,13,10,'Digite Segunda CANTIDAD (debe ser < a 65535)'
  	   DB  ' : $'

;------------------------------------------------------------------------------
; TABLA DE POTENCIAS USADA PARA CONVERTIR EL RESULTADO BINARIO DE LA
; OPERACION EN FORMATO ASCII. SE USAN LAS POTENCIAS DE 10 (1, 10, 100, 1000
; y 10000), PORQUE EL NUMERO MAS GRANDE ES 65535. EN CASO DE QUE QUIERA
; OPERAR SOBRE NUMEROS MAS GRANDES AMPLIE LA TABLA.
;------------------------------------------------------------------------------

  Potencia  DW  0001h, 000ah, 0064h, 03E8h, 2710h
  PotenciaF DW  $

.CODE                       ; Area de c¢digo


Empieza:                    ; Etiqueta de comienzo de programa

;------------------------------------------------------------------------------
; BORRA LA PANTALLA CAMBIANDO LA MODALIDAD DE VIDEO. ESTA FORMA DE BORRAR 
; LA PANTALLA ES MUY PECULIAR Y SE CONSIDERA COMO "TRUCO". SE BASA EN EL
; HECHO DE QUE AL CAMBIAR LA MODALIDAD DE VIDEO, EL PROPIO BIOS (HARDWARE)
; BORRA LA PANTALLA POR NOSOTROS. ES UN METODO BURDO PERO MUY EFICIENTE.
;------------------------------------------------------------------------------

  Mov  Ah, 0Fh              ; Obtiene la modalidad de video actual
  Int  10h
  Mov  Ah, 0                ; Cambia la modalidad de video que se obtuvo
  Int  10h
  Mov  Ax,@Data             ; Inicializa DS con la direcci¢n de @Data
  Mov  Ds, Ax
  Mov  Dx, Offset Mensaje   ; Despliega el mensaje de bienvenida
  Call Imprime
  Mov  Si, Offset ResultaR  ; Inicializa la variable ResultaR
  Add  Si, 11
  Mov  Al, '$'
  Mov  [Si], Al

;------------------------------------------------------------------------------
; SE DESPLIEGA EL MENU DE OPCIONES A ELEGIR. LA OPCION ELEGIDA DEBE DE ESTAR
; COMPRENDIDA ENTRE 1 Y 5. ESTO ES VERIFICADO POR LAS INSTRUCCIONES CMP Y
; JAE (SALTA SI MAYOR O IGUAL A) Y JBE (SALTA SI MENOR O IGUAL A).
; NOTE QUE LA SELECCION "NO ES DEPLEGADA A LA PANTALLA", ESO SE DEJA A SU
; CREATIVIDAD. SI EXISTE ALGUN ERROR, SE DESPLEGARA EL MENSAJE APROPIADO.
;------------------------------------------------------------------------------

OTRA:
  Mov  Dx, Offset Pregunta  ; Despliega men£ de opciones
  Call Imprime
  Call ObtenTecla           ; Espera a que el usuario seleccione la
                            ; funci¢n a realizar (1 a 5)
  Cmp  Al, 49               ; La selecci¢n del usuario es mayor o igual
  Jae  SIGUE                ; a 1 ?.
  Mov  Dx, Offset Error     ; NO, despliega mensaje de error
  Call Imprime
  Jmp  OTRA

SIGUE:
  Cmp  Al, 53               ; La selecci¢n del usuario es menor o igual
  Jbe  TODOBIEN             ; a 5?.
  Mov  Dx, Offset Error     ; NO, despliega mensaje de error
  Call Imprime
  Jmp  OTRA

TODOBIEN:
  Cmp  Al, 53
  Jnz  CHECATODO
  Jmp  FUNCION5

CHECATODO:
  Mov  Funcion, Al          ; Guarda la funci¢n a realizar

;------------------------------------------------------------------------------
; SE CAPTURAN LAS CANTIDADES Y SE GUARDAN EN SUS RESPECTIVAS VARIABLES PARA
; PODER TRABAJAR SOBRE ELLAS MAS ADELANTE. LA CAPTURA SE BASA EN LA FUNCION
; 09 DE LA INT 21H. DICHA FUNCION ESTABLECE QUE EL REGISTRO AH CONTENGA 09
; Y EL REGISTRO PAR DS:DX APUNTE A LA DIRECCION DE LA VARIABLE QUE
; ALMACENARA LA ESTRUCTURA DEL BUFFER, EL CUAL DEBE ESTAR CONSTRUIDO DE LA
; SIGUIENTE MANERA:
;
;  BYTE 1  =  CANTIDAD DE BYTES POR LEER
;  BYTE 2  =  (LLENADO POR MS-DOS) ES LA CANTIDAD DE BYTES REALMENTE LEIDOS.
;  BYTE 3  =  BUFFER DON DE SE ALMACENA EL RESULTADO; DEBE ENCONTRARSE
;             INICIALIZADO CON LA MISMA CANTIDAD DE BYTES ESPECIFICADOS 
;             POR EL BYTE 1.
;
; LAS CANTIDADES CAPTURADAS REPRESENTAN UNA CADENA QUE ES NECESARIO
; CONVERTIR EN BINARIO ANTES DE QUE SE PUEDA OPERAR SOBRE ELLA. MAS
; ADELANTE SERA EVIDENTE LO ANTERIOR.
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; CAPTURA PRIMER CANTIDAD.
;------------------------------------------------------------------------------

CAPCANT01:
  Mov  Dx, Offset CantUnoM  ; Mensaje de captura de cantidad 1
  Call Imprime
  Mov  Ah, 0Ah              ; Captura la cantidad (hasta 8 d¡gitos)
  Mov  Dx, Offset CantUnoN
  Int  21h
  Mov  ErrorCAP, 0          ; Supone que no hay errores y que se est 
  Mov  Cantidad, 0          ; operando sobre la cantidad 1.
  Call ConvNUM              ; Convierte cantidad 1 a binario
  Cmp  ErrorCAP, 1          ; ¨Hubo error?
  Jz   CAPCANT01            ; S¡, regresa a la captura
  Mov  CantUnoR, Bx         ; Guarda resultado de conversi¢n

;------------------------------------------------------------------------------
; CAPTURA SEGUNDA CANTIDAD.
;------------------------------------------------------------------------------

CAPCANT02:
  Mov  ErrorCAP, 0          ; Supone que no hay error
  Mov  Cantidad, 1          ; Indica a ConvNUM que es la segunda cantidad
  Mov  Dx, Offset CantDosM  ; Mensaje de captura de cantidad 2
  Call Imprime
  Mov  Ah, 0Ah              ; Captura la segunda cantidad
  Mov  Dx, Offset CantDosN
  Int  21h
  Call ConvNUM              ; Convierte cantidad 2 a binario
  Cmp  ErrorCAP, 1          ; ¨Hay error?
  Jz   CAPCANT02            ; S¡, regresa a capturar la cantidad
  Mov  CantDosR, Bx         ; Guarda conversi¢n de cantidad 2

;------------------------------------------------------------------------------
; DESPUES DE CAPTURAR LAS DOS CANTIDADES SOBRE LAS CUALES SE VA A OPERAR,
; SE DEFINE CUAL ES LA FUNCION POR REALIZAR (MULTIPLICACION, DIVISION, SUMA
; O RESTA).
;------------------------------------------------------------------------------

  Mov  Al, Funcion          ; Funcion que selecciona el usuario
  Cmp  Al, 31h              ; ¨Es 1?
  Jne  FUNCION2             ; No.
  Call Multiplica           ; Multiplica las dos cantidades
  Jmp  OTRA

FUNCION2:
  Cmp  Al, 32h              ; ¨Es 2?
  Jne  FUNCION3             ; No.
  Call Divide               ; Divide las dos cantidades
  Jmp  OTRA

FUNCION3:
  Cmp  Al, 33h              ; ¨Es 3?
  Jne  FUNCION4             ; No.
  Call Suma                 ; Suma las dos cantidades
  Jmp  OTRA

FUNCION4:
  Cmp  Al, 34h              ; ¨Es 4?
  Jne  FUNCION5             ; No.
  Call Resta                ; Resta las dos cantidades
  Jmp  OTRA
FUNCION5:

;------------------------------------------------------------------------------
; TERMINA EL PROGRAMA
;------------------------------------------------------------------------------

  Mov  Ax, 4C00h          ; Termina el programa sin errores.
  Int  21h

;******************************************************************************
;                   R U T I N A S    D E    S O P O R T E
;******************************************************************************

;------------------------------------------------------------------------------
; Rutina      : Multiplica
; Prop¢sito   : Multiplica dos n£meros enteros sin signo
; Par metros  : En el registro AX el multiplicando y en BX el multiplicador
; Regresa     : El resultado en el registro par DX:AX, que es desplegado en
;               la pantalla.
;------------------------------------------------------------------------------

Multiplica Proc Near
  Xor  Dx, Dx               ; Dx = 0 por si acaso
  Mov  Ax, CantUnoR         ; Primera cantidad (multiplicando)
  Mov  Bx, CantDosR         ; Segunda cantidad (multiplicador)
  Mul  Bx                   ; Multiplica
  Call ConvASCII            ; Convierte en ASCII
  Mov  Dx, Offset Resulta   ; Prepara para desplegar la cadena del
  Call Imprime              ; resultado
  Mov  Dx, Offset ResultaR  ; Despliega el resultado.
  Call Imprime
  Ret
Multiplica Endp

;------------------------------------------------------------------------------
; Rutina      : Divide
; Prop¢sito   : Divide dos n£meros enteros sin signo
; Par metros  : En el registro AX el dividendo y en BX el divisor
; Regresa     : El resultado en el registro par DX:AX, que es desplegado en
;               la pantalla.
;------------------------------------------------------------------------------

Divide Proc Near

  Mov  Ax, CantUnoR        ; Carga la cantidad 1 (dividendo)
  Mov  Bx, CantDosR        ; Carga la cantidad 2 (divisor)
  Cmp  Bx, 0               ; Revisa si el divisor es 0 para evitar un
  			   ; error de divisi¢n por cero.
  Jnz  DIVIDE01
  Mov  Cantidad, 3         ; Hubo error, as¡ que despliega el mensaje y
 			   ; salta
  Call HuboERROR
  Ret
DIVIDE01:
  Div  Bx                  ; Divide
  Xor  Dx, Dx              ; Dx = 0. No se usa el residuo para simplificar
                           ; las operaciones
  Call ConvASCII           ; Convierte en ASCII
  Mov  Dx, Offset Resulta  ; Despliega la cadena del resultado
  Call Imprime
  Mov  Dx, Offset ResultaR ; Despliega el resultado
  Call Imprime
  Ret
Divide Endp

;------------------------------------------------------------------------------
; Rutina      : Suma
; Prop¢sito   : Suma dos n£meros enteros sin signo
; Par metros  : En el registro AX el primer n£mero y en BX el segundo
; Regresa     : El resultado en el registro par DX:AX, que es desplegado en
;               la pantalla.
;------------------------------------------------------------------------------

Suma Proc Near
  Xor  Dx, Dx               ; Dx = 0 por si acaso existe acarreo
  Mov  Ax, CantUnoR         ; Primera cantidad
  Mov  Bx, CantDosR         ; Segunda cantidad
  Add  Ax, Bx               ; suma
  Jnc  SUMACONV             ; ¨Hubo acarreo?
  Adc  Dx, 0                ; S¡.
SUMACONV:
  Call ConvASCII            ; Convierte resultado en ASCII
  Mov  Dx, Offset Resulta   ; Despliega cadena del resultado
  Call Imprime
  Mov  Dx, Offset ResultaR  ; Despliega el resultado
  Call Imprime
  Ret
Suma Endp

;------------------------------------------------------------------------------
; Rutina      : Resta
; Prop¢sito   : Resta dos n£meros enteros sin signo
; Par metros  : En el registro AX el primer n£mero y en BX el segundo
; Regresa     : El resultado en el registro par DX:AX, que es desplegado en
;               la pantalla.
;------------------------------------------------------------------------------

Resta Proc Near
  Xor  Dx, Dx              ; Dx = 0 por si acaso existe acarreo
  Mov  Ax, CantUnoR        ; Primera cantidad
  Mov  Bx, CantDosR        ; Segunda cantidad
  Sub  Ax, Bx              ; Resta cantidades
  Jnc  RESTACONV           ; ¨Hubo acarreo?
  Sbb  Dx, 0               ; S¡.
RESTACONV:
  Call ConvASCII           ; Convierte en ASCII
  Mov  Dx, Offset Resulta  ; Despliega cadena del resultado
  Call Imprime
  Mov  Dx, Offset ResultaR ; Despliega el resultado
  Call Imprime
  Ret
Resta Endp

;------------------------------------------------------------------------------
; Rutina      : Imprime
; Prop¢sito   : Despliega una cadena
; Par metros  : El registro DX contiene el desplazamiento de la cadena
; Regresa     : Nada
;------------------------------------------------------------------------------

Imprime Proc Near
  Mov  Ah, 9               ; Prepara para desplegar la cadena a trav‚s de la
  Int  21h                 ; INT 21h.
  Ret
Imprime Endp

;------------------------------------------------------------------------------
; Rutina      : Obt‚nTecla
; Prop¢sito   : Espera a que el usuario digite una tecla
; Par metros  : Ninguno
; Regresa     : En el registro AL el c¢digo ASCII de la tecla
;------------------------------------------------------------------------------

ObtenTecla Proc Near
  Mov  Ah, 0               ; Lee una tecla del teclado a trav‚s de la INT 16h
  Int  16h
  Ret
ObtenTecla Endp

;------------------------------------------------------------------------------
; Rutina      : ConvNUM
; Prop¢sito   : Convertir una cadena a un entero largo
; Par metros  : La longitud de la cadena y la direcci¢n de la misma, y se
;               pasan a la pila.
; Regresa     : En el registro BX la cadena convertida en un entero
;------------------------------------------------------------------------------

ConvNUM Proc Near
  Mov  Dx, 0Ah                   ; Multiplicador es 10
  Cmp  Cantidad, 0               ; ¨Es la cantidad 1?
  Jnz  CONVNUM01                 ; NO, as¡ que es la cantidad 2
  Mov  Di, Offset CantUnoN + 1   ; Bytes le¡dos de la cantidad 1
  Mov  Cx, [Di]
  Mov  Si, Offset CantUnoN + 2   ; La cantidad 1
  Jmp  CONVNUM02

CONVNUM01:
  Mov  Di, Offset CantDosN + 1   ; Bytes le¡dos de la cantidad 2
  Mov  Cx, [Di]
  Mov  Si, Offset CantDosN + 2   ; La cantidad 2

CONVNUM02:
  Xor  Ch, Ch                    ; CH = 0
  Mov  Di, Offset Potencia       ; Direcci¢n de la tabla de potencias
  Dec  Si                        ; Posiciona Si en el primer byte de la
  Add  Si, Cx                    ; cadena capturada y le suma el
  Xor  Bx, Bx                    ; desplazamiento de bytes le¡dos
  Std                            ; para que podamos posicionarnos en el
                                 ; final de la misma (apunta al £ltimo
                                 ; d¡gito capturado). BX = 0 y lee la 
                                 ; cadena en forma inversa; es decir, de
                                 ; atr s hacia adelante.

CONVNUM03:
  Lodsb                 ; Levanta un byte del n£mero (esta instrucci¢n indica
                        ; que el registro AL ser  cargado con el contenido
                        ; de la direcci¢n apuntada por DS:SI.
  Cmp  AL,"0"           ; ¨Es menor a 0? (entonces NO es un d¡gito v lido)
  Jb   CONVNUM04        ; S¡, despliega el mensaje de error y termina
  Cmp  AL,"9"           ; ¨Es mayor a 9? (entonces NO es un d¡gito v lido)
  Ja   CONVNUM04        ; S¡, despliega el error y salta
  Sub  Al, 30h          ; Convierte el d¡gito de ASCII a binario
  Cbw                   ; Convierte a palabra
  Mov  Dx, [Di]         ; Obtiene la potencia de 10 que ser  usada para
  Mul  Dx               ; multiplicar, multiplica n£mero y lo suma
  Jc   CONVNUM05        ; a BX. Revisa si hubo acarreo, y si lo hubo, esto
  Add  Bx, Ax           ; significa que la cantidad es > 65535.
  Jc   CONVNUM05        ; Si hay acarreo la cantidad es > 65535
  Add  Di, 2            ; Va a la siguiente potencia de 10
  Loop CONVNUM03        ; Itera hasta que CX sea = 0
  Jmp  CONVNUM06

CONVNUM04:
  Call HuboERROR        ; Algo ocurri¢, despliega mensaje y salta
  Jmp  CONVNUM06

CONVNUM05:
  Mov  Cantidad, 2      ; Hubo acarreo en la conversi¢n, por lo tanto la
  Call HuboERROR        ; cantidad capturada es mayor a 65535.

CONVNUM06:
  Cld                   ; Regresa la bandera de direcci¢n a su estado normal
  Ret                   ; y REGRESA.

ConvNum Endp

;------------------------------------------------------------------------------
; Rutina      : ConvASCII
; Prop¢sito   : Convertir un valor binario en ASCII
; Par metros  : El registro par DX:AX
; Regresa     : Nada, pero almacena el resultado en el buffer ResultaR
;------------------------------------------------------------------------------

ConvASCII Proc Near

;------------------------------------------------------------------------------
; Lo primero que se hace es inicializar la variable que contendr  el
; resultado de la conversi¢n.
;------------------------------------------------------------------------------

  Push Dx
  Push Ax                  ; Guarda el resultado
  Mov  Si, Offset ResultaR ; Inicializa la variable ResultaR llen ndola
  Mov  Cx, 10              ; con asteriscos
  Mov  Al, '*'

ConvASCII01:
  Mov  [Si], Al
  Inc  Si
  Loop ConvASCII01
  Pop  Ax
  Pop  Dx
  Mov  Bx, Ax                  ; Palabra baja de la cantidad
  Mov  Ax, Dx                  ; Palabra alta de la cantidad
  Mov  Si,Offset ResultaR      ; Cadena donde se guardar  el resultado
  Add  Si, 11
  Mov  CX, 10                  ; Divisor = 10

OBTENDIGITO:
  Dec  Si
  Xor  Dx, Dx                  ; DX contendr  el residuo
  Div  Cx                      ; Divide la palabra alta (AX)
  Mov  Di, Ax                  ; Guarda cociente (AX)
  Mov  Ax, Bx                  ; AX = palabra baja (BX)
  Div  Cx                      ; DX ten¡a un residuo de la divisi¢n anterior
  Mov  Bx, Ax                  ; Guarda el cociente
  Mov  Ax, Di                  ; Regresa la palabra alta
  Add  Dl,30h                  ; Convierte residuo en ASCII
  Mov  [Si], Dl                ; Lo almacena
  Or   Ax, Ax                  ; ¨Palabra alta es 0?
  Jnz  OBTENDIGITO             ; No, sigue procesando
  Or   Bx, Bx                  ; ¨Palabra baja es 0?
  Jnz  OBTENDIGITO             ; No, sigue procesando
  Ret

ConvASCII Endp

;------------------------------------------------------------------------------
; Rutina      : HuboERROR
; Prop¢sito   : Desplegar el mensaje de error adecuado.
; Par metros  : Nada
; Regresa     : Nada
;------------------------------------------------------------------------------

HuboERROR  Proc Near

  Cmp  Cantidad, 0        ; ¨Es la cantidad 1?
  Jnz  HUBOERROR02        ; No.
  Mov  Dx, Offset Error1
  Call Imprime
  Mov  ErrorCAP, 1        ; Enciende la bandera de error
  Jmp  HUBOERROR05

HUBOERROR02:
  Cmp  Cantidad, 1        ; ¨Es la cantidad 2?
  Jnz  HUBOERROR03        ; No.
  Mov  Dx, Offset Error2
  Call Imprime
  Mov  ErrorCAP, 1
  Jmp  HUBOERROR05

HUBOERROR03:
  Cmp  Cantidad, 2        ; ¨Cantidad capturada est  fuera de rango ?
  Jnz  HUBOERROR04        ; No.
  Mov  Dx, Offset Error3
  Call Imprime
  Mov  ErrorCAP, 1
  Jmp  HUBOERROR05

HUBOERROR04:
  Mov  Dx, Offset Error4  ; Error de intento de divisi¢n por cero
  Call Imprime
  Mov  ErrorCAP, 1

HUBOERROR05:
  Ret

HuboERROR Endp

  .STACK
  End  Empieza