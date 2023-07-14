; Proyecto PONJ

; Proyecto final de la materia de Estructura y Programación de Computadoras, Grupo: 02,
; Profesor: M.I. Luis Sergio Durán Arenas, Semestre: 2021-2, Facultad de Ingeniería, 
; Universidad Nacional Autónoma de México.

; Desarrollado por Iñaky Ordiales Caballero

; Instrucciones:
; Desarrollar un programa en lenguaje ensamblador para arquitectura Intel x86 que funcione 
; como un juego de Pong™, imprimiendo en pantalla una interfaz gráfica que permita la interacción
; computadora-usuario a través del mouse y del teclado de la computadora.

;-------------------------------------------------------------------------------------------------

;_________________________________________________________________________________________________
title "Proyecto Final: Juego Ponj" 	; Descripcion breve del programa.
	.model small			; Tamanio de memoria: small => 64KB memoria programa y 64KB memoria datos
	.386					; Version del procesador (Arquitectura x86)
	.stack 64 				; Tamanio del segmento de pila: 64B
;_________________________________________________________________________________________________


;_________________________________________________________________________________________________
	.data					; Definicion del segmento de datos (Variables y constantes)

; ; ; CONSTANTES
;ASCII de caracteres del marco y pelota
marcoCruceHorDer	equ 	185d 	;'╣'
marcoVer 			equ 	186d 	; '║'
marcoEsqSupDer 		equ 	187d	;'╗'
marcoEsqInfDer 		equ 	188d	; '╝'
marcoEsqInfIzq 		equ 	200d 	;'╚'
marcoEsqSupIzq 		equ 	201d 	; '╔'
marcoCruceVerInf	equ		202d	;'╩'
marcoCruceVerSup	equ		203d	; '╦'
marcoCruceHorIzq	equ 	204d 	;'╠'
marcoHor 			equ 	205d 	; '═'
marcoCruce 			equ		206d	;'╬'

;Atributos de color de BIOS
;Valores de color para carácter
cNegro 			equ		00h
cAzul 			equ		01h
cVerde 			equ 	02h
cCyan 			equ 	03h
cRojo 			equ 	04h
cMagenta 		equ		05h
cCafe 			equ 	06h
cGrisClaro		equ		07h
cGrisOscuro		equ		08h
cAzulClaro		equ		09h
cVerdeClaro		equ		0Ah
cCyanClaro		equ		0Bh
cRojoClaro		equ		0Ch
cMagentaClaro	equ		0Dh
cAmarillo 		equ		0Eh
cBlanco 		equ		0Fh
;Valores de color para fondo de carácter
bgNegro 		equ		00h
bgAzul 			equ		10h
bgVerde 		equ 	20h
bgCyan 			equ 	30h
bgRojo 			equ 	40h
bgMagenta 		equ		50h
bgCafe 			equ 	60h
bgGrisClaro		equ		70h
bgGrisOscuro	equ		80h
bgAzulClaro		equ		90h
bgVerdeClaro	equ	   0A0h
bgCyanClaro		equ	   0B0h
bgRojoClaro		equ	   0C0h
bgMagentaClaro	equ	   0D0h
bgAmarillo 		equ	   0E0h
bgBlanco 		equ	   0F0h
;-------------------------------------------------------------------------------------------------

;-------------------------------------------------------------------------------------------------

; ; ; VARIABLES
titulo 			db 		"PONJ"
player1 		db 		"Player 1"
player2 		db 		"Player 2"
tiempo_cadena	db 		"0:00"
proyecto 		db 		"Proyecto final de EyPC"
creador 		db 		"Creado por: I",165,"AKY ORDIALES CABALLERO"
unJug			db 		"Un jugador"
dosJug			db 		"Dos  jugadores"
quit 			db 		"Salir"
porTiempo1		db 		"TIEMPO"
porTiempo2		db 		"( 2 min)"
porPuntos1		db 		"PUNTOS"
porPuntos2		db 		"( 10 )"
back 			db 		"Regresar"
tiempo_s 		db 		0
p1_score 		db 		0
p2_score		db 		0
grafico 		db 		2 		; 0-inicio, 1-modoDeJuego, 2-Juego, 3-Ganador
individual		db 		1 		; 0-dosJugadores, 1-unJugador
modoJuego		db 		0 		; 0-porTiempo, 1-porPuntos

;variables para guardar la posición del player 1
p1_col			db 		6
p1_ren			db 		14

;variables para guardar la posición del player 2
p2_col 			db 		73
p2_ren 			db 		14

;variables para guardar una posición auxiliar
;sirven como variables globales para algunos procedimientos
col_aux 		db 		0
ren_aux 		db 		0

;variable que se utiliza como valor 10 auxiliar en divisiones
diez 			dw 		10

;Una variable contador para algunos loops
conta 			db 		0

;Variables que sirven de parametros para el procedimiento IMPRIME_BOTON
boton_caracter 	db 		0
boton_renglon 	db 		0
boton_columna 	db 		0
boton_color		db 		0
boton_bg_color	db 		0

;Auxiliar para calculo de coordenadas del mouse
ocho			db 		8

;Cuando el driver del mouse no esta disponible
no_mouse		db 		"No se encuentra driver de mouse. Presione [enter] para salir$"
;-------------------------------------------------------------------------------------------------

