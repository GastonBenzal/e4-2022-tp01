 	.cpu cortex-m3
 	.syntax unified
	.thumb

	.set		MASCARA, 0x0F //defino a mascara como ese numero igual al binario 00001111 que nos permitirá solo utilizar la parte baja

 	.bss						// Define a RAM section
		BINHex:  .space 1				// defino espacio en ram de 1 byte de tamaño donde esta el dato hex a convertir
		BINAsc:  .space 1				// defino espacio en ram de 1 byte de tamaño para la salida del dato en codigo ASCII procesado

  .section .text				// Define a code section
  .global  mainS				// defino donde empieza el programa principal mediante la etiqueta mainS

Puntero_base .req	R2 //R2 se llama ahora puntero_base

mainS:
	LDR		Puntero_base, = BINHex //cargo en R2 la direccion de memoria de BINHex
	MOV		R1, #0x2A //cargo ese valor en r1
	STRB	R1,[Puntero_base]	// carga 0x2A en BINHex, de cual solo me importa convertir la A a ascii 

	BL		ConvAscii			@ llama rutina, debe devolver en BINAsc "A"
	B		. //aca finaliza el programa

ConvAscii:
	AND		R1,#MASCARA				// hace un AND entre el byte guardado en R1 y el 00001111, es decir solo tiene en cuenta los 4 bits bajos

	LDR		Puntero_base, = T_ascii // cargo en R2 la direccion de memoria donde empieza la tabla T_ascii
	LDRB	R3,[Puntero_base,R1]	// cargo en R3 lo que hay en [puntero_base] sumado 10 posiciones(valor de R1)

	LDR		Puntero_base, = BINAsc //guardo la direc de memoria de BINasc en R2
	STR		R3,[Puntero_base]		// guarda resultado ascii en BINAsc

	BX		LR						// retorna a la linea siguiente a la ultima que se ejecuto en el programa principal

  .pool								// Place literal pool (constants) para guardan en memoria flash

T_ascii: .asciz "0123456789ABCDEF"	// tabla para convertir
//.asciz convierte cada uno de los elementos del vector al formato ascii y los guarda en la tabla  
  .align
Constantes:
  .word  0x40
  .end								@ Mark the end of a program
