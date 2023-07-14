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
title "Proyecto Final: Juego Ponj"
	.model small			; Tamaño de memoria: small => 64KB memoria programa y 64KB memoria datos
	.386					; Version del procesador (Arquitectura x86)
	.stack 64 				; Tamaño del segmento de pila => 64B
;_________________________________________________________________________________________________

;_________________________________________________________________________________________________
	.data					; Definicion del segmento de datos (Variables y constantes)

;-------------------------------------------------------------------------------------------------
; ; ; CONSTANTES ; ; ;

; ASCII de caracteres del marco y pelota
marcoCruceHorDer	equ 	185d 	;'╣'
marcoVer 			equ 	186d 	; '║'
marcoEsqInfDer 		equ 	188d	; '╝'
marcoEsqInfIzq 		equ 	200d 	;'╚'
marcoCruceVerInf	equ		202d	;'╩'
marcoCruceHorIzq	equ 	204d 	;'╠'
marcoHor 			equ 	205d 	; '═'

; Atributos de color de BIOS
; Valores de color para carácter
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
; Valores de color para fondo de carácter
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
; ; ; VARIABLES ; ; ;

; Textos de impresión														; logitud
titulo 			db 		"PONJ"												;  4
jugador1 		db 		"Jugador 1"											;  9
jugador2		db 		"Jugador 2"											;  9
tiempo_cadena	db 		"0:00"												;  4
proyecto 		db 		"Proyecto final de EyPC"							;  22
creador 		db 		"Creado por: I",165,"AKY ORDIALES CABALLERO"		;  36
unJug			db 		"Un jugador"										;  10
dosJug			db 		"Dos  jugadores"									;  14
quit 			db 		"Salir"												;  5
porTiempo1		db 		"TIEMPO"											;  6
porTiempo2		db 		"( 2 min)"											;  8
porPuntos1		db 		"PUNTOS"											;  6
porPuntos2		db 		"( 10 )"											;  6
back 			db 		"Regresar"											;  8
puntos 			db 		"puntos"											;  6
ganador 		db 		"GANADOR            !!!"							;  22
empate 			db 		" EMPATE "											;  8
reiniciar 		db 		"Reiniciar"											;  9
menu 			db 		"Men",163											;  4
teclas1 		db 		"JUGADOR 1: se mueve con '",24,"' y '",25,"'" 		;  33
teclas2 		db 		"JUGADOR 1: se mueve con 'w' y 's'         JUGADOR 2: se mueve con '",24,"' y '",25,"'" ;  75
;Cuando el driver del mouse no esta disponible
no_mouse		db 		"No se encuentra driver de mouse. Presione [enter] para salir$"	;  60

; Variables de selección de características.
grafico 		db 		0 		; 0-inicio		1-modoDeJuego		2-Juego		3-Ganador
individual		db 		0 		; 0-un Jugador 	1-dos Jugadores
modoJuego		db 		0 		; 0-por Tiempo	1-por Puntos
iniciado 		db 		0 		; 0-No iniciado 1-Ya iniciado

; Para las posiciones de jugadores o compu
; posición jugador 1
p1_col			db 		5
p1_ren			db 		14
; Posición jugador 2
p2_col 			db 		74
p2_ren 			db 		14
; auxiliares de posición (sirven como var. globales para algunos procedimientos)
col_aux 		db 		0
ren_aux 		db 		0
; variables de almacenamiento de puntaje del juego
p1_score 		db 		0
p2_score		db 		0

; Variables que sirven de parametros para el procedimiento IMPRIME_BOTON
botonChar 		db 		0
boton_renglon 	db 		0
boton_columna 	db 		0
boton_color		db 		0
boton_bg_color	db 		0

;Variables para el movimiento de la pelota
movPelota 		db 		0 		; 0-casi derecho 	1-poco inclinado 	2-inclinado
gravedad 		db 		0 		; 0-hacia arriba 	1-hacia abajo
sentido 		db 		0 		; 0-derecha 	  	1-izquierda
aux_rebote 		db 		0  		; 0-no rebota		1-rebota
paso 			db 		0 		; variable para definir paso del movimiento (antes de cambiar Y)
								; casi derecho-14 	poco inclinado-3 	inclinado-1
posX			db 		0 		; posicion en X
posY 			db 		0 		; posicion en Y

;Variables cronometro
t_inicial		dw 		0,0		;guarda números de ticks inicial
tick_ms			dw 		55 		;55 ms por cada tick del sistema, esta variable se usa para operación de MUL convertir ticks a segundos
mil				dw		1000 	;dato de valor decimal 1000 para operación DIV entre 1000
cien 			db 		100 	;dato de valor decimal 100 para operación DIV entre 100
sesenta 		db 		60		;dato de valor decimal 60 para operación DIV entre 60
contador 		dw		0		;variable contador
milisegundos	dw		0		;variable para guardar la cantidad de milisegundos
segundos		db		0 		;variable para guardar la cantidad de segundos
minutos 		db		0		;variable para guardar la cantidad de minutos
tiempo_aux		db 		0 		;variable auxiliar para la impresion del cronometro
tiempo_aux2 	db 		0 		;segunda variable auxiliar para la impresión del cronometro

; Auxiliares varios:
; Variables para ajustar tiempos del juego
tiemposJug 		dw  	0000h
tiemposCompu 	dw 		0000h
tiemposPelota 	dw 		0000h
; Una variable contador para algunos loops
conta 			db 		0
; Variable que se utiliza como valor 10 auxiliar en divisiones
diez 			dw 		10
;Auxiliar para calculo de coordenadas del mouse
ocho			db 		8

;-------------------------------------------------------------------------------------------------
							;;;;;;;;; ; ; MACROS ; ; ;;;;;;;;;
;-------------------------------------------------------------------------------------------------
; SEGMENTO DATOS Y PANTALLA

; inicializa_ds_es - Inicializa el valor del registro DS y ES
inicializa_ds_es 	macro
	mov ax,@data
	mov ds,ax
	mov es,ax 		;Este registro se va a usar, junto con BP, para imprimir cadenas con int 10h
endm

; clear - Limpia pantalla
clear macro
	mov ax,0003h 	;ah = 00h, selecciona modo video
					;al = 03h. Modo texto, 16 colores
	int 10h			;llama interrupcion 10h con opcion 00h. 
					;Establece modo de video limpiando pantalla
endm

;-------------------------------------------------------------------------------------------------
; MOUSE

; posiciona_cursor_mouse - Cambia la posición del mouse a la especificada por 'renglon' y 'columna'
posiciona_cursor_mouse 	macro renglon,columna
	mov cx,columna 
	mov dx,renglon 
	mov ax,0004h
	int 33h
endm

; muestra_cursor_mouse - Establece la visibilidad del cursor del mouser
muestra_cursor_mouse	macro
	mov ax,1		;opcion 0001h
	int 33h			;int 33h para manejo del mouse. Opcion AX=0001h
					;Habilita la visibilidad del cursor del mouse en el programa
endm

; bloquea_cursor_juego - Activa límites de movimiento del cursor mientras se juega (640x200)
bloquea_cursor_juego 	macro 
	mov ax,0008h 	; opcion para poner limites horizontales
	mov cx,0000h 	; valor minimo renglón (0)
	mov dx,39d 		; valor máximo renglón (39)
	int 33h 		; int 33h manejo del mouse.
