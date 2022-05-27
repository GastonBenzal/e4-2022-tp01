/*Programe una rutina __asm (en línea en un programa en C) que copie 16 datos consecutivos
de tipo byte. Los datos de origen se encuentran en la RAM, a partir de la posición
0x20000010 y se deben copiar a la posición 0x20000020.*/

 	.cpu cortex-m3
 	.syntax unified
	.thumb

.set origen,  0x20000010  //direccion base de datos a copiar
.set destino, 0x20000020  //direccion base de datos a copiar
//como no se tienen definidos los datos, los inicializo en cero
  .section .text				// Define a code section
  .global  mainS				// defino donde empieza el programa principal mediante la etiqueta mainS


mainS:
	ldr		R0, = origen        //cargo en R0 la direccion de memoria base de los datos a copiar
	ldr		R1, = destino       //cargo en R0 la direccion de memoria base donde seran copiados los datos
	mov     R3, #16
0:
    ldrb    R2 , [R0], #1
    strb    R2 , [R1], #1
    subs    R3 , #1
	beq     0b
	B		.                   //aca finaliza el programa

.end								@ Mark the end of a program