; ; ; MACROS
;inicializa_ds_es - Inicializa el valor del registro DS y ES
inicializa_ds_es 	macro
	mov ax,@data
	mov ds,ax
	mov es,ax 		;Este registro se va a usar, junto con BP, para imprimir cadenas con int 10h
endm

;clear - Limpia pantalla
clear macro
	mov ax,0003h 	;ah = 00h, selecciona modo video
					;al = 03h. Modo texto, 16 colores
	int 10h			;llama interrupcion 10h con opcion 00h. 
					;Establece modo de video limpiando pantalla
endm

;posiciona_cursor - Cambia la posición del cursor a la especificada con 'renglon' y 'columna' 
posiciona_cursor macro renglon,columna
	mov dh,renglon	;dh = renglon
	mov dl,columna	;dl = columna
	mov bx,0
	mov ax,0200h 	;preparar ax para interrupcion, opcion 02h
	int 10h 		;interrupcion 10h y opcion 02h. Cambia posicion del cursor
endm 

;muestra_cursor_mouse - Establece la visibilidad del cursor del mouser
muestra_cursor_mouse	macro
	mov ax,1		;opcion 0001h
	int 33h			;int 33h para manejo del mouse. Opcion AX=0001h
					;Habilita la visibilidad del cursor del mouse en el programa
endm

;oculta_cursor_teclado - Oculta la visibilidad del cursor del teclado
oculta_cursor_teclado	macro
	mov ah,01h 		;Opcion 01h
	mov cx,2607h 	;Parametro necesario para ocultar cursor
	int 10h 		;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm

;apaga_cursor_parpadeo - Deshabilita parpadeo cursor cuando se imprimen caracteres con fondo de color
;Habilita 16 colores de fondo
apaga_cursor_parpadeo	macro
	mov ax,1003h 		;Opcion 1003h
	xor bl,bl 			;BL = 0, parámetro para int 10h opción 1003h
  	int 10h 			;int 10, opcion 01h. Cambia la visibilidad del cursor del teclado
endm

;imprime_caracter_color - Imprime un caracter de cierto color en pantalla, especificado por 'char', 'color' y 'bg_color'. 
;Los colores disponibles están en la lista a continuacion;
; utiliza int 10h opcion 09h
; 'char' - caracter que se va a imprimir
; 'color' - color que tomará el caracter
; 'bg_color' - color de fondo para el carácter en la celda
; Cuando se define el color del carácter, éste se hace en el registro BL:
; La parte baja de BL (los 4 bits menos significativos) define el color del carácter
; La parte alta de BL (los 4 bits más significativos) define el color de fondo "background" del carácter
imprime_caracter_color macro caracter,color,bg_color
	mov ah,09h				;preparar AH para interrupcion, opcion 09h
	mov al,caracter 		;AL = caracter a imprimir
	mov bh,0				;BH = numero de pagina
	mov bl,color 			
	or bl,bg_color 			;BL = color del caracter
							;'color' define los 4 bits menos significativos 
							;'bg_color' define los 4 bits más significativos 
	mov cx,1				;CX = numero de veces que se imprime el caracter
							;CX es un argumento necesario para opcion 09h de int 10h
	int 10h 				;int 10h, AH=09h, imprime el caracter en AL con el color BL
endm

;imprime_cadena_color - Imprime una cadena de cierto color en pantalla, especificado por 'cadena', 'color' y 'bg_color'. 
; utiliza int 10h opcion 13h
; 'cadena' - nombre de la cadena en memoria que se va a imprimir
; 'long_cadena' - longitud (en caracteres) de la cadena a imprimir
; 'color' - color que tomarán los caracteres de la cadena
; 'bg_color' - color de fondo para los caracteres en la cadena
imprime_cadena_color macro cadena,long_cadena,color,bg_color
	mov ah,13h				;preparar AH para interrupcion, opcion 13h
	lea bp,cadena 			;BP como apuntador a la cadena a imprimir
	mov bh,0				;BH = numero de pagina
	mov bl,color 			
	or bl,bg_color 			;BL = color del caracter
							;'color' define los 4 bits menos significativos 
							;'bg_color' define los 4 bits más significativos 
	mov cx,long_cadena		;CX = longitud de la cadena, se tomarán este número de localidades a partir del apuntador a la cadena
	int 10h 				;int 10h, AH=09h, imprime el caracter en AL con el color BL
endm

;lee_mouse - Revisa el estado del mouse
;Devuelve:
;;BX - estado de los botones
;;;Si BX = 0000h, ningun boton presionado
;;;Si BX = 0001h, boton izquierdo presionado
;;;Si BX = 0002h, boton derecho presionado
;;;Si BX = 0003h, boton izquierdo y derecho presionados
; (400,120) => 80x25 =>Columna: 400 x 80 / 640 = 50; Renglon: (120 x 25 / 200) = 15 => 50,15
;;CX - columna en la que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
;;DX - renglon en el que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
lee_mouse	macro
	mov ax,0003h
	int 33h
endm

