; Hacer un programa que muestre la cantidad de decimas de segundo que estuvo
; corriendo en modo protegido. Para salir al modo real el usuario podra
; apretar cualquier tecla. Utilizar para ello las interrupciones en modo
; protegido 8 (reloj) y 9 (teclado).
;
; Hecho por Dario Alejandro Alpern el 9 de setiembre de 1999.
;
	.386p
nada	segment use16 at 0
dummy	label far
nada	ends
codigo  segment use16
	assume cs:codigo,ds:codigo
	org 100h
comienzo:jmp inicio
; Valores que van en la tabla de descriptores globales (dos descriptores)
; 1ø descriptor: Segmento de codigo.
gdtab   db 0FFh         ;Bits 7-0 del limite.
        db 0FFh         ;Bits 15-8 del limite.
        db 0            ;Bits 7-0 de la base (se llena durante la ejecucion).
        db 0            ;Bits 15-8 de la base (se llena durante la ejecucion).
        db 0            ;Bits 23-16 de la base (se llena durante la ejecucion).
	db 9Ah		;Byte de derechos de acceso:
			;Bit 7=1: Segmento Presente.
			;Bits 6,5=00: Nivel de Privilegio cero.
                        ;Bit 4=1: Segmento de codigo o datos.
                        ;Bit 3=1: Descriptor correspondiente a codigo.
			;Bit 2=0: Segmento no conforme.
                        ;Bit 1=1: El segmento de codigo se puede leer.
			;Bit 0=0: El segmento no fue accedido.
	db 0		;Bit 7=0: Granularidad = 1 byte.
			;Bit 6=0: Segmento de 16 bits.
			;Bit 5,4=00: No usados.
                        ;Bits 3-0=0000: Bits 19-16 del limite.
	db 0		;Bits 31-24 de la base.
; 2ø descriptor: Segmento de datos.
        db 0FFh         ;Bits 7-0 del limite.
        db 0FFh         ;Bits 15-8 del limite.
	db 0		;Bits 7-0 de la base.
	db 0		;Bits 15-8 de la base.
	db 0		;Bits 23-16 de la base.
	db 92h		;Byte de derechos de acceso:
			;Bit 7=1: Segmento Presente.
			;Bits 6,5=00: Nivel de Privilegio cero.
                        ;Bit 4=1: Segmento de codigo o datos.
			;Bit 3=0: Descriptor correspondiente a datos.
                        ;Bit 2=0: Offset <= Limite. 
			;Bit 1=1: El segmento de datos se puede escribir.
			;Bit 0=0: El segmento no fue accedido.
	db 0Fh		;Bit 7=0: Granularidad = 1 byte.
			;Bit 6=0: Segmento de 16 bits.
			;Bit 5,4=00: No usados.
                        ;Bits 3-0=1111: Bits 19-16 del limite.
	db 0		;Bits 31-24 de la base.
; Valores que van en la tabla de descriptores de interrupcion
; (dos descriptores correspondientes a INT 8 e INT 9)
; 1ø Descriptor: Compuerta de interrupcion correspondiente a INT 8.
idtab	dw int8han	;Bits 15-0 del offset.
        dw cs_sel       ;Selector del segmento de codigo.
        db 0            ;Cantidad de palabras que ocupan los parametros.
        db 86h          ;Indica que es una compuerta de interrupcion tipo 286.
	dw 0		;Bits 31-16 del offset.
; 2ø Descriptor: Compuerta de interrupcion correspondiente a INT 9.
	dw int9han	;Bits 15-0 del offset.
        dw cs_sel       ;Selector del segmento de codigo.
        db 0            ;Cantidad de palabras que ocupan los parametros.
        db 86h          ;Indica que es una compuerta de interrupcion tipo 286.
	dw 0		;Bits 31-16 del offset.
cs_sel  equ 8           ;Valor del selector del segmento de codigo.
ds_sel  equ 16		;Valor del selector del segmento de datos.
gdt	equ gdtab - 8	;Inicio de la tabla de descriptores globales.
idt     equ idtab - 64  ;Inicio de la tabla de interrupcion.
texto1  db "Este programa no puede correr en modo virtual 8086.",13,10
        db "Pruebe eliminando la linea DEVICE=EMM386 en CONFIG.SYS",13,10,"$"
texto2  db "Este programa requiere 80386 o posterior.",13,10,"$"
texto3  dw 24*160+25*2
        db "Hecho por Dario Alpern el 9/9/1995.",0
