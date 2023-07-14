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

; (5,1)
;       (23,78)

; jugadores están en (x,6) - (x,73)
saque 			db 		0 		; 0-hacia derecha, 1-hacia izquierda
movPelota 		db 		0 		; 0-casi derecho, 1-poco inclinado, 2-inclinado, 3-muy inclinado
gravedad 		db 		0 		; 0-hacia arriba, 1-hacia abajo
sentido 		db 		0 		; 0-hacia derecha, 1-hacia izquierda
paso 			db 		0 		; variable para definir pasos del movimiento
posX			db 		0 		; posicion en X
posY 			db 		0 		; posicion en Y

;posiciona_cursor - Cambia la posición del cursor a la especificada con 'renglon' y 'columna' 
posiciona_cursor macro renglon,columna
	mov dh,renglon	;dh = renglon
	mov dl,columna	;dl = columna
	mov bx,0
	mov ax,0200h 	;preparar ax para interrupcion, opcion 02h
	int 10h 		;interrupcion 10h y opcion 02h. Cambia posicion del cursor
endm 
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

;procedimiento IMPRIME_BOLA
;Imprime el carácter ☻ (02h en ASCII) en la posición indicada por 
;las variables globales
;ren_aux y col_aux
IMPRIME_BOLA proc
	posiciona_cursor [ren_aux],[col_aux]
	imprime_caracter_color 2d,cCyanClaro,bgNegro 
	ret
endp

checarLimiteHorizontal:
	cmp [posX],5
	je rebote
	cmp [posX],22
	je rebote
checarLimiteVertical:
	cmp [posY],1
	je golP2
	cmp [posY],78
	je golP1
cambioPosicionPelota:
	posiciona_cursor [posY],[posX]
	imprime_caracter_color 219,cNegro,bgNegro		;borra la pelota
	cmp [movPelota],0
	je derecho
	cmp [movPelota],1
	je pocoInclinado
	cmp [movPelota],2
	je inclinado 
	jmp muyInclinado
imprimirPelotaNueva:
	mov ax,[posX]
	mov [ren_aux],ax
	mov ax,[posY]
	mov [col_aux],ax 
	IMPRIME_BOLA


derecho:
	cmp [paso],14
	jb avanceDer
	jmp alturaDer

pocoInclinado:
	cmp [paso],3
	jb avanceDer
	jmp alturaDer

inclinado:
	cmp [paso],1
	jb avanceDer
	jmp alturaDer

muyInclinado:
	jmp alturaDer


avanceDer:
	cmp [sentido],0 	; 0-derecha
	jne avanceIzq
	inc [posX]
	inc [paso]
	jmp imprimirPelotaNueva 	; ->
avanceIzq:
	dec [posX]
	inc [paso]
	jmp imprimirPelotaNueva		; <-


alturaDer:
	cmp [sentido],0 	; 0-derecha
	jne alturaIzq
	cmp [gravedad],0 	; 0-hacia arriba
	jne alturaDerBaja
alturaDerAlta:
	inc [posX]
	inc [posY]
	mov [paso],0
	jmp imprimirPelotaNueva 	; />
alturaDerBaja:
	inc [posX]
	dec [posY]
	mov [paso],0
	jmp imprimirPelotaNueva		;\>
alturaIzq:
	cmp [gravedad],0 	; 0-hacia arriba
	jne alturaIzqBaja
alturaIzqAlta:
	dec [posX]
	inc [posY]
	mov [paso],0
	jmp imprimirPelotaNueva 	; <\
alturaIzqBaja:
	dec [posX]
	dec [posY]
	mov [paso],0
	jmp imprimirPelotaNueva		; </
	

rebote:
	cmp [gravedad],0
	je gravAbajo
	mov [gravedad],0
	jmp checarLimiteVertical
gravAbajo:
	mov [gravedad],1
	jmp checarLimiteVertical

golP1:
	inc [p1_score]
	posiciona_cursor [posY],[posX]
	imprime_caracter_color 219,cNegro,bgNegro		;borra la pelota
	je saque
golP2:
	inc [p2_score]
	imprime_caracter_color 219,cNegro,bgNegro		;borra la pelota
	jmp saque
	


