/**
 * Referencias importantes:
 * https://developer.arm.com/documentation/dui0552/a
 * https://github.com/ARM-software/abi-aa/tree/main/aapcs32
 */
.syntax unified
.cpu cortex-m3
.fpu softvfp
.thumb

.macro defun nombre
    .section .text.\nombre
    .global \nombre
    .type \nombre, %function
\nombre:
.endm

.macro endfun nombre
    .size \nombre, . - \nombre
.endm

defun copiaMemoria
    // Implementación aquí
    // R0: origen, R1: destino, R2: longitud
0:
    cbz R2, 1f

    ldrb R3, [R0],#1
    strb R3, [R1],#1 //Guardé en un registro un byte de la memoria y "movi" el cursor al proximo byte y luego lo cargue en R1.
    subs R2,R2,#1 //Cuando la resta sea igual a 0, entonces ya se habrá recorrido toda la memoria y deberia terminar.
    bne 0b
1:
    bx lr
endfun copiaMemoria

defun copiaCadena
    // Implementación aquí
    // R0: origen, R1: destino, R2: longitudMaxima
    //R4 longitud actual
    push {R4,LR} //guarda valores de lr y r4 para recuperarlos con el pop
    mov R4 , #0x01 //copia en r4 el valor hexadecimal 01 que sirve como contador de longitud de cadena que aumenta hasta llegar al valor de R2
0:
    cbz R2, 0f //compara la longitud r2 con cero y si es cero pasa a la siguiente etiqueta 0: con 0f
    ldrb R3,[R0],#1 //copio en r3 un byte [r1] y luego posincremento para copiar el siguiente byte de la memoria
    cmp R3 , #0x00
    beq 0f
    cmp R4, R2 //compara la longitud actual R4 de la cadena cadena copiada con la longitud maxima R2
    beq 0f //si las longitudes son iguales, ya termine de copiar cadena y salto a 0f
    strb R3,[R1],#1 //escribo r3 en [r1] y luego posincremento para escribir el siguiente caracter en [r1]
    add R4,R4,#1 //sumo 1 a r4
    b 0b
0:
    mov R3, #0x00 //copio a r3 como ultimo caracter el valor del terminador nulo
    strb R3, [R1] //copio el terminador nulo al final de la cadena guardada en [r1]
    pop {R4,PC} //recupero el valor de r4 y el de lr se copia en pc para ejecutar la instruccion que corresponda al terminar esta rutina
endfun copiaCadena

defun mayusculaEnLugar
    // Implementación aquí
    // R0: cadena, R1: longitudMaxima
    push {R1, LR}
    cbz R1, final2

programa:
    ldrb R2, [R0], #1
    //cbz R3, final (perguntar si es lo mismo que lo de abajo)
    cmp R2, #0x00
    beq final
    cmp R2, #97 //preguntar si asi o 0x61, chequeo si codigo ascii es menor que mayusculas
    blt longitud //salto a longitud, donde se resta 1 a r1 para llevar la cuenta de la longitud de la cadena
    cmp R2, #122 //preguntar si asi o 0x7A, chequeo si codigo ascii es mayor que mayusculas
    bgt longitud

    sub R2, #32
    sub R0, #1
    strb R2, [R0], #1

longitud:
    subs R1, #1
    beq final //si la longitud llega a cero, finaliza la conversión de la cadena
    bl programa

final:
    pop {R1, PC}
    bx lr
endfun mayusculaEnLugar

defun minusculaEnLugar
    // Implementación aquí
    // R0: cadena, R1: longitudMaxima
    push {R1, LR}
    cbz R1, final

programa2:
    ldrb R2, [R0], #1
    cmp R2, #0x00
    beq final2
    cmp R2, #65 //preguntar si asi o 0x41, chequeo si codigo ascii es menor que minusculas
    blt longitud2 //salto a longitud, donde se resta 1 a r1 para llevar la cuenta de la longitud de la cadena
    cmp R2, #90 //preguntar si asi o 0x5A, chequeo si codigo ascii es mayor que minusculas
    bgt longitud2

    add R2, #32
    sub R0, #1
    strb R2, [R0], #1

longitud2:
    subs R1, #1
    beq final2 //si la longitud llega a cero, finaliza la conversión de la cadena
    bl programa2

final2:
    pop {R1, PC}
    bx lr
endfun minusculaEnLugar