texto4  dw 11*160+25*2
	db "Segundos en modo protegido:",0
texto5  dw 13*160+25*2
	db "Apriete cualquier tecla para salir.",0
picint  db 0
gdtr    label fword     ;Informacion a almacenar en el GDTR.
        dw 3*8-1        ;Limite de la tabla de descriptores globales.
	dd 0		;Base de la tabla de descriptores globales.
                        ;Se llena durante la ejecucion del programa.
idtr    label fword     ;Informacion a almacenar en el IDTR.
        dw 10*8-1       ;Limite de la tabla de descriptores de interrupcion.
        dd 0            ;Base de la tabla de descriptores de interrupcion.
real_idtr df 0		;Espacio para almacenar el IDTR en modo real.
final   db 0            ;Indicador para saber si se apreto una tecla.
tics    dd 0            ;Tiempo (en tics de reloj) desde que comenzo el prog.
inicio:	mov dx,offset texto2
test86:	pushf		;Sirve para rechazar un 8086. En este procesador
	pop ax		;los bits 15-12 del registro de indicadores siempre
        and ax,0FFFh    ;estan a uno.
	push ax
	popf
	pushf
	pop ax
	add ax,1000h
	jc short mal
test286:pushf		;Sirve para rechazar un 80286. En este procesador
	pop ax		;los bits 15-12 del registro de indicadores siempre
        or ax,0F000h    ;estan a cero en modo real.
	push ax
	popf
	pushf
	pop ax
	and ax,0F000h
	jz short mal
virtual?:smsw ax        ;Sirve para ver si el 80386 esta en modo virtual.
        test al,1       ;Aqui no puede utilizarse MOV EAX,CR0.
	jz short modo_real
	mov dx,offset texto1
mal:  	mov ah,9	;Mostrar el mensaje de error.
	int 21h
        mov ax,4c01h    ;Terminar el programa con codigo de salida 1.
	int 21h
modo_real:in al,21h	;Almacenar en un lugar temporal los IRQ habilitados
	mov picint,al	;en el controlador de interrupciones (PIC).
	mov real_cs,cs	;Llenar el campo correspondiente al segmento en el 
                        ;salto intersegmento que esta mas abajo.
        mov ah,0fh      ;Averiguar el modo de video segun la BIOS. Si vale 7,
	int 10h		;el buffer de video comienza en B0000h, en caso
	mov ebp,0B8000h	;contrario, en B8000h.
	cmp al,7
	jnz short ebp_ok
	xor bp,bp
ebp_ok: mov ax,cs       ;Llenar la base del descriptor del segmento de codigo
	xor dx,dx	;en la tabla de descriptores globales con la misma
	shld dx,ax,4	;base que para el modo real.
        shl ax,4        ;DL:AX = Direccion lineal del segmento de codigo.
	mov byte ptr gdt[cs_sel+4],dl
	mov word ptr gdt[cs_sel+2],ax
	mov bx,ax
	mov cl,dl
	add ax,offset gdt
        adc dl,0        ;DL:AX = Direccion lineal de la GDT.
	mov word ptr gdtr[2],ax
	mov byte ptr gdtr[4],dl
	add bx,offset idt
        adc cl,0        ;CL:BX = Direccion lineal de la IDT.
	mov word ptr idtr[2],bx
	mov byte ptr idtr[4],cl
	mov al,0FFh	;Deshabilitar todas las IRQ del PIC.
	out 21h,al
	jmp $+2
	sidt real_idtr	;Almacenar en memoria el IDTR del modo real.
	lgdt gdtr	;Cargar el GDTR.
	lidt idtr	;Cargar el IDTR.
	push cs_sel	;Poner en la pila el descriptor y el offset del
        push offset modo_protegido ;codigo en modo protegido.
	mov eax,cr0	;Pasar a modo protegido poniendo a uno el bit 0
	or al,1		;(Protection Enable) de CR0.
	mov cr0,eax
        retf            ;Ir a ejecutar codigo en modo protegido.
                        ;En este caso es la instruccion siguiente.
modo_protegido:
	mov ax,ds_sel
	mov ds,ax	;Poner en DS el selector del segmento de datos.
        mov ebx,ebp     ;Limpiar la pantalla. Notese que el offset supera
        mov cx,2000     ;los 64KB en modo protegido (con la eleccion
        mov ax,0720h    ;realizada en la GDT debera ser menor que 1MB).