endm

; bloquea_cursor_ganador - Activa límites de movimiento del cursor mientras se muestra el ganador (640x200)
bloquea_cursor_ganador 	macro 
	mov ax,0007h 	; opcion para poner limites verticales
	mov cx,231d 	; valor minimo columna (231)
	mov dx,415d 	; valor máximo columna (415)
	int 33h			; int 33h manejo del mouse.
	mov ax,0008h 	; opcion para poner limites horizontales
	mov cx,63d 		; valor minimo renglón (63)
	mov dx,143d 	; valor máximo renglón (143)
	int 33h 		; int 33h manejo del mouse.
endm

; libera_cursor - Elimina los límites del mouse al ponerlos al tamaño de la pantalla (640x200)
libera_cursor 			macro 
	mov ax,0007h 	; opcion para poner limites verticales
	mov cx,0d 		; valor minimo columna (0)
	mov dx,639d 	; valor máximo columna (639)
	int 33h			; int 33h manejo del mouse.
	mov ax,0008h 	; opcion para poner limites horizontales
	mov cx,0d 		; valor minimo renglón (0)
	mov dx,199d 	; valor máximo renglón (199)
	int 33h 		; int 33h manejo del mouse.
endm

; lee_mouse - Revisa el estado del mouse
; Devuelve:
;	 BX - estado de los botones
; 		 Si BX = 0000h, ningun boton presionado
;		 Si BX = 0001h, boton izquierdo presionado
;		 Si BX = 0002h, boton derecho presionado
;		 Si BX = 0003h, boton izquierdo y derecho presionados
; 	 (400,120) => 80x25 =>Columna: 400 x 80 / 640 = 50; Renglon: (120 x 25 / 200) = 15 => 50,15
;	 CX - columna en la que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
;	 DX - renglon en el que se encuentra el mouse en resolucion 640x200 (columnas x renglones)
lee_mouse	macro
	mov ax,0003h
	int 33h
endm

; calcula_coord - hace la conversion a resolucion 80x25 (columnas x renglones) en modo texto
; Devuelve:
; 	 AX - (columna), valor entre 0 y 79
;	 DX - (renglon), valor entre 0 y 24
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

; comprueba_mouse - Revisa si el driver del mouse existe
comprueba_mouse 	macro
	mov ax,0		;opcion 0
	int 33h			;llama interrupcion 33h para manejo del mouse, devuelve un valor en AX
					;Si AX = 0000h, no existe el driver. Si AX = FFFFh, existe driver
endm

;-------------------------------------------------------------------------------------------------
; TECLADO

; posiciona_cursor - Cambia la posición del cursor a la especificada con 'renglon' y 'columna' 
posiciona_cursor macro renglon,columna
	mov dh,renglon	;dh = renglon
	mov dl,columna	;dl = columna
	mov bx,0
	mov ax,0200h 	;preparar ax para interrupcion, opcion 02h
	int 10h 		;interrupcion 10h y opcion 02h. Cambia posicion del cursor
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


;-------------------------------------------------------------------------------------------------
;_________________________________________________________________________________________________


;_________________________________________________________________________________________________
	.code

;-------------------------------------------------------------------------------------------------
						;;;;;;;;; ; ; INICIO PROGRAMA ; ; ;;;;;;;;;
;-------------------------------------------------------------------------------------------------
inicio:
	inicializa_ds_es	; macro inicializar segmento de datos y segmento extendido
	comprueba_mouse		; macro para revisar si existe driver de mouse
	xor ax,0FFFFh		; compara el valor de AX con FFFFh, si el resultado es zero, entonces existe el driver de mouse
	jz cambiaPantalla	; Si existe el driver del mouse, entonces salta a 'cambiaPantalla'
						; Si no existe el driver del mouse entonces se muestra un mensaje
	lea dx,[no_mouse]	; carga la dirección del mensaje
	mov ax,0900h		; opcion 9 para interrupcion 21h
	int 21h				; interrupcion 21h. Imprime cadena.
	jmp teclado			; salta a 'teclado'

;-------------------------------------------------------------------------------------------------
			;;;;;;;;; ; ; CAMBIO E IMPRESIÓN DE INTERFACES GRÁFICAS ; ; ;;;;;;;;;
;-------------------------------------------------------------------------------------------------
cambiaPantalla:
	cmp [grafico],0
	je pintaInicioModo 	; pasa a imprimir pantalla de Inicio
	cmp [grafico],1
	je pintaInicioModo 	; pasa a imprimir pantalla de selección de modo de juego
	cmp [grafico],2
	je pintaJuego 		; pasa a imprimir pantalla del juego
	jmp pintaGanador 	; pasa a imprimir pantalla del ganador del juego

; imprime la interfaz de inicio o de modo
pintaInicioModo:
	clear 					; limpia pantalla
	oculta_cursor_teclado	; oculta cursor del mouse
	apaga_cursor_parpadeo 	; Deshabilita parpadeo del cursor
	call DIBUJA_INICIO_MODO	; procedimiento que dibuja pantalla inicial
	muestra_cursor_mouse 	; hace visible el cursor del mouse
	libera_cursor  			; quita restricciones de movimiento del mouse
	jmp mouse_no_clic 		; brinca a ver estado del mouse

; imprime la interfaz de juego con los detalles de jugadores y modalida.
pintaJuego:
	clear 					; limpia pantalla
	oculta_cursor_teclado	; oculta cursor del mouse
	apaga_cursor_parpadeo 	; Deshabilita parpadeo del cursor
	call DIBUJA_JUEGO		; procedimiento que dibuja pantalla del juego
	cmp [modoJuego],0 		; checa si el modo de juego es por tiempo
	je detallesTiempo 		; si es por tiempo salta a detallesTiempo, sino continua con detalles de por puntuación
	; a continuación borra el cronometro
	posiciona_cursor 2,38
	imprime_caracter_color 223,cNegro,bgNegro
	posiciona_cursor 2,39
	imprime_caracter_color 223,cNegro,bgNegro
	posiciona_cursor 2,40
	imprime_caracter_color 223,cNegro,bgNegro
	posiciona_cursor 2,41
	imprime_caracter_color 223,cNegro,bgNegro
detallesTiempo:
	posiciona_cursor_mouse 20,319
	muestra_cursor_mouse 	; hace visible el cursor del mouse
	bloquea_cursor_juego 	; restringe la movilidad del mouse
	jmp logicaJuego			; brinca al área lógica del juego

pintaGanador:
	clear 					; limpia pantalla
	oculta_cursor_teclado	; oculta cursor del mouse
	apaga_cursor_parpadeo 	; Deshabilita parpadeo del cursor
	call DIBUJA_GANADOR		; procedimiento que dibuja mensaje del ganador
	muestra_cursor_mouse 	; hace visible el cursor del mouse
	posiciona_cursor_mouse 111,319
	bloquea_cursor_ganador  ; restringe movilidad del mouse
	jmp mouse_no_clic 		; brinca a ver el estado del mouse

;-------------------------------------------------------------------------------------------------
			;;;;;;;;; ; ; ESTADO Y LECTURA DEL MOUSE FUERA DEL JUEGO ; ; ;;;;;;;;;
