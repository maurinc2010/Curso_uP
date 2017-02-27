;**************************************************************************
; Nombre del programa:   EJ00CA04.ASM
; Fecha de creaci¢n  :   Abril 26 de 1993
; Autor              :   J.A. Rojas Ponce
; Objetivo           :   Despliega el t¡tulo del programa y los n£meros
;                        hexadecimales correspondientes del 15 al 1 en
;                        forma de escalera.
;**************************************************************************
; COMANDO DE ENSAMBLE    : Masm Ej00ca04;
; COMANDO DE ENLACE      : Link Ej00ca04;
; COMANDO DE EJECUCION   : Ej00ca04 [Enter]
;**************************************************************************

; --------------------------------------------------------------------
; INICIA EL PROGRAMA. SE DEFINE EL MODELO DE MEMORIA A USAR Y EL
; SEGMENTO DE CODIGO
; --------------------------------------------------------------------

     .MODEL    SMALL          ; Modelo de memoria
     .CODE                    ; Area de c¢digo

Empieza:                      ; Etiqueta de comienzo de programa

     Mov  Ax, @Data           ; Permite el acceso a los datos inicializando
     Mov  Ds, Ax              ; el registro DS con la direcci¢n adecuada.
     Mov  Dx, OFFSET Mensaje  ; Carga la direcci¢n de mensaje a DX para
     Mov  Ah, 9               ; poder desplegarlo con la funci¢n 9 de la
     Int  21h                 ; Int 21h (DS:DX contiene la direcci¢n de
                              ; la cadena que se desplegar ).
     Mov  Cx, 15              ; Contador de los n£meros (van a ser 15).
     Mov  Bx, OFFSET Tabla    ; Permite el acceso a la tabla de equivalencias
                              ; hexadecimales inicializando su direcci¢n
                              ; y apuntando al primer elemento.
Itera:                        ; Etiqueta controladora de las iteraciones
     Mov  Al, Cl              ; Pone en Al el n£mero a traducir
     Xlat 		      ; (empezando desde 15) y lo traduce.
     Mov  Dl, Al              ; Prepara para desplegar el n£mero usando la
     Mov  Ah, 2               ; funci¢n 2 de la Int 21h. Dl debe de tener
     Int  21h                 ; el car cter a ser deplegado.
     Mov  Dl, 10              ; Salta una l¡nea dando un efecto de
     Int  21h                 ; escalera. De nuevo se usa la funci¢n 2.
     Loop Itera               ; Itera hasta llegar a 0 (de 15 a 0). El
                              ; registro CX mantiene una cuenta activa de
                              ; las veces que se ha iterado, y al completar
                              ; un ciclo se decrementa en uno hasta llegar
                              ; a cero.
     Mov  ax,4c00h            ; Regresa a MS-DOS por medio de la funci¢n
     			      ; 4c de la interrupci¢n 21h.
     int  21h                 ; El c¢digo de regreso es 0 porque no hubo
                              ; error. En caso de existir se podr¡a pasar
                              ; un c¢digo diferente a 0 (ej. 4c01h).

; --------------------------------------------------------------------
; INICIA SEGMENTO DE DATOS
; --------------------------------------------------------------------

    .DATA                     ; Segmento de datos

     Mensaje  DB  13,10,13,10
              DB  'Desplegando los n£meros hexadecimales del 15 al 1'
              DB  13,10,13,10,'$'   ; Cadena a desplegar
     Tabla    DB  '0123456789ABCDEF'; Tabla de traducci¢n

; --------------------------------------------------------------------
; INICIA SEGMENTO DE PILA
; --------------------------------------------------------------------

     .STACK                   ; Se necesita una PILA.
     END  Empieza             ; Fin del programa
