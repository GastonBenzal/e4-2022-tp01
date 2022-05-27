//Lopez Luque,Martin Eduardo
    
    .cpu cortex-m4              // Indica el procesador de destino  
    .syntax unified             // Habilita las instrucciones Thumb-2
    .thumb                      // Usar instrucciones Thumb y no ARM

    .section .data
    valores_separados:
            .space  4,0x00 //4 bytes inicializados en 0

    valor_fecha: 
            .byte 9,25  //mes,dias

    tabla7seg:  .byte 0xFC,0X60,0xDA,0xF2,0x66  //de 0 a 4
                .byte 0xB6,0xBE,0x30,0xFE,0xF6  //de 5 a 9    


    .section .text          // Define la sección de código (FLASH)
    .global reset           // Define el punto de entrada del código

reset:

    
lazo:

////////////////////////
    ldr   r0,=valor_fecha // el = pasa la direccion de memoria de valor_fecha para que se cargue en r0
    bl    fecha //bl salta a la rutina fecha

     B    final             // salta al final

final:
stop:
    B stop
.align
.pool

///////////////////
fecha:
       push   {lr,r4} // guarda en pila en una posicion de memoria el valor de r4 y lr(lr para saber la instruccion siguiente al retomar)

       ldr    r1,=valores_separados //cargo la direccion de memoria de valores separados
       bl     conversion //salto a la rutina conversion
       ldr    r1,=tabla7seg
       bl     segmentos

       pop    {pc,r4} //pc va a ser el valor que se almaceno de lr y por eso seguira a la siguiente intrucción
///////////////////
conversion:
    push   {lr}
    ldrb     r2,[r0] // carga 8bits de la posicion de memoria a la que apunta r0 y lo carga a r2. entre corchetes es direccion de memoria a la que apunta el registro
    mov     r3,#0 //constante se escribe con numeral. mov escribe r3 con 0
decena:
    subs    r2,r2,#10 //resta d10 a la decena y guarda el resultado, sub no afecta flag, subs si
    bmi     escape //se fija si la flag es negativa y si es asi sale a escape. b(salto)mi(bandera negativa) realiza el salto si la flag es negativa
    add     r3,r3,#1 //suma uno al contador de decenas en r3
    b      decena       
escape:
    add     r2,r2,#10 //vuelva a sumar d10 a r2
    mov     r0,#0
unidad:
    subs    r2,r2,#1
    bmi     cont
    add     r0,r0,#1
    b       unidad     
cont:
    strb    r3,[r1] //guardo en la posicion de memoria a la que apunta r1 el valor de r3
    strb    r0,[r1,#1] //guardo r0 en la posicion de memoria a la que apunta r1 pero un byte despues
    pop    {pc}
///////////////////
segmentos:
       push   {lr}
       ldrb   r0,[r1,r0] //carga el segundo byte(usando r0 que representa cantidad de unidades) de r1 en r0
       pop    {pc}
///////////////////