;-------------------------------------------------------------------------------------------------
; Revisar que el boton izquierdo del mouse no esté presionado
; Si el botón no está suelto, no continúa
mouse_no_clic:
	lee_mouse				; revisa el estado del mouse
	test bx,0001h			; compara si bx=0001h, es decir si boton izq. esta presionado
	jnz mouse_no_clic		; Si bx AND 0001h no dan 0 (está presionado) salta al inicio de la etiqueta.

; Lee el mouse y avanza hasta que se haga clic en el boton izquierdo
mouse:
	lee_mouse
	test bx,0001h 		;Para revisar si el boton izquierdo del mouse fue presionado
	jz mouse 			;Si el boton izquierdo no fue presionado, vuelve a leer el estado del mouse

; Hacer la conversion de las coordenadas de donde hizo click el mouse a resolucion texto
	calcula_coord
; Compara en que pantalla grafica estamos y nos guía a sus procediminetos lógicos respectivos
	cmp [grafico],0
	je logicaInicio
	cmp [grafico],1
	je logicaModo
	jmp logicaGanador


;-------------------------------------------------------------------------------------------------
	   ;;;;;;;;; ; ; LÓGICA DE SELECCIÓN DE OPCIONES EN PANTALLAS (NO JUEGO) ; ; ;;;;;;;;;
;-------------------------------------------------------------------------------------------------

; LOGICA DE LA PANTALLA DE INICIO
; * si no se aprieta en ningún botón vuelve a mouse_no_click a esperar

logicaInicio:
	cmp dx,0 
	jnz unJugador 			; si no se apreto la cruz, checa el botón de un jugador.
	cmp cx,76
	jb mouse_no_clic
	cmp cx,78
	jg mouse_no_clic
	jmp salir 				; si se apreto la cruz, se salta a salir del programa. 

unJugador: 				; se selecciona sólo un jugador
	cmp dx,11
	jb mouse_no_clic
	cmp dx,13
	jg dosJugadores			; si no se apretó el botón de un jugador checa el de dos jugadores
	cmp cx,32
	jb mouse_no_clic
	cmp cx,47
	jg mouse_no_clic
	mov [individual],0 		; si se apretó el botón de un jugador modifica los indicadores
	mov [grafico],1 		; individual y gráfico
	jmp cambiaPantalla 		; y salta a cambia pantalla

dosJugadores: 			; se selecciona el jugar con dos temporadas
	cmp dx,15
	jb mouse_no_clic
	cmp dx,17
	jg botonSalir  			; si no se apretó el botón de dos jugadores checa el de salir
	cmp cx,32
	jb mouse_no_clic
	cmp cx,47
	jg mouse_no_clic
	mov [individual],1  	; si sí se apretó el botón de dos jugador modifica los indicadores
	mov [grafico],1 		; individual y gráfico
	jmp cambiaPantalla 		; y salta a cambia pantalla

botonSalir: 			; salir del programa
	cmp dx,20
	jb mouse_no_clic
	cmp dx,22
	jg mouse_no_clic
	cmp cx,66
	jb mouse_no_clic
	cmp cx,72
	jg mouse_no_clic
	jmp salir 				; si se apretó el botón salir, salta a salir del programa
;-------------------------------------------------------------------------------------------------

; LOGICA DE LA PANTALLA DE MODALIDAD PARA EL JUEGO
; * si no se aprieta en ningún botón vuelve a mouse_no_click a esperar

logicaModo:
	cmp dx,0 
	jnz botonTiempo 		; si no se apreto la cruz, checa el botón de Tiempo.
	cmp cx,76
	jb mouse_no_clic
	cmp cx,78
	jg mouse_no_clic
	jmp salir 				; si se apreto la cruz, se salta a salir del programa.

botonTiempo: 			; establece el modo de juego a por tiempo
	cmp dx,12
	jb mouse_no_clic
	cmp dx,14
	jg botonRegresar 		; si no se apretó el botón tiempo ni el de puntos, salta al de regresar
	cmp cx,15
	jb mouse_no_clic
	cmp cx,30
	jg botonPuntos  		; si no se apretó el botón tiempo, salta a checar el de puntos
	mov [modoJuego],0  		; si sí se apretó el botón de tiempo modifica los indicadores
	mov [grafico],2 		; modoJuego y grafico
	jmp cambiaPantalla 		; y salta a cambio pantalla

botonPuntos: 			; establece el modo de juego a por puntos
	cmp cx,49
	jb mouse_no_clic
	cmp cx,64
	jg mouse_no_clic
	mov [modoJuego],1 		; si sí se apretó el botón de puntos modifica los indicadores
	mov [grafico],2 		; modoJuego y grafico
	jmp cambiaPantalla 		; y salta a cambio pantalla

botonRegresar: 			; regresa a la pantalla inicial
	cmp dx,20
	jb mouse_no_clic
	cmp dx,22
	jg mouse_no_clic
	cmp cx,65
	jb mouse_no_clic
	cmp cx,74
	jg mouse_no_clic
	mov [grafico],0 		; si sí se apretó el botón de regresar modifica el indicador grafico
	jmp cambiaPantalla 		; y salta a cambio pantalla
;-------------------------------------------------------------------------------------------------

; ; LOGICA DE LA PANTALLA DE MENSAJE DE GANADOR
; * si no se aprieta en ningún botón vuelve a mouse_no_click a esperar

logicaGanador:
	cmp dx,14
	jb mouse_no_clic
	cmp dx,16
	jg mouse_no_clic

botonReiniciar: 		; reinicia al principio la partida
	cmp cx,29
	jb mouse_no_clic
	cmp cx,38
	jg botonMenu 			; si no se apretó el botón reiniciar, checa el de menú
	mov [grafico],2 		; si sí se apretó el botón de reiniciar cambia indicador grafico
	jmp cambiaPantalla 		; y salta a cambio pantalla

botonMenu: 				; manda a la pantalla inicial para elegir opciones
	cmp cx,41
	jb mouse_no_clic
	cmp cx,50
	jg mouse_no_clic
	mov [grafico],0 		; si sí se apretó el botón de menú cambia indicador grafico
	jmp cambiaPantalla 		; y salta a cambio pantalla
;-------------------------------------------------------------------------------------------------


;-------------------------------------------------------------------------------------------------
		  			;;;;;;;;; ; ; LÓGICA DENTRO DEL JUEGO ; ; ;;;;;;;;;
;-------------------------------------------------------------------------------------------------


; MOVIMIENTOS DEL MOUSE Y BOTONES
; * si no se aprieta ningún botón salta a checar los movimientos del juego

logicaJuego:
	lee_mouse
	test bx,0001h 			;Para revisar si el boton izquierdo del mouse fue presionado
	jz movJuegos  			;Si el mouse no fue presionado, salta a checar los movimientos del juego
	calcula_coord

botonSalirJuego:		; la cruz de salida
	cmp dx,0
	jnz botonReinicioJuego 	; si no se apretó la cruz, checa el botón de reinicio del juego
	cmp cx,76
	jb movJuegos
	cmp cx,78
	jg movJuegos
	jmp salir 				; si se apretó la cruz, se salta a salir del programa.

