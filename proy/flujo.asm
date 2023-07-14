

mouse:
	lee_mouse
	test bx,0001h
	jz mouse

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


salir:
	cmp dx,0 
	jnz unJugador
	cmp cx,76
	jb mouse
	cmp cx,78
	jg mouse
	jmp salida

unJugador:
	cmp dx,11
	jb mouse
	cmp dx,13
	jg dosJugador
	cmp cx,32
	jb mouse
	cmp cx,47
	jg mouse
	mov variable que indica selección de un sólo jugador 
	jmp modo

dosJugador:
	cmp dx,15
	jb mouse
	cmp dx,17
	jg botonSalir
	cmp cx,32
	jb mouse
	cmp cx,47
	jg mouse
	mov variable que indica selección de un sólo jugador 
	jmp modo

botonSalir:
	cmp dx,20
	jb mouse
	cmp dx,22
	jg mouse
	cmp cx,66
	jb mouse
	cmp cx,72
	jg mouse
	jmp salida

modo:
	DIBUJAR LA PANTALLA
mouseModo:
	lee mouse
	test bx,0001h
	jz mouseModo

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

salirModo:
	cmp dx,0 
	jnz tiempo
	cmp cx,76
	jb mouseModo
	cmp cx,78
	jg mouseModo
	jmp salida

tiempo: 
	cmp dx,12
	jb mouseModo
	cmp dx,14
	jg regresar
	cmp cx,15
	jb mouseModo
	cmp cx,30
	jg puntos
	mov Varialbe que indica que se seleccionó el modo tiempo
	jmp juego

puntos:
	cmp cx,49
	jb mouseModo
	cmp cx,64
	jg mouseModo
	mov Variable que indica que se seleccionó el modo PUNTOS
	jmp juego

regresar:

juego:

salida:
	; AQUI SE SALE DEL PROGRAMA