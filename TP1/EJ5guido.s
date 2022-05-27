/*Realizar un programa que detecte un flanco ascendente en el pin PB10 (configure
como entrada ese pin). Cuando se detecte el flanco, se debe encender el led en el pin
PC13, por 200ms. Se considera que en el pin PB10, ingresan señales de mas de
0.5Hz./

//Los .algo se llaman directivas

.syntax unified     //sintaxis unificada
.cpu cortex-m3      //especifico el micro
.fpu softvfp        //para las operaciones de coma flotante
.thumb              //habilita instrucciones de 16 y 32 bits

/*.data
//reservamos aca espacios de memoria RAM inicializada en valores específicos
.bss
//reservamos aca espacios de memoria RAM inicializada en cero/

.section .text.main     //permite crear una seccion de codigo particular para cada funcion
.global main            //se utiliza para que la funcion main sea visible desde fuera así se pueda llamar fuera de este archivo .s. Se vuelve un símbolo global
.type main, %funcion    //notacion que dice que dentro de main hay codigo y no datos
main:
    //configurar puertos
    bl configura_puertos
    //lazo infinito


//defino rutina de bucle infinito para cuando no se hace nada
idle:
    wfi //pone el micro en bajo consumo
    b idle

.size main, . - main //una vez terminado codigo asigna el espacio de memoria para esas instrucciones 

.text //creo seccion donde va aestar una parte del codigo
configura_puertos:
*/

 .thumb
 	.syntax unified

	//.equ		MASCARA, 0x0F
	.equ		GPIO_A,  0x40010800
	.equ		GPIO_B,  GPIO_A + 0x400
	.equ		GPIO_C,  GPIO_B + 0x400

	.equ		CRL, 0x00 //configura parte parte baja de los pines
	.equ		CRH, 0x04 //config pines altos
	.equ		IDR, 0x08 //chequeo el estado de la entrada
	.equ		ODR, 0x0C //chequeo estado de salida
	.equ		BSRR, 0x10//pone en 1 un bit
	.equ		BRR, 0x14 //resetea un bit(lo pone a cero)

 	.bss						@ Define a RAM section
//BINHex:  .space 1				@ entra_ numero binario a convertir
//BINAsc:  .space 1				@ salida_ dato en codigo ASCII procesado

  .section .text				@ Define a code section
  .global  mainS				@ Make mainS visible to the linker


mainS:
	LDR	R0, =GPIO_B
	LDR R1, =#( (0B0100) << (4* (10-8)) ) //0B0100 pone en modo entrada digital al ping
	//-8 viene de  que el pin sea de la parte alta(8 al 15) de PB , 10 por ser el pin 10, multplico por 4 y obtengo el pin que quiero elegir
	STR R1,[R0, #CRH] //escribo en la direccion de memoria de gpioB con el offset CRH para configurar los pines altos 

	LDR R2, =GPIO_C
	MOV R4, #1<<13 //guardo un 1 en la posicion 13 de R4
	//LDR R4, =# ( (0B0001)<< (4*(13-8)))
	//STR R4, [R2,#CRH]

//	BL 0
	BL LUCES
	B .


0:
	LDR R3, [R0,#IDR] //leo las entradas de gpioB
	//ANDS R3, #1<<10
	TST R3, #1<<10 //hago un and que solo afecte flag entre R3 y la posicion 10
	BNE 0
1:
	LDR R3, [R0,#IDR]
	//ANDS R3, #1<<10
	TST R3, #1<<10
	BEQ 1
	BX LR

LUCES:

	STR	R4, [R2,#BRR]   // apartir de aqui, codigo para que prenda y que apaga el led por 150 ms

	//STR R4, [R2,#BRR]

	MOV R5, #5 //bucles de delay ciclos terminan siendo 150ms

DELAY:
	SUBS R5,#1
	BNE DELAY
	//STR	R4, [R2,#BSRR]
	STR R4, [R2,#BSRR]

	B LUCES

  .pool								@ Place literal pool (constants)
//T_ascii: .asciz "0123456789ABCDEF"	@ tabla para convertir
  .align
Constantes:
 .word  0x40
  .end								@ Mark the end of a program