botonReinicioJuego:		; reinicia al principio la partida
	cmp [iniciado],1 		; checa si el juego está iniciado
	jne botonInicioJuego 	; si no se ha iniciado el juego, se salta a checar el boton de inicio
	cmp dx,3
	jg movJuegos
	cmp cx,34
	jb movJuegos
	cmp cx,36
	jg movJuegos 		 	; si no se ha apretado el boton de reinicio, se checa el de inicio
	mov [iniciado],0  		; si se apretó botón de reinicio se cambia identificador de iniciado (a 0-no)
	jmp cambiaPantalla		; se salta a cambio de pantalla para volver a imprimir el juego reiniciado

botonInicioJuego:		; inicia la partida
	cmp cx,43
	jb movJuegos
	cmp cx,45
	jg movJuegos
	jmp IniciarJuego 		; si sí se apreto el botón de inicio, salta a iniciar juego
;-------------------------------------------------------------------------------------------------


; MOVIMIENTOS DE JUGADORES (se pueden mover aún sin iniciar el juego)

movJuegos: 						; Movimiento de la compu (para modo individual)
	cmp [individual],0 				; checa si es modo individual
	jne movJugadores 				; si no es modo individual salt a movJugadores
	inc [tiemposCompu] 				; aumenta contador del ciclo para mover la compu
	cmp [modoJuego],0
	je retrasoCompuTiempo
	cmp [tiemposCompu],19FFh 		; compara si el ciclo de la compu se cumple (para puntos)			***AJUSTABLE***
	jne movJugadores 				; si todavía no se cumple, salta a movJugadores
	mov [tiemposCompu],0h 			; si se cumple reinicia contador
	mov al,[p2_ren]
	cmp al,[posY]
	jb moverJugador2Abajo 			; si la pelota está arriba salta a mover la compu hacia abajo
	jg moverJugador2Arriba 			; si la pelota está abajo salta a mover la compu hacia arriba
retrasoCompuTiempo:
	cmp [tiemposCompu],05FFh 		; compara si el ciclo de la compu se cumple (para tiempo)			***AJUSTABLE***
	jne movJugadores 				; si todavía no se cumple, salta a movJugadores
	mov [tiemposCompu],0h 			; si se cumple reinicia contador
	mov al,[p2_ren]
	cmp al,[posY]
	jb moverJugador2Abajo 			; si la pelota está arriba salta a mover la compu hacia abajo
	jg moverJugador2Arriba 			; si la pelota está abajo salta a mover la compu hacia arriba

movJugadores: 					; Movimiento individual
	inc [tiemposJug] 				; aumenta contador del ciclo para moverse individual
	cmp [tiemposJug],10h 		 	; compara si el ciclo del jugador/jugadores se cumple 				***AJUSTABLE***
	jne checarIniciado 				; si no se cumple salta a checar si el juego ha sido iniciado
	mov [tiemposJug],0h 			; si se cumple reinicia contador
	mov ah,06h  
	mov dl,0FFh 
	int 21h 						; Int 21h con opción AH=06h y DL=FFh -> checa si se ha presionado una tecla
	jz checarIniciado 				; si no se ha presionado tecla salta a checar si el juego se ha iniciado
									; si se presionó una tecla continúa.
	cmp [individual],1 				; compara si se está en modo dos jugadores
	je par 							; si está en modo dos jugadores salta a par (mov dos jugadores)
	cmp al,72 					; flecha arriba
	je moverJugador1Arriba			; salta a mover a jugador individual hacia arriba
	cmp al,80 					; flecha abajo
	je moverJugador1Abajo 			; salta a mover a jugador individual hacia abajo
	jmp checarIniciado 				; si fue otra tecla, salta a checar si el juego ha sido iniciado
par:
	cmp al,87 					; W
	je moverJugador1Arriba 			; salta a mover a jugador 1 hacia arriba
	cmp al,119 					; w
	je moverJugador1Arriba 			; salta a mover a jugador 1 hacia arriba
	cmp al,83 					; S
	je moverJugador1Abajo 			; salta a mover a jugador 1 hacia abajo
	cmp al,115 					; s
	je moverJugador1Abajo 			; salta a mover a jugador 1 hacia abajo
	cmp al,72 					; flecha arriba
	je moverJugador2Arriba 			; salta a mover a jugador 2 hacia arriba
	cmp al,80 					; flecha abajo
	je moverJugador2Abajo 			; salta a mover a jugador 2 hacia abajo
	jmp checarIniciado 				; si fue otra tecla, salta a checar si el juego ha sido iniciado

; En los movimientos de jugadores se checa si no se han chocado contra los límites,
; luego se imprimen en su nueva posición y se borra el sobrante de la antigua.
; Finalmente brincan a checar si el juego ha sido iniciado
moverJugador1Arriba:
	cmp [p1_ren],7
	je checarIniciado
	dec [p1_ren]
	mov al,[p1_col]
	mov ah,[p1_ren]
	mov [col_aux],al
	mov [ren_aux],ah
	call IMPRIME_PLAYER
	mov al,[p1_ren]
	mov [ren_aux],al
	add [ren_aux],3d
	posiciona_cursor [ren_aux],[p1_col]
	imprime_caracter_color 219,cNegro,bgNegro
	jmp checarIniciado
moverJugador1Abajo:
	cmp [p1_ren],20
	je checarIniciado
	inc [p1_ren]
	mov al,[p1_col]
	mov ah,[p1_ren]
	mov [col_aux],al
	mov [ren_aux],ah
	call IMPRIME_PLAYER
	mov al,[p1_ren]
	mov [ren_aux],al
	sub [ren_aux],3d
	posiciona_cursor [ren_aux],[p1_col]
	imprime_caracter_color 219,cNegro,bgNegro
	jmp checarIniciado
moverJugador2Arriba:
	cmp [p2_ren],7
	je checarIniciado
	dec [p2_ren]
	mov al,[p2_col]
	mov ah,[p2_ren]
	mov [col_aux],al
	mov [ren_aux],ah
	call IMPRIME_PLAYER
	mov al,[p2_ren]
	mov [ren_aux],al
	add [ren_aux],3d
	posiciona_cursor [ren_aux],[p2_col]
	imprime_caracter_color 219,cNegro,bgNegro
	jmp checarIniciado
moverJugador2Abajo:
	cmp [p2_ren],20
	je checarIniciado
	inc [p2_ren]
	mov al,[p2_col]
	mov ah,[p2_ren]
	mov [col_aux],al
	mov [ren_aux],ah
	call IMPRIME_PLAYER
	mov al,[p2_ren]
	mov [ren_aux],al
	sub [ren_aux],3d
	posiciona_cursor [ren_aux],[p2_col]
	imprime_caracter_color 219,cNegro,bgNegro
	jmp checarIniciado
;-------------------------------------------------------------------------------------------------


; INICIACIÓN DEL JUEGO

; Checa si el juego ha iniciado
checarIniciado:
	cmp [iniciado],0
	jz logicaJuego 			; si el juego no se ha iniciado, vuelve a logicaJuego (checar botones)
	jmp seguirJuego


iniciarJuego:			; Checa el modo de juego para saber si iniciar o no el cronómetro. Si es modo tiempo, lo inicia. 
	mov [iniciado],1
	cmp [modoJuego],0
	jne saquePelota			; si el modo de juego es puntuación pasa al saque de la pelota
	
	mov ah,00h 				; Inicia datos del cronómetro.
	int 1Ah 				; Lee el valor del contador de ticks y lo guarda en variable t_inicial
	mov [t_inicial],dx
	mov [t_inicial+2],cx


