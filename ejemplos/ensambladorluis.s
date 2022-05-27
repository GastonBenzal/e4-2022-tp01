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

    //Esto use al principio pero cambiamos para lo otro para que quede mejor
    //tst R2, #(-1) //El -1 es 11111111... entonces lo que hacemos AND R2 con 11111..
    //beq 0f //si longitud es 0 no hago nada
1:
    cbz R2, 0f //cbz compara el registro si es 0, ahora vemos si R2 es 0 y si se cumple salta a 1
    
    ldrb R3 ,[R0],#1 //Llevamos lo que esta en la direccion de  memoria a la que apunta Ro a R3
    strb R3,[R1],#1 //Guardamos el registro R3 en la direccion de memoria a la que apunta R1
    subs R2 ,R2,#1 //Guardo R2=R2-1 y afecto la bandera para saltar cuando sea necesario
    bne 1b //se puede usar cbz r2, 1b
0:
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
0:
    cmp     R2,#0
    beq     2f

    ldrb    R2,[R0],#1
    mov     R3,R2
    bics    R3,0x0F
    cmp     R3,0x60
    beq     1f
    subs    R2,#1
    b       0b
1:
    bics    R2,0xF0
    orr     R2,0x40
    subs    R0,#1
    strb    R2,[R0]
    b       0b
2:
    bx      lr
endfun mayusculaEnLugar

defun minusculaEnLugar
    // Implementación aquí
    // R0: cadena, R1: longitudMaxima
0:
    cmp     R2,#0
    beq     2f

    ldrb    R2,[R0],#1
    mov     R3,R2
    bics    R3,0x0F
    cmp     R3,0x40
    beq     1f
    subs    R2,#1
    b       0b
1:
    bics    R2,0xF0
    orr     R2,0x60
    subs    R0,#1
    strb    R2,[R0]
    b       0b
2:
    bx      lr
endfun minusculaEnLugar