;Hacer la conversion a resolucion 80x25 (columnas x renglones) en modo texto
calcula_coord macro 
	mov ax,dx 			;Copia DX en AX. DX es un valor entre 0 y 199 (renglon)
	div [ocho] 			;Division de 8 bits
						;divide el valor del renglon en resolucion 640x200 en donde se encuentra el mouse
						;para obtener el valor correspondiente en resolucion 80x25
	xor ah,ah 			;Descartar el residuo de la division anterior
	mov dx,ax 			;Copia AX en DX. AX es un valor entre 0 y 24 (renglon)

	mov ax,cx 			;Copia CX en AX. CX es un valor entre 0 y 639 (columna)
	div [ocho] 			;Division de 8 bits
						;divide el valor de la columna en resolucion 640x200 en donde se encuentra el mouse
						;para obtener el valor correspondiente en resolucion 80x25
	xor ah,ah 			;Descartar el residuo de la division anterior
	mov cx,ax 			;Copia AX en CX. AX es un valor entre 0 y 79 (columna)
endm

;comprueba_mouse - Revisa si el driver del mouse existe
comprueba_mouse 	macro
	mov ax,0		;opcion 0
	int 33h			;llama interrupcion 33h para manejo del mouse, devuelve un valor en AX
					;Si AX = 0000h, no existe el driver. Si AX = FFFFh, existe driver
endm
;-------------------------------------------------------------------------------------------------
;_________________________________________________________________________________________________


;_________________________________________________________________________________________________
	.code

inicio:
	inicializa_ds_es	; macro inicializar segmento de datos y segmento extendido
	comprueba_mouse		; macro para revisar si existe driver de mouse
	xor ax,0FFFFh		; compara el valor de AX con FFFFh, si el resultado es zero, entonces existe el driver de mouse
	jz cambiaPantalla	; Si existe el driver del mouse, entonces salta a 'imprime_ui'
						; Si no existe el driver del mouse entonces se muestra un mensaje
	lea dx,[no_mouse]	; carga la dirección del mensaje
	mov ax,0900h		; opcion 9 para interrupcion 21h
	int 21h				; interrupcion 21h. Imprime cadena.
	jmp teclado			; salta a 'teclado'

cambiaPantalla:
	cmp [grafico],0
	je pintaInicioModo
	cmp [grafico],1
	je pintaInicioModo
	cmp [grafico],2
	je pintaJuego
	clear 					; limpia pantalla
	oculta_cursor_teclado	; oculta cursor del mouse
	apaga_cursor_parpadeo 	; Deshabilita parpadeo del cursor
	call DIBUJA_GANADOR		; procedimiento que dibuja marco de la interfaz
	muestra_cursor_mouse 	; hace visible el cursor del mouse
	jmp mouse_no_clic

pintaInicioModo:
	clear 					; limpia pantalla
	oculta_cursor_teclado	; oculta cursor del mouse
	apaga_cursor_parpadeo 	; Deshabilita parpadeo del cursor
	call DIBUJA_INICIO_MODO	; procedimiento que dibuja pantalla inicial
	muestra_cursor_mouse 	; hace visible el cursor del mouse
	jmp mouse_no_clic

pintaJuego:
	clear 					; limpia pantalla
	oculta_cursor_teclado	; oculta cursor del mouse
	apaga_cursor_parpadeo 	; Deshabilita parpadeo del cursor
	call DIBUJA_JUEGO		; procedimiento que dibuja marco de la interfaz
	muestra_cursor_mouse 	; hace visible el cursor del mouse
	jmp mouse_no_clic

pintaGanador:
	clear 					; limpia pantalla
	oculta_cursor_teclado	; oculta cursor del mouse
	apaga_cursor_parpadeo 	; Deshabilita parpadeo del cursor
	call DIBUJA_GANADOR		; procedimiento que dibuja mensaje del ganador
	muestra_cursor_mouse 	; hace visible el cursor del mouse
	jmp mouse_no_clic

;-------------------------------------------------------------------------------------------------

;Revisar que el boton izquierdo del mouse no esté presionado
;Si el botón no está suelto, no continúa
mouse_no_clic:
	lee_mouse				; revisa el estado del mouse
	test bx,0001h			; compara si bx=0001h, es decir si boton izq. esta presionado
	jnz mouse_no_clic		; Si bx AND 0001h no dan 0 (está presionado) salta al inicio de la etiqueta.

;Lee el mouse y avanza hasta que se haga clic en el boton izquierdo
mouse:
	lee_mouse
	test bx,0001h 		;Para revisar si el boton izquierdo del mouse fue presionado
	jz mouse 			;Si el boton izquierdo no fue presionado, vuelve a leer el estado del mouse

	;Leer la posicion del mouse y hacer la conversion a resolucion
	calcula_coord

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Aqui va la lógica de la posicion del mouse;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pantalla:
	cmp [grafico],0
	je pInicio
	cmp [grafico],1
	je pModo
	cmp [grafico],2
	je pJuego
	jmp pGanador
;-------------------------------------------------------------------------------------------------

pInicio:
	cmp dx,0 
	jnz unJugador
	cmp cx,76
	jb mouse_no_clic
	cmp cx,78
	jg mouse_no_clic
	jmp salir 

unJugador:
	cmp dx,11
	jb mouse_no_clic
	cmp dx,13
	jg dosJugadores
	cmp cx,32
	jb mouse_no_clic
	cmp cx,47
	jg mouse_no_clic
	mov [individual],0
	mov [grafico],1
	jmp cambiaPantalla

dosJugadores:
	cmp dx,15
	jb mouse_no_clic
	cmp dx,17
	jg botonSalir
	cmp cx,32
	jb mouse_no_clic
	cmp cx,47
	jg mouse_no_clic
	mov [individual],1
	mov [grafico],1
	jmp cambiaPantalla