saquePelota:			; Le da los parámetros iniciales a la pelota y la imprime en posición de inicio
	mov [movPelota],0
	mov [paso],0 
	mov [posX],40
	mov [posY],14
	mov [col_aux],40
	mov [ren_aux],14
	call IMPRIME_BOLA
;-------------------------------------------------------------------------------------------------


; FLUJO PRINCIPAL DEL JUEGO INICIADO

seguirJuego:
	cmp [modoJuego],0 					; checa si el modo es por tiempo
	jne puntuacion 						; si no lo es, salta a puntuación
	call CRONO 							; imprime el tiempo del cronómetro

tiempos: 						; checa si se agotó el tiempo para finalizar el juego
	cmp [minutos],0
	jne jugar
	cmp [segundos],0
	je finJuego
	jmp jugar

puntuacion: 					; checa si se llegó al máximo puntaje para finalizar el juego
	cmp [p1_score],10
	jge finJuego
	cmp [p2_score],10
	jge finJuego

jugar: 							; movimiento de la pelota
	inc [tiemposPelota] 				; aumenta contador del ciclo para mover la pelota
	cmp [individual],0 					; checa parametro individual
	je retrasoIndividual 				; si el juego es individual salta a retraso Individual
	cmp [modoJuego],0 					; checa si el modo de juego es por tiempo (y de dos jugadores)
	jne retrasoPorPuntos 				; si no es por tiempo salta a retraso por puntos

 								; Retraso para Pelota: 2 jugadores, por tiempo
	cmp [tiemposPelota],01CFh	 		; compara si el ciclo de la pelota se cumple 					***AJUSTABLE***
	jne logicaJuego
	mov [tiemposPelota],0h 				; si se cumple reinicia contador
	jmp checarLimiteHorizontal

retrasoPorPuntos:				; Retraso para Pelota: 2 jugadores, por puntos
	cmp [tiemposPelota],05FAh  			; compara si el ciclo de la pelota se cumple 					***AJUSTABLE***
	jne logicaJuego
	mov [tiemposPelota],0h 				; si se cumple reinicia contador
	jmp checarLimiteHorizontal

retrasoIndividual:				; Retraso para Pelota: 1 jugador, por tiempo
	cmp [modoJuego],0 					; checa si el modo de juego es por tiempo
	jne retrasoIndividualPuntos 		; si no es por tiempo salta a retraso individual por puntos
	cmp [tiemposPelota],019Ah 			; compara si el ciclo de la pelota se cumple 					***AJUSTABLE***
	jne logicaJuego
	mov [tiemposPelota],0h  			; si se cumple reinicia contador
	jmp checarLimiteHorizontal

retrasoIndividualPuntos: 		; Retraso para Pelota: 1 jugador, por puntos
	cmp [tiemposPelota],05AFh  			; compara si el ciclo de la pelota se cumple 					***AJUSTABLE***
	jne logicaJuego
	mov [tiemposPelota],0h  			; si se cumple reinicia contador
;-------------------------------------------------------------------------------------------------


; ; ; MOVIMIENTO DE LA PELOTA ; ; ;


; CHECAR REBOTES, CHOQUES Y GOLES DE LA PELOTA

checarLimiteHorizontal: 		; Checa si la pelota choca contra un límite horizontal.
	cmp [posY],5
	jbe rebote
	cmp [posY],22
	jge rebote

checarChoqueJugador1:			; Checar si la pelota choca contra jugador 1, y en qué parte para el rebote.
	cmp [posX],6
	jne checarChoqueJugador2
	mov al,[p1_ren]
	cmp al,[posY]
	je reboteJugador1Derecho
	inc al
	cmp al,[posY]
	je reboteJugador1MedioBajo
	inc al 
	cmp al,[posY]
	je reboteJugador1InclinadoBajo
	sub al,3 
	cmp al,[posY]
	je reboteJugador1MedioAlto
	dec al 
	cmp al,[posY]
	je reboteJugador1InclinadoAlto

checarChoqueJugador2:			; Checar si la pelota choca contra jugador 2, y en qué parte para el rebote.
	cmp [posX],73
	jne checarLimiteVertical
	mov al,[p2_ren]
	cmp al,[posY]
	je reboteJugador2Derecho
	inc al
	cmp al,[posY]
	je reboteJugador2MedioBajo
	inc al 
	cmp al,[posY]
	je reboteJugador2InclinadoBajo
	sub al,3 
	cmp al,[posY]
	je reboteJugador2MedioAlto
	dec al 
	cmp al,[posY]
	je reboteJugador2InclinadoAlto

checarLimiteVertical:			; Checar si la pelota rebasa el límite vertical (la línea de gol).
	cmp [posX],1
	jbe golP2
	cmp [posX],78
	je golP1


; MOVER LA PELOTA

cambioPosicionPelota: 			; Realiza el borrado de la pelota antigua
	posiciona_cursor [posY],[posX]
	imprime_caracter_color 219,cNegro,bgNegro		; borra la pelota
	cmp [posX],39
	jb despuesRellenar
	cmp [posX],40
	jg despuesRellenar
	imprime_caracter_color 176,cBlanco,bgNegro 		; rellena el hueco de la red si pasa pelota.

despuesRellenar: 				; Determina el tipo de movimiento para acomodar sus parámetros.
	cmp [movPelota],0
	je derecho
	cmp [movPelota],1
	je pocoInclinado
	cmp [movPelota],2
	je inclinado 
	jmp muyInclinado

imprimirPelotaNueva: 			; Imprime la nueva pelota
	mov al,[posX]
	mov [col_aux],al
	mov al,[posY]
	mov [ren_aux],al
	call IMPRIME_BOLA
	jmp logicaJuego


; ; ; LOGICA PARA ESTABLECER MOVIMIENTO DE LA PELOTA ; ; ;


; CAMBIA LA DIRECCION VERTICAL DEL MOVIMIENTO DEBIDO AL CHOQUE CON EL LÍMITE HORIZONTAL

rebote: 					; si rebota cambia la dirección vertical al lado contrario
	mov [aux_rebote],1
	cmp [gravedad],0
	je gravAbajo
	mov [gravedad],0
	jmp checarChoqueJugador1
gravAbajo:
	mov [gravedad],1
	jmp checarChoqueJugador1


; CAMBIA LA DIRECCION HORIZONTAL DEL MOVIMIENTO DEBIDO AL CHOQUE CONTRA UN JUGADOR
; (depende de con que parte del jugador se choca)

reboteJugador1Derecho: 			; movimiento casi derecho, a la derecha, en espejo
	mov [sentido],0
	mov [movPelota],0
	jmp cambioPosicionPelota
reboteJugador1MedioAlto:		; movimiento inclinado, a la derecha, hacia arriba
	cmp [posX],5
	je reboteJugador1MedioBajo
	mov [sentido],0
	mov [movPelota],1
	mov [gravedad],0
	jmp cambioPosicionPelota
reboteJugador1MedioBajo:		; movimiento inclinado, a la derecha, hacia abajo
	cmp [posX],22
	je reboteJugador1MedioAlto
	mov [sentido],0
	mov [movPelota],1
	mov [gravedad],1
	jmp cambioPosicionPelota