bucle_cls:mov [ebx],ax
	add ebx,2
	loop bucle_cls
	mov si,offset texto3 ;Mostrar las tres leyendas en pantalla.
	call mostrar_texto
	mov si,offset texto4
	call mostrar_texto
	mov si,offset texto5
	call mostrar_texto
        mov al,0FCh     ;Habilitar unicamente la INT 8 (reloj) e INT 9
	out 21h,al	;(teclado).
	jmp $+2
espera: cmp ss:final,0  ;Se apreto una tecla?
        jz espera       ;Saltar si no es asi.
	mov al,0FFh	;Deshabilitar todas las interrupciones.
	out 21h,al
	jmp $+2
	mov eax,cr0	;Volver a modo real poniendo a cero el bit 0 de CR0.
	and al,0feh
	mov cr0,eax
        jmp far ptr dummy ;Aqui es absolutamente necesario un salto DIRECTO
                          ;intersegmento. No funciona ni el metodo de RETF
			  ;(como arriba) ni un salto indirecto.
	org $-4
	dw regreso_a_modo_real ;Offset del salto.
real_cs	dw 0		  ;Segmento del salto.
regreso_a_modo_real:
	lidt ss:real_idtr ;Restaurar el valor de IDTR.
	mov al,ss:picint  ;Restaurar las habilitaciones de la PIC.
	out 21h,al
	jmp $+2
	mov ax,4c00h	;Terminar el programa.
	int 21h
;La siguiente subrutina muestra un texto ASCIIZ apuntado por ss:[si].
mostrar_texto:
	movzx ebx,word ptr ss:[si]
        add ebx,ebp     ;EBX = Direccion donde debe ir el texto en pantalla.
	inc si
bucle_disp:inc si       ;Apuntar al siguiente caracter.
        mov al,ss:[si]  ;Obtener el proximo caracter a mostrar.
        and al,al       ;Ver si se termino.
        jz short fin_disp ;Saltar si es asi.
	mov [ebx],al	;Mandarlo a pantalla.
        add ebx,2       ;Apuntar a la siguiente posicion en pantalla.
	jmp bucle_disp
fin_disp:ret		;Terminar la subrutina.
;Manejador de la interrupcion de reloj.
int8han:pushad		;Preservar todos los registros de 32 bits de uso gral.
	mov eax,ds:[046Ch] ;Actualizar el tic de reloj para mantenerlo en hora.
	inc eax
        cmp eax,180040h ;Llego medianoche?
        jnz short guardar_tic   ;Saltar si no es asi.
	inc byte ptr ds:[0470h]	;Indicarlo en la variable de la RAM BIOS.
	xor eax,eax
guardar_tic:mov ds:[046Ch],eax
	inc dword ptr ss:tics	;Incrementar tics desde inicio del programa.
        mov eax,35997*65536     ;Convertir a decimos de segundo.
	mul dword ptr ss:tics
        mov ebx,ebp             ;Obtener posicion a mostrar en pantalla.
	add bx,ss:texto4
        add bx,(texto5 - texto4) * 2 ;EBX = Posicion en pantalla.
	mov cl,0
	mov eax,1000000000
	call digito
	mov eax,100000000
	call digito
	mov eax,10000000
	call digito
	mov eax,1000000
	call digito
	mov eax,100000
	call digito
	mov eax,10000
	call digito
	mov ax,1000
	call digito
	mov ax,100
	call digito
	mov cl,1
	mov al,10
	call digito
	mov ch,"."
	call mostr_dig
	mov al,1
	call digito
fin_inter:mov al,20h         ;Indicarle al PIC que finalizo la interrupcion.
	out 20h,al
        popad                ;Restaurar los registros.
        iret                 ;Fin de la interrupcion.
digito: mov ch,"0"-1
bucle_dig:inc ch
	sub edx,eax
	jnc bucle_dig
	add edx,eax
	and cl,cl
	jnz short mostr_dig
	cmp ch,"0"
	jz short fin_digito
	mov cl,1
mostr_dig:mov [ebx],ch
	add ebx,2
fin_digito:ret
int9han:pushad			;Preservar los registros de 32 bits.
        in al,60h               ;Obtener informacion del controlador de teclado
        and al,al               ;La tecla se acaba de apretar o de soltar?
	js fin_inter		;Saltar si se acaba de soltar.
	mov ss:final,1		;Indicar que se termine el programa.
	jmp fin_inter		;Ir a restaurar los registros.
codigo  ends
	end comienzo   