botonSalir:
	cmp dx,20
	jb mouse_no_clic
	cmp dx,22
	jg mouse_no_clic
	cmp cx,66
	jb mouse_no_clic
	cmp cx,72
	jg mouse_no_clic
	jmp salir
;-------------------------------------------------------------------------------------------------

pModo:
	cmp dx,0 
	jnz botonTiempo
	cmp cx,76
	jb mouse_no_clic
	cmp cx,78
	jg mouse_no_clic
	jmp salir

botonTiempo:
	cmp dx,12
	jb mouse_no_clic
	cmp dx,14
	jg botonRegresar
	cmp cx,15
	jb mouse_no_clic
	cmp cx,30
	jg botonPuntos
	mov [modoJuego],0
	mov [grafico],2
	jmp cambiaPantalla

botonPuntos:
	cmp cx,49
	jb mouse_no_clic
	cmp cx,64
	jg mouse_no_clic
	mov [modoJuego],1
	mov [grafico],2
	jmp cambiaPantalla

botonRegresar:
	cmp dx,20
	jb mouse_no_clic
	cmp dx,22
	jg mouse_no_clic
	cmp cx,65
	jb mouse_no_clic
	cmp cx,74
	jg mouse_no_clic
	mov [grafico],0
	jmp cambiaPantalla
;-------------------------------------------------------------------------------------------------

pJuego:
	cmp dx,0 
	jnz mouse_no_clic
	cmp cx,76
	jb mouse_no_clic
	cmp cx,78
	jg mouse_no_clic
	jmp salir
;-------------------------------------------------------------------------------------------------
pGanador:
	jmp pInicio

;Si no se encontró el driver del mouse, muestra un mensaje y el usuario debe salir tecleando [enter]
teclado:
	mov ah,08h
	int 21h
	cmp al,0Dh		;compara la entrada de teclado si fue [enter]
	jnz teclado 	;Sale del ciclo hasta que presiona la tecla [enter]

salir:				;inicia etiqueta salir
	clear 			;limpia pantalla
	mov ax,4C00h	;AH = 4Ch, opción para terminar programa, AL = 0 Exit Code
	int 21h			;señal 21h de interrupción, pasa el control al sistema operativo
;-------------------------------------------------------------------------------------------------