reboteJugador1InclinadoAlto:	; movimiento muy inclinado, a la derecha, hacia arriba
	cmp [posX],5
	je reboteJugador1InclinadoBajo
	mov [sentido],0
	mov [movPelota],2
	mov [gravedad],0
	jmp cambioPosicionPelota
reboteJugador1InclinadoBajo:	; movimiento muy inclinado, a la derecha, hacia abajo
	cmp [posX],22
	je reboteJugador1InclinadoAlto
	mov [sentido],0
	mov [movPelota],2
	mov [gravedad],1
	jmp cambioPosicionPelota
reboteJugador2Derecho:			; movimiento casi derecho, a la izquierda, en espejo
	mov [sentido],1
	mov [movPelota],0
	jmp cambioPosicionPelota
reboteJugador2MedioAlto:		; movimiento inclinado, a la izquierda, hacia arriba
	cmp [posX],5
	je reboteJugador2MedioBajo
	mov [sentido],1
	mov [movPelota],1
	mov [gravedad],0
	jmp cambioPosicionPelota
reboteJugador2MedioBajo:		; movimiento inclinado, a la izquierda, hacia abajo
	cmp [posX],22
	je reboteJugador2MedioAlto
	mov [sentido],1
	mov [movPelota],1
	mov [gravedad],1
	jmp cambioPosicionPelota
reboteJugador2InclinadoAlto:	; movimiento muy inclinado, a la izquierda, hacia arriba
	cmp [posX],5
	je reboteJugador2InclinadoBajo
	mov [sentido],1
	mov [movPelota],2
	mov [gravedad],0
	jmp cambioPosicionPelota
reboteJugador2InclinadoBajo:	; movimiento muy inclinado, a la izquierda, hacia abajo
	cmp [posX],22
	je reboteJugador2InclinadoAlto
	mov [sentido],1
	mov [movPelota],2
	mov [gravedad],1
	jmp cambioPosicionPelota


; GOOOOOOL de algún jugador, se pasa a saque de pelota.

golP1: 							; se borra la pelota vieja, se incrementa un punto a jugador 1
	inc [p1_score]
	posiciona_cursor [posY],[posX]
	imprime_caracter_color 219,cNegro,bgNegro
	mov [col_aux],3
	mov [ren_aux],2
	mov bl,[p1_score]
	call IMPRIME_SCORE_BL
	je saquePelota
golP2: 							; se borra la pelota vieja, se incrementa un punto a jugador 2
	inc [p2_score]
	posiciona_cursor [posY],[posX]
	imprime_caracter_color 219,cNegro,bgNegro
	mov [col_aux],75
	mov [ren_aux],2
	mov bl,[p2_score]
	call IMPRIME_SCORE_BL
	jmp saquePelota 


; DEFINICIÓN DEL MOVIMIENTO SEGÚN LA ETAPA (define si se mueve en Y o no)

derecho:
	cmp [paso],14 			; checa si ya se movió 14 veces en horizontal antes de moverse 1 en vertical
	jb avanceDer
	jmp alturaDer
pocoInclinado:
	cmp [paso],3 			; checa si ya se movió 3 veces en horizontal antes de moverse 1 en vertical
	jb avanceDer
	jmp alturaDer
inclinado:
	cmp [paso],1 			; checa si ya se movió 1 vez en horizontal antes de moverse 1 en vertical
	jb avanceDer
	jmp alturaDer
muyInclinado:
	jmp alturaDer


; AVANCES SIN CAMBIO EN Y

avanceDer: 					; horizontal a la derecha
	cmp [aux_rebote],1
	je alturaDer
	cmp [sentido],0
	jne avanceIzq
	inc [posX]
	inc [paso]
	jmp imprimirPelotaNueva
avanceIzq: 					; horizontal a la izquierda
	dec [posX]
	inc [paso]
	jmp imprimirPelotaNueva


; AVANCE CON CAMBIO EN Y

alturaDer: 					; inclinado DERECHA
	mov [aux_rebote],0
	cmp [sentido],0
	jne alturaIzq
	cmp [gravedad],0
	jne alturaDerBaja
alturaDerAlta: 				; inclinado hacia arriba y a la derecha
	inc [posX]
	dec [posY]
	mov [paso],0
	jmp imprimirPelotaNueva
alturaDerBaja:				; inclinado hacia abajo y a la derecha
	inc [posX]
	inc [posY]
	mov [paso],0
	jmp imprimirPelotaNueva
alturaIzq:					; inclinado IZQUIERDA
	cmp [gravedad],0
	jne alturaIzqBaja
alturaIzqAlta:				; inclinado hacia arriba y a la izquierda
	dec [posX]
	dec [posY]
	mov [paso],0
	jmp imprimirPelotaNueva
alturaIzqBaja:				; inclinado hacia abajo y a la izquierda
	dec [posX]
	inc [posY]
	mov [paso],0
	jmp imprimirPelotaNueva
;-------------------------------------------------------------------------------------------------


; FINALIZACIÓN DEL JUEGO

finJuego: 					; se acaba el juego y pasa a la pantalla de anuncio de ganador
	mov [iniciado],0
	mov [grafico],3
	jmp cambiaPantalla
;-------------------------------------------------------------------------------------------------



;-------------------------------------------------------------------------------------------------
		  			;;;;;;;;; ; ; SALIDA DEL PROGRAMA ; ; ;;;;;;;;;
;-------------------------------------------------------------------------------------------------

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


;_________________________________________________________________________________________________



;-------------------------------------------------------------------------------------------------
		  			;;;;;;;;; ; ; PROCEDIMIENTOS ; ; ;;;;;;;;;
;-------------------------------------------------------------------------------------------------

	; DIBUJA_INICIO_MODO - Dibuja la interfaz gráfica del INICIO/MODO sin las decoraciones, detalles y textos específicos.
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
;-------------------------------------------------------------------------------------------------

	; IMPRIME_DECO_INICIO - imprime en la pantalla de INICIO/MODO los detalles específicos de Inicio.
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
;-------------------------------------------------------------------------------------------------

	; IMPRIME_TEXTOS_INICIO - se encarga de imprimir los textos necesarios de la pantalla de INICIO
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
;-------------------------------------------------------------------------------------------------
	; IMPRIME_DECO_MODO - imprime en la pantalla de INICIO/MODO los detalles específicos de Modo.
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
;-------------------------------------------------------------------------------------------------

	; IMPRIME_TEXTOS_MODO - se encarga de imprimir los textos necesarios de la pantalla de Modo de Juego
	IMPRIME_TEXTOS_MODO proc
		posiciona_cursor 22,3
		imprime_cadena_color creador,36,cBlanco,bgNegro
		cmp [individual],1
		je mensaje_dos
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
;-------------------------------------------------------------------------------------------------

	; DIBUJA_JUEGO - Dibuja la interfaz gráfica del juego sin los mensajes o datos.
	DIBUJA_JUEGO proc
		;imprimir esquinas
		;imprimir esquina superior izquierda del marco
		posiciona_cursor 0,0
		imprime_caracter_color 177,cMagenta,bgNegro
		
		;imprimir esquina superior derecha del marco
		posiciona_cursor 0,79
		imprime_caracter_color 177,cMagenta,bgNegro
		
		;imprimir esquina inferior izquierda del marco
		posiciona_cursor 23,0
		imprime_caracter_color marcoEsqInfIzq,cMagenta,bgNegro
		
		;imprimir esquina inferior derecha del marco
		posiciona_cursor 23,79
		imprime_caracter_color marcoEsqInfDer,cMagenta,bgNegro
		
		;imprimir marcos horizontales, superior e inferior
		mov cx,78 		;CX = 004Eh => CH = 00h, CL = 4Eh
	marcos_horizontales:
		mov [col_aux],cl
		;Superior
		posiciona_cursor 0,[col_aux]
		imprime_caracter_color 176,cMagenta,bgNegro
		;Inferior
		posiciona_cursor 23,[col_aux]
		imprime_caracter_color marcoHor,cMagenta,bgNegro
		;Limite mouse
		posiciona_cursor 4,[col_aux]
		imprime_caracter_color marcoHor,cMagenta,bgNegro
		mov cl,[col_aux]
		loop marcos_horizontales

		;imprimir marcos verticales, derecho e izquierdo
		mov cx,22 		;CX = 0017h => CH = 00h, CL = 17h 
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

		;imprime instrucciones
		cmp [individual],0
		jne pareja
		posiciona_cursor 24,26
		imprime_cadena_color [teclas1],33,cGrisClaro,bgNegro
		jmp mitad
	pareja:
		posiciona_cursor 24,3
		imprime_cadena_color [teclas2],75,cGrisClaro,bgNegro
	mitad:
		;imprimir mitad
		posiciona_cursor 5,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 5,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 6,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 6,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 7,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 7,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 8,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 8,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 9,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 9,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 10,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 10,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 11,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 11,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 12,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 12,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 13,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 13,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 14,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 14,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 15,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 15,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 16,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 16,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 17,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 17,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 18,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 18,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 19,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 19,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 20,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 20,40
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

	; IMPRIME_DATOS_INICIALES - se encarga de imprimir en la interfaz del juego los datos iniciales según el modo de juego.
	IMPRIME_DATOS_INICIALES proc
		;inicializa la cadena del timer
		mov [tiempo_cadena],"2"
		mov [tiempo_cadena+1],":"
		mov [tiempo_cadena+2],"0"
		mov [tiempo_cadena+3],"0"
		
		mov [p1_score],0 			;inicializa el score del player 1
		mov [p2_score],0 			;inicializa el score del player 2

		;Imprime el score del player 1, en la posición del col_aux
		;la posición de ren_aux está fija en IMPRIME_SCORE_BL
		mov [col_aux],3
		mov [ren_aux],2
		mov bl,[p1_score]
		call IMPRIME_SCORE_BL

		;Imprime el score del player 1, en la posición del col_aux
		;la posición de ren_aux está fija en IMPRIME_SCORE_BL
		mov [col_aux],75
		mov [ren_aux],2
		mov bl,[p2_score]
		call IMPRIME_SCORE_BL

		;imprime cadena 'Player 1'
		posiciona_cursor 2,9
		imprime_cadena_color jugador1,9,cBlanco,bgNegro
		
		;imprime cadena 'Player 2'
		posiciona_cursor 2,62
		imprime_cadena_color jugador2,9,cBlanco,bgNegro

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
		mov [botonChar],254d
		mov [boton_color],bgCyan
		mov [boton_renglon],1
		mov [boton_columna],34
		call IMPRIME_BOTON

		;Botón Start
		mov [botonChar],16d
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
		posiciona_cursor [ren_aux],[col_aux]
		pop dx
		or dl,30h
		imprime_caracter_color dl,cBlanco,bgNegro
		inc [col_aux]
		dec [conta]
		cmp [conta],0
		ja imprime_digito
		ret
	endp
;-------------------------------------------------------------------------------------------------

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
;-------------------------------------------------------------------------------------------------

	;procedimiento IMPRIME_BOTON
	;Dibuja un boton que abarca 3 renglones y 3 columnas
	;con un caracter centrado dentro del boton
	;en la posición que se especifique (esquina superior izquierda)
	;y de un color especificado
	;Utiliza paso de parametros por variables globales
	;Las variables utilizadas son:
	;botonChar: debe contener el caracter que va a mostrar el boton
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
		imprime_caracter_color [botonChar],bh,[boton_color]
	 	ret 			;Regreso de llamada a procedimiento
	endp	 			;Indica fin de procedimiento UI para el ensamblador