; ; ; PROCEDIMIENTOS

	DIBUJA_GANADOR proc 
		ret
	endp

	DIBUJA_INICIO_MODO proc 
		;imprimir esquinas
		posiciona_cursor 0,0
		imprime_caracter_color 177,cAzul,bgNegro
		posiciona_cursor 24,0
		imprime_caracter_color 177,cAzul,bgNegro
		posiciona_cursor 0,79
		imprime_caracter_color 177,cAzul,bgNegro
		posiciona_cursor 24,79
		imprime_caracter_color 177,cAzul,bgNegro
		;imprimir bordes
		mov cx,78
	marco_sup_inf:
		mov [col_aux],cl
		posiciona_cursor 0,[col_aux]
		imprime_caracter_color 176,cAzul,bgNegro
		posiciona_cursor 24,[col_aux]
		imprime_caracter_color 176,cAzul,bgNegro
		mov cl,[col_aux]
		loop marco_sup_inf
		mov cx,23
	marco_izq_der:
		mov [ren_aux],cl
		posiciona_cursor [ren_aux],0
		imprime_caracter_color 176,cAzul,bgNegro
		posiciona_cursor [ren_aux],79
		imprime_caracter_color 176,cAzul,bgNegro
		mov cl,[ren_aux]
		loop marco_izq_der

	cmp [grafico],0
	jnz pantalla_modo
	pantalla_inicio:
		call IMPRIME_DECO_INICIO		; imprimir decoraciones del inicio
		call IMPRIME_TEXTOS_INICIO		; imprimir los textos del inicio
		jmp fin_dibujo_inicio
	pantalla_modo:
		call IMPRIME_DECO_MODO			; imprimir decoraciones del modo
		call IMPRIME_TEXTOS_MODO 		; imprimir los textos del modo
	fin_dibujo_inicio:
		;imprimir [X] para cerrar programa
		posiciona_cursor 0,76
		imprime_caracter_color '[',cRojo,bgNegro
		posiciona_cursor 0,77
		imprime_caracter_color 'X',cRojoClaro,bgNegro
		posiciona_cursor 0,78
		imprime_caracter_color ']',cRojo,bgNegro
		ret
	endp

	IMPRIME_DECO_INICIO proc
		;imprimir la P
		posiciona_cursor 4,29
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 4,30
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 4,31
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 4,32
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 5,29
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 5,32
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 6,29
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 6,30
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 6,31
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 6,32
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 7,29
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 8,29
		imprime_caracter_color 219,cCyanClaro,bgNegro
		;imprimir la O
		posiciona_cursor 4,35
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 4,36
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 4,37
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 4,38
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 5,35
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 5,38
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 6,35
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 6,38
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 7,35
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 7,38
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 8,35
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 8,36
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 8,37
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 8,38
		imprime_caracter_color 219,cCyanClaro,bgNegro
		;imprimir la N
		posiciona_cursor 4,41
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 4,44
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 5,41
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 5,42
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 5,44
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 6,41
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 6,43
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 6,44
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 7,41
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 7,43
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 7,44
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 8,41
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 8,44
		imprime_caracter_color 219,cCyanClaro,bgNegro
		;imprimir la J
		posiciona_cursor 4,47
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 4,48
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 4,49
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 4,50
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 5,49
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 6,49
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 7,47
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 7,49
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 8,47
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 8,48
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 8,49
		imprime_caracter_color 219,cCyanClaro,bgNegro

		;imprimir barras y punto
		posiciona_cursor 3,3
		imprime_caracter_color 219,cVerdeClaro,bgNegro
		posiciona_cursor 4,3
		imprime_caracter_color 219,cVerdeClaro,bgNegro
		posiciona_cursor 5,3
		imprime_caracter_color 219,cVerdeClaro,bgNegro
		posiciona_cursor 6,3
		imprime_caracter_color 219,cVerdeClaro,bgNegro
		posiciona_cursor 7,3
		imprime_caracter_color 219,cVerdeClaro,bgNegro
		posiciona_cursor 14,75
		imprime_caracter_color 219,cVerdeClaro,bgNegro
		posiciona_cursor 15,75
		imprime_caracter_color 219,cVerdeClaro,bgNegro
		posiciona_cursor 16,75
		imprime_caracter_color 219,cVerdeClaro,bgNegro
		posiciona_cursor 17,75
		imprime_caracter_color 219,cVerdeClaro,bgNegro
		posiciona_cursor 18,75
		imprime_caracter_color 219,cVerdeClaro,bgNegro
		posiciona_cursor 11,20
		imprime_caracter_color 219,cAmarillo,bgNegro
		;imprimir lineas
		posiciona_cursor 1,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 1,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 9,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 9,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 14,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 14,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 19,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 19,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 20,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 20,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 23,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 23,40
		imprime_caracter_color 176,cBlanco,bgNegro
		;imprimir botones grandes
		mov cx,16
		mov [col_aux],32
	boton_grande_uno_inicio:
		mov [ren_aux],cl
		posiciona_cursor 11,[col_aux]
		imprime_caracter_color 219,cAzulClaro,bgNegro
		posiciona_cursor 12,[col_aux]
		imprime_caracter_color 219,cAzulClaro,bgNegro
		posiciona_cursor 13,[col_aux]
		imprime_caracter_color 219,cAzulClaro,bgNegro
		inc [col_aux]
		mov cl,[ren_aux]
		loop boton_grande_uno_inicio
		mov cx,16
		mov [col_aux],32
	boton_grande_dos_inicio:
		mov [ren_aux],cl
		posiciona_cursor 15,[col_aux]
		imprime_caracter_color 219,cAzulClaro,bgNegro
		posiciona_cursor 16,[col_aux]
		imprime_caracter_color 219,cAzulClaro,bgNegro
		posiciona_cursor 17,[col_aux]
		imprime_caracter_color 219,cAzulClaro,bgNegro
		inc [col_aux]
		mov cl,[ren_aux]
		loop boton_grande_dos_inicio
		mov cx,7
		mov [col_aux],66
	boton_chico_inicio:
		mov [ren_aux],cl
		posiciona_cursor 20,[col_aux]
		imprime_caracter_color 219,cAzulClaro,bgNegro
		posiciona_cursor 21,[col_aux]
		imprime_caracter_color 219,cAzulClaro,bgNegro
		posiciona_cursor 22,[col_aux]
		imprime_caracter_color 219,cAzulClaro,bgNegro
		inc [col_aux]
		mov cl,[ren_aux]
		loop boton_chico_inicio
		;imprimir boton chico
		ret
	endp

	IMPRIME_TEXTOS_INICIO proc
		;imprime cadena 'proyecto'
		posiciona_cursor 2,29
		imprime_cadena_color proyecto,22,cBlanco,bgGrisClaro
		posiciona_cursor 22,3
		imprime_cadena_color creador,36,cBlanco,bgNegro
		posiciona_cursor 12,35
		imprime_cadena_color unJug,10,cBlanco,bgAzulClaro
		posiciona_cursor 16,33
		imprime_cadena_color dosJug,14,cBlanco,bgAzulClaro
		posiciona_cursor 21,67
		imprime_cadena_color quit,5,cBlanco,bgAzulClaro
		ret
	endp

	IMPRIME_DECO_MODO proc
		;imprimir la P
		posiciona_cursor 2,29
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 2,30
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 2,31
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 2,32
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 3,29
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 3,32
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 4,29
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 4,30
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 4,31
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 4,32
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 5,29
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 6,29
		imprime_caracter_color 219,cCyanClaro,bgNegro
		;imprimir la O
		posiciona_cursor 2,35
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 2,36
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 2,37
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 2,38
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 3,35
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 3,38
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 4,35
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 4,38
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 5,35
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 5,38
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 6,35
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 6,36
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 6,37
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 6,38
		imprime_caracter_color 219,cCyanClaro,bgNegro
		;imprimir la N
		posiciona_cursor 2,41
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 2,44
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 3,41
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 3,42
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 3,44
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 4,41
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 4,43
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 4,44
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 5,41
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 5,43
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 5,44
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 6,41
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 6,44
		imprime_caracter_color 219,cCyanClaro,bgNegro
		;imprimir la J
		posiciona_cursor 2,47
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 2,48
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 2,49
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 2,50
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 3,49
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 4,49
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 5,47
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 5,49
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 6,47
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 6,48
		imprime_caracter_color 219,cCyanClaro,bgNegro
		posiciona_cursor 6,49
		imprime_caracter_color 219,cCyanClaro,bgNegro

		;imprimir barras y punto
		posiciona_cursor 10,3
		imprime_caracter_color 219,cVerdeClaro,bgNegro
		posiciona_cursor 11,3
		imprime_caracter_color 219,cVerdeClaro,bgNegro
		posiciona_cursor 12,3
		imprime_caracter_color 219,cVerdeClaro,bgNegro
		posiciona_cursor 13,3
		imprime_caracter_color 219,cVerdeClaro,bgNegro
		posiciona_cursor 14,3
		imprime_caracter_color 219,cVerdeClaro,bgNegro
		posiciona_cursor 5,75
		imprime_caracter_color 219,cVerdeClaro,bgNegro
		posiciona_cursor 6,75
		imprime_caracter_color 219,cVerdeClaro,bgNegro
		posiciona_cursor 7,75
		imprime_caracter_color 219,cVerdeClaro,bgNegro
		posiciona_cursor 8,75
		imprime_caracter_color 219,cVerdeClaro,bgNegro
		posiciona_cursor 9,75
		imprime_caracter_color 219,cVerdeClaro,bgNegro
		posiciona_cursor 4,66
		imprime_caracter_color 219,cAmarillo,bgNegro
		;imprimir lineas
		posiciona_cursor 1,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 1,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 7,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 7,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 8,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 8,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 11,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 11,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 12,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 12,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 15,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 15,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 16,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 16,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 19,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 19,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 20,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 20,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 23,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 23,40
		imprime_caracter_color 176,cBlanco,bgNegro
		;imprimir botones grandes
		mov cx,16
		mov [col_aux],15
	boton_grande_uno_modo:
		mov [ren_aux],cl
		posiciona_cursor 12,[col_aux]
		imprime_caracter_color 219,cAzulClaro,bgNegro
		posiciona_cursor 13,[col_aux]
		imprime_caracter_color 219,cAzulClaro,bgNegro
		posiciona_cursor 14,[col_aux]
		imprime_caracter_color 219,cAzulClaro,bgNegro
		inc [col_aux]
		mov cl,[ren_aux]
		loop boton_grande_uno_modo
		mov cx,16
		mov [col_aux],49
	boton_grande_dos_modo:
		mov [ren_aux],cl
		posiciona_cursor 12,[col_aux]
		imprime_caracter_color 219,cAzulClaro,bgNegro
		posiciona_cursor 13,[col_aux]
		imprime_caracter_color 219,cAzulClaro,bgNegro
		posiciona_cursor 14,[col_aux]
		imprime_caracter_color 219,cAzulClaro,bgNegro
		inc [col_aux]
		mov cl,[ren_aux]
		loop boton_grande_dos_modo
		mov cx,10
		mov [col_aux],65
	boton_chico_modo:
		mov [ren_aux],cl
		posiciona_cursor 20,[col_aux]
		imprime_caracter_color 219,cAzulClaro,bgNegro
		posiciona_cursor 21,[col_aux]
		imprime_caracter_color 219,cAzulClaro,bgNegro
		posiciona_cursor 22,[col_aux]
		imprime_caracter_color 219,cAzulClaro,bgNegro
		inc [col_aux]
		mov cl,[ren_aux]
		loop boton_chico_modo
		;imprimir boton chico
		ret
	endp

	IMPRIME_TEXTOS_MODO proc
		posiciona_cursor 22,3
		imprime_cadena_color creador,36,cBlanco,bgNegro
		cmp individual,0
		jnz mensaje_dos
		posiciona_cursor 9,35
		imprime_cadena_color unJug,10,cBlanco,bgGrisOscuro
		jmp desp_mensaje
	mensaje_dos:
		posiciona_cursor 9,34
		imprime_cadena_color dosJug,14,cBlanco,bgGrisOscuro
	desp_mensaje:
		posiciona_cursor 13,20
		imprime_cadena_color porTiempo1,6,cBlanco,bgAzulClaro
		posiciona_cursor 14,19
		imprime_cadena_color porTiempo2,8,cBlanco,bgAzulClaro
		posiciona_cursor 13,54
		imprime_cadena_color porPuntos1,6,cBlanco,bgAzulClaro
		posiciona_cursor 14,54
		imprime_cadena_color porPuntos2,6,cBlanco,bgAzulClaro
		posiciona_cursor 21,66
		imprime_cadena_color back,8,cBlanco,bgAzulClaro
		ret
	endp

	DIBUJA_JUEGO proc
		;imprimir esquinas
		;imprimir esquina superior izquierda del marco
		posiciona_cursor 0,0
		imprime_caracter_color 177,cMagenta,bgNegro
		
		;imprimir esquina superior derecha del marco
		posiciona_cursor 0,79
		imprime_caracter_color 177,cMagenta,bgNegro
		
		;imprimir esquina inferior izquierda del marco
		posiciona_cursor 24,0
		imprime_caracter_color marcoEsqInfIzq,cMagenta,bgNegro
		
		;imprimir esquina inferior derecha del marco
		posiciona_cursor 24,79
		imprime_caracter_color marcoEsqInfDer,cMagenta,bgNegro
		
		;imprimir marcos horizontales, superior e inferior
		mov cx,78 		;CX = 004Eh => CH = 00h, CL = 4Eh
	marcos_horizontales:
		mov [col_aux],cl
		;Superior
		posiciona_cursor 0,[col_aux]
		imprime_caracter_color 176,cMagenta,bgNegro
		;Inferior
		posiciona_cursor 24,[col_aux]
		imprime_caracter_color marcoHor,cMagenta,bgNegro
		;Limite mouse
		posiciona_cursor 4,[col_aux]
		imprime_caracter_color marcoHor,cMagenta,bgNegro
		mov cl,[col_aux]
		loop marcos_horizontales

		;imprimir marcos verticales, derecho e izquierdo
		mov cx,23 		;CX = 0017h => CH = 00h, CL = 17h 
	marcos_verticales:
		mov [ren_aux],cl
		;Izquierdo
		posiciona_cursor [ren_aux],0
		imprime_caracter_color marcoVer,cMagenta,bgNegro
		;Inferior
		posiciona_cursor [ren_aux],79
		imprime_caracter_color marcoVer,cMagenta,bgNegro
		mov cl,[ren_aux]
		loop marcos_verticales

		;imprimir marcos verticales internos
		mov cx,3 		;CX = 0003h => CH = 00h, CL = 03h 
	marcos_verticales_internos:
		mov [ren_aux],cl
		;Interno izquierdo (marcador player 1)
		posiciona_cursor [ren_aux],7
		imprime_caracter_color marcoVer,cMagenta,bgNegro

		;Interno derecho (marcador player 2)
		posiciona_cursor [ren_aux],72
		imprime_caracter_color marcoVer,cMagenta,bgNegro

		jmp marcos_verticales_internos_aux1
	marcos_verticales_internos_aux2:
		jmp marcos_verticales_internos
	marcos_verticales_internos_aux1:
		;Interno central izquierdo (Timer)
		posiciona_cursor [ren_aux],32
		imprime_caracter_color marcoVer,cMagenta,bgNegro

		;Interno central derecho (Timer)
		posiciona_cursor [ren_aux],47
		imprime_caracter_color marcoVer,cMagenta,bgNegro

		mov cl,[ren_aux]
		loop marcos_verticales_internos_aux2

		;imprime intersecciones internas	
		posiciona_cursor 0,7
		imprime_caracter_color 177,cMagenta,bgNegro
		posiciona_cursor 4,7
		imprime_caracter_color marcoCruceVerInf,cMagenta,bgNegro

		posiciona_cursor 0,32
		imprime_caracter_color 177,cMagenta,bgNegro
		posiciona_cursor 4,32
		imprime_caracter_color marcoCruceVerInf,cMagenta,bgNegro

		posiciona_cursor 0,47
		imprime_caracter_color 177,cMagenta,bgNegro
		posiciona_cursor 4,47
		imprime_caracter_color marcoCruceVerInf,cMagenta,bgNegro

		posiciona_cursor 0,72
		imprime_caracter_color 177,cMagenta,bgNegro
		posiciona_cursor 4,72
		imprime_caracter_color marcoCruceVerInf,cMagenta,bgNegro

		posiciona_cursor 4,0
		imprime_caracter_color marcoCruceHorIzq,cMagenta,bgNegro
		posiciona_cursor 4,79
		imprime_caracter_color marcoCruceHorDer,cMagenta,bgNegro

		;imprimir [X] para cerrar programa
		posiciona_cursor 0,76
		imprime_caracter_color '[',cRojo,bgNegro
		posiciona_cursor 0,77
		imprime_caracter_color 'X',cRojoClaro,bgNegro
		posiciona_cursor 0,78
		imprime_caracter_color ']',cRojo,bgNegro

		;imprimir título
		posiciona_cursor 0,38
		imprime_cadena_color [titulo],4,cBlanco,bgNegro

		;imprimir mitad
		posiciona_cursor 5,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 5,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 6,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 6,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 9,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 9,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 10,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 10,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 13,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 13,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 14,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 14,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 17,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 17,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 18,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 18,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 21,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 21,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 22,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 22,40
		imprime_caracter_color 176,cBlanco,bgNegro


		call IMPRIME_DATOS_INICIALES
		ret
	endp