;-------------------------------------------------------------------------------------------------

	; DIBUJA_GANADOR - imprime en pantalla la interfaz que contiene el mensaje del jugador ganador.
	DIBUJA_GANADOR proc
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
	marcos_horizontales_ganador:
		mov [col_aux],cl
		;Superior
		posiciona_cursor 0,[col_aux]
		imprime_caracter_color 176,cMagenta,bgNegro
		;Inferior
		posiciona_cursor 24,[col_aux]
		imprime_caracter_color marcoHor,cMagenta,bgNegro
		mov cl,[col_aux]
		loop marcos_horizontales_ganador

		;imprimir marcos verticales, derecho e izquierdo
		mov cx,23 		;CX = 0017h => CH = 00h, CL = 17h 
	marcos_verticales_ganador:
		mov [ren_aux],cl
		;Izquierdo
		posiciona_cursor [ren_aux],0
		imprime_caracter_color marcoVer,cMagenta,bgNegro
		;Derecho
		posiciona_cursor [ren_aux],79
		imprime_caracter_color marcoVer,cMagenta,bgNegro
		mov cl,[ren_aux]
		loop marcos_verticales_ganador

		;centro para mensajes
		mov cx,24
	cuadroGanador1:
		mov [col_aux],cl
		add [col_aux],27d
		posiciona_cursor 7,[col_aux]
		imprime_caracter_color 219,cGrisOscuro,bgNegro
		posiciona_cursor 8,[col_aux]
		imprime_caracter_color 219,cGrisOscuro,bgNegro
		posiciona_cursor 9,[col_aux]
		imprime_caracter_color 219,cGrisOscuro,bgNegro
		posiciona_cursor 10,[col_aux]
		imprime_caracter_color 219,cGrisOscuro,bgNegro
		posiciona_cursor 11,[col_aux]
		imprime_caracter_color 219,cGrisOscuro,bgNegro
		posiciona_cursor 12,[col_aux]
		imprime_caracter_color 219,cGrisOscuro,bgNegro
		sub [col_aux],27d
		mov cl,[col_aux]
		dec cl
		cmp cx,0
		jnz cuadroGanador1
		mov cx,24
	cuadroGanador2:
		mov [col_aux],cl
		add [col_aux],27d
		posiciona_cursor 13,[col_aux]
		imprime_caracter_color 219,cGrisOscuro,bgNegro
		posiciona_cursor 14,[col_aux]
		imprime_caracter_color 219,cAzulClaro,bgNegro
		posiciona_cursor 15,[col_aux]
		imprime_caracter_color 219,cAzulClaro,bgNegro
		posiciona_cursor 16,[col_aux]
		imprime_caracter_color 219,cAzulClaro,bgNegro
		posiciona_cursor 17,[col_aux]
		imprime_caracter_color 219,cGrisOscuro,bgNegro
		sub [col_aux],27d
		mov cl,[col_aux]
		dec cl
		cmp cx,0
		jnz cuadroGanador2

		;definido botones
		posiciona_cursor 14,28
		imprime_caracter_color 219,cGrisOscuro,bgNegro
		posiciona_cursor 15,28
		imprime_caracter_color 219,cGrisOscuro,bgNegro
		posiciona_cursor 16,28
		imprime_caracter_color 219,cGrisOscuro,bgNegro
		posiciona_cursor 14,39
		imprime_caracter_color 219,cGrisOscuro,bgNegro
		posiciona_cursor 15,39
		imprime_caracter_color 219,cGrisOscuro,bgNegro
		posiciona_cursor 16,39
		imprime_caracter_color 219,cGrisOscuro,bgNegro
		posiciona_cursor 14,40
		imprime_caracter_color 219,cGrisOscuro,bgNegro
		posiciona_cursor 15,40
		imprime_caracter_color 219,cGrisOscuro,bgNegro
		posiciona_cursor 16,40
		imprime_caracter_color 219,cGrisOscuro,bgNegro
		posiciona_cursor 14,51
		imprime_caracter_color 219,cGrisOscuro,bgNegro
		posiciona_cursor 15,51
		imprime_caracter_color 219,cGrisOscuro,bgNegro
		posiciona_cursor 16,51
		imprime_caracter_color 219,cGrisOscuro,bgNegro

		;imprimir título
		posiciona_cursor 0,38
		imprime_cadena_color [titulo],4,cBlanco,bgNegro
		
		;imprimir mitad
		posiciona_cursor 1,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 1,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 2,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 2,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 5,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 5,40
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 6,39
		imprime_caracter_color 176,cBlanco,bgNegro
		posiciona_cursor 6,40
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

		;impresion textos fijos
		posiciona_cursor 8,29
		imprime_cadena_color [jugador1],9,cBlanco,bgGrisOscuro
		posiciona_cursor 8,38
		imprime_caracter_color 58,cBlanco,bgGrisOscuro
		posiciona_cursor 8,44
		imprime_cadena_color [puntos],6,cBlanco,bgGrisOscuro
		posiciona_cursor 10,29
		imprime_cadena_color [jugador2],9,cBlanco,bgGrisOscuro
		posiciona_cursor 10,38
		imprime_caracter_color 58,cBlanco,bgGrisOscuro
		posiciona_cursor 10,44
		imprime_cadena_color [puntos],6,cBlanco,bgGrisOscuro
		posiciona_cursor 15,30
		imprime_cadena_color [reiniciar],9,cBlanco,bgAzulClaro
		posiciona_cursor 15,44
		imprime_cadena_color [menu],4,cBlanco,bgAzulClaro
		;impresion puntajes
		mov [col_aux],40
		mov [ren_aux],8
		mov bl,[p1_score]
		call IMPRIME_SCORE_BL
		mov [col_aux],40
		mov [ren_aux],10
		mov bl,[p2_score]
		call IMPRIME_SCORE_BL
		;impresion ganador
		mov al,[p2_score]
		cmp [p1_score],al
		je mensajeEmpate
		posiciona_cursor 12,29
		imprime_cadena_color [ganador],22,cNegro,bgBlanco
		mov al,[p2_score]
		cmp [p1_score],al
		jg p1ganador
		posiciona_cursor 12,39
		imprime_cadena_color [jugador2],9,cNegro,bgBlanco
		jmp finImpGan
	mensajeEmpate:
		posiciona_cursor 12,36
		imprime_cadena_color [empate],8,cNegro,bgBlanco
		jmp finImpGan
	p1ganador:
		posiciona_cursor 12,39
		imprime_cadena_color [jugador1],9,cNegro,bgBlanco
	finImpGan:
		ret
	endp
;-------------------------------------------------------------------------------------------------

	; CRONO - calcula e imprime el cronometro del tiempo de juego, el cual avanza en reversa desde 2:00 hasta 0:00.
	CRONO proc

	    MOV AH, 0Dh
	    INT 21H					;flushes all file buffers

		;Se vuelve a leer el contador de ticks
		;Se lee para saber cuántos ticks pasaron entre la lectura inicial y ésta
		;De esa forma, se obtiene la diferencia de ticks
		;por cada incremento en el contador de ticks, transcurrieron 55 ms
		mov ah,00h
		int 1Ah

		;Se recupera el valor de los ticks iniciales para poder hacer la diferencia entre
		;el valor inicial y el último recuperado
		mov ax,[t_inicial]		;AX = parte baja de t_inicial
		mov bx,[t_inicial+2]	;BX = parte alta de t_inicial
		
		;Se hace la resta de los valores para obtener la diferencia
		sub dx,ax  				;DX = DX - AX = t_final - t_inicial, DX guarda la parte baja del contador de ticks
		sbb cx,bx 				;CX = CX - BX - C = t_final - t_inicial - C, CX guarda la parte alta del contador de ticks y se resta el acarreo si hubo en la resta anterior

		;Se asume que el valor de CX es cronómetro
		;Significaría que la diferencia de ticks no es mayor a 65535d
		;Si la diferencia está entre 0d y 65535d, significa que hay un máximo de 65535 * 55ms =  3,604,425 milisegundos
		mov ax,dx

		;Se multiplica la diferencia de ticks por 55ms para obtener 
		;la diferencia en milisegundos
		mul [tick_ms]

		;El valor anterior se divide entre 1000 para calcular la cantidad de segundos 
		;y la cantidad de milisegundos del cronómetro (0d - 999d)
		div [mil]
		;Después de esta división, el cociente AX guarda el valor de segundos
		;el residuo DX tiene la cantidad de milisegundos del cronómetro (0- 999d)
		
		mov [tiempo_aux],120
		sub [tiempo_aux],al 
		; [tiempo_aux] tiene el total de segundos
		mov ax,0
		mov al,[tiempo_aux]
		div [sesenta]
		; ah-segundos(0-59), al-minutos(>=0)
		mov [segundos],ah
		mov [minutos],al
		mov [tiempo_aux],al 
		add [tiempo_aux],48d

	;A continuación, se tomarán los valores de las variables minutos, segundos
	;y se imprimirán en formato de M:SS
		
	;Imprime minutos
		posiciona_cursor 2,38 
		imprime_caracter_color [tiempo_aux],cBlanco,bgNegro
	;Separador ':'
		posiciona_cursor 2,39
		imprime_caracter_color ':',cBlanco,bgNegro
	;Imprime segundos
		xor ah,ah
		mov al,[segundos]
		mov [tiempo_aux2],al
		aam
		or ax,3030h
		mov [segundos],al
		mov [tiempo_aux],ah
	;decenas
		posiciona_cursor 2,40
		imprime_caracter_color [tiempo_aux],cBlanco,bgNegro
	;unidades
		posiciona_cursor 2,41
		imprime_caracter_color [segundos],cBlanco,bgNegro
		mov al,[tiempo_aux2]
		mov [segundos],al

		MOV AX, 0D00h
	    INT 21H

		ret
	crono endp
;-------------------------------------------------------------------------------------------------



	end inicio			;fin de etiqueta inicio, fin de programa
;_________________________________________________________________________________________________