;-------------------------------------------------------------------------------------------------

	IMPRIME_DATOS_INICIALES proc
		;inicializa la cadena del timer
		mov [tiempo_cadena],"2"
		mov [tiempo_cadena+1],":"
		mov [tiempo_cadena+2],"0"
		mov [tiempo_cadena+3],"0"
		
		mov [tiempo_s],120 			;inicializa el número de segundos del timer
		mov [p1_score],0 			;inicializa el score del player 1
		mov [p2_score],0 			;inicializa el score del player 2

		;Imprime el score del player 1, en la posición del col_aux
		;la posición de ren_aux está fija en IMPRIME_SCORE_BL
		mov [col_aux],4
		mov bl,[p1_score]
		call IMPRIME_SCORE_BL

		;Imprime el score del player 1, en la posición del col_aux
		;la posición de ren_aux está fija en IMPRIME_SCORE_BL
		mov [col_aux],76
		mov bl,[p2_score]
		call IMPRIME_SCORE_BL

		;imprime cadena 'Player 1'
		posiciona_cursor 2,9
		imprime_cadena_color player1,8,cBlanco,bgNegro
		
		;imprime cadena 'Player 2'
		posiciona_cursor 2,63
		imprime_cadena_color player2,8,cBlanco,bgNegro

		;imprime cadena de Timer
		posiciona_cursor 2,38
		imprime_cadena_color tiempo_cadena,4,cBlanco,bgNegro

		;imprime players
		;player 1
		;columna: p1_col, renglón: p1_ren
		mov al,[p1_col]
		mov ah,[p1_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		call IMPRIME_PLAYER

		;player 2
		;columna: p2_col, renglón: p2_ren
		mov al,[p2_col]
		mov ah,[p2_ren]
		mov [col_aux],al
		mov [ren_aux],ah
		call IMPRIME_PLAYER

		;imprime bola
		;columna: 40, renglón: 14
		mov [col_aux],40
		mov [ren_aux],14
		call IMPRIME_BOLA

		;Botón Stop
		mov [boton_caracter],254d
		mov [boton_color],bgCyan
		mov [boton_renglon],1
		mov [boton_columna],34
		call IMPRIME_BOTON

		;Botón Start
		mov [boton_caracter],16d
		mov [boton_color],bgCyan
		mov [boton_renglon],1
		mov [boton_columna],43d
		call IMPRIME_BOTON

		ret
	endp
;-------------------------------------------------------------------------------------------------

	;procedimiento IMPRIME_SCORE_BL
	;Imprime el marcador de un jugador, poniendo la posición
	;en renglón: 2, columna: col_aux
	;El valor que imprime es el que se encuentre en el registro BL
	;Obtiene cada caracter haciendo divisiones entre 10 y metiéndolos en
	;la pila
	IMPRIME_SCORE_BL proc
		xor ah,ah
		mov al,bl
		mov [conta],0
	div10:
		xor dx,dx
		div [diez]
		push dx
		inc [conta]
		cmp ax,0
		ja div10
	imprime_digito:
		posiciona_cursor 2,[col_aux]
		pop dx
		or dl,30h
		imprime_caracter_color dl,cBlanco,bgNegro
		inc [col_aux]
		dec [conta]
		cmp [conta],0
		ja imprime_digito
		ret
	endp

	;procedimiento IMPRIME_PLAYER
	;Imprime la barra que corresponde a un jugador tomando como referencia la posición indicada por las variables
	;ren_aux y col_aux, donde esa posición es el centro del jugador
	;Se imprime el carácter █ en color blanco en cinco renglones
	IMPRIME_PLAYER proc
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219d,cBlanco,bgNegro
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219d,cBlanco,bgNegro
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219d,cBlanco,bgNegro
		add [ren_aux],3
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219d,cBlanco,bgNegro
		inc [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 219d,cBlanco,bgNegro
		ret
	endp
;-------------------------------------------------------------------------------------------------

	;procedimiento IMPRIME_BOLA
	;Imprime el carácter ☻ (02h en ASCII) en la posición indicada por 
	;las variables globales
	;ren_aux y col_aux
	IMPRIME_BOLA proc
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color 2d,cCyanClaro,bgNegro 
		ret
	endp

	;procedimiento IMPRIME_BOTON
	;Dibuja un boton que abarca 3 renglones y 3 columnas
	;con un caracter centrado dentro del boton
	;en la posición que se especifique (esquina superior izquierda)
	;y de un color especificado
	;Utiliza paso de parametros por variables globales
	;Las variables utilizadas son:
	;boton_caracter: debe contener el caracter que va a mostrar el boton
	;boton_renglon: contiene la posicion del renglon en donde inicia el boton
	;boton_columna: contiene la posicion de la columna en donde inicia el boton
	;boton_color: contiene el color del boton
	IMPRIME_BOTON proc
	 	;La esquina superior izquierda se define en registro CX y define el inicio del botón
		;La esquina inferior derecha se define en registro DX y define el final del botón
		;utilizando opción 06h de int 10h
		;el color del botón se define en BH
		mov ax,0600h 			;AH=06h (scroll up window) AL=00h (borrar)
		mov bh,cBlanco	 		;Caracteres en color rojo dentro del botón, los 4 bits menos significativos de BH
		xor bh,[boton_color] 	;Color de fondo en los 4 bits más significativos de BH
		mov ch,[boton_renglon] 	;Renglón de la esquina superior izquierda donde inicia el boton
		mov cl,[boton_columna] 	;Columna de la esquina superior izquierda donde inicia el boton
		mov dh,ch 				;Copia el renglón de la esquina superior izquierda donde inicia el botón
		add dh,2 				;Incrementa el valor copiado por 2, para poner el renglón final
		mov dl,cl 				;Copia la columna de la esquina superior izquierda donde inicia el botón
		add dl,2 				;Incrementa el valor copiado por 2, para poner la columna final
		int 10h
		;se recupera los valores del renglón y columna del botón
		;para posicionar el cursor en el centro e imprimir el 
		;carácter en el centro del botón
		mov [col_aux],dl  				
		mov [ren_aux],dh
		dec [col_aux]
		dec [ren_aux]
		posiciona_cursor [ren_aux],[col_aux]
		imprime_caracter_color [boton_caracter],bh,[boton_color]
	 	ret 			;Regreso de llamada a procedimiento
	endp	 			;Indica fin de procedimiento UI para el ensamblador
;-------------------------------------------------------------------------------------------------
	end inicio			;fin de etiqueta inicio, fin de programa
;_________________________________________________________________________________________________