// https://sourceware.org/binutils/docs/as.html
// https://developer.arm.com/documentation/dui0552
// https://github.com/ARM-software/abi-aa/blob/main/aapcs32/aapcs32.rst
// https://www.st.com/resource/en/reference_manual/cd00171190-stm32f101xx-stm32f102xx-stm32f103xx-stm32f105xx-and-stm32f107xx-advanced-arm-based-32-bit-mcus-stmicroelectronics.pdf

// constantes para inicializar reloj
.set RCC_base, 0x40021000
.set RCC_APB2ENR, 0x18 
.set IOPAEN_mask, (1<<2)

// constantes para GPIOA
.set GPIOA_base, 0x40010800
.set GPIO_CRL, 0x00
.set P0_P7_salida_PP_2MHz, 0x22222222

// constantes SysTick
.set SysTick_base, 0xE000E010
.set SYST_CSR, 0x00
.set SYST_RVR, 0x04
.set SYST_CVR, 0x08
.set SYST_CSR_ENABLE_mask, (1<<0)
.set SYST_CSR_Countflag_mask, (1<<16)
.set RELOJ_reset, 8000000


// conjunto de instrucciones y sintaxis 
.syntax unified
.cpu cortex-m3
.thumb 
//.data es para reservar memoria en ram 
.seccion .text.main     //seccion por funcion 
.global main            //Para usar main desde afuera 
.type main, %funcion    // main tiene codigo ejecutable (anotacion)

main:
    push {LR}
    ldr R0,=misDatos    //posicion en Flash de los datos (puntero)
    movs R1,#32         //Cantidad de datos
    movs R2,#1          //Delay en ms
    bl punto4
    pop {LR}
    bx LR
.size main, . - main // tamaño en memoria de main (anotacion)

.section .text.punto4
.global punto4
.type punto4, %function

punto4:
    // R0:direccion datos; R1:cantidad de datos ; R2:delay ms
    push {R4-R7,LR}
    movs R4,R0
    movs R5,R1
    movs R6,R2
    movs R7,#0 //contador
    bl inicializa_puerto_a
    bl inicializar_SysTick
0:
    ldrb R0,[R4,R7]
    bl extraer_dato
    movs R0,R6
    bl delay_ms
    adds R7,#1
1:
    cmp R7,R5
    bne 0b
    pop {R4-R7,PC}
.size punto4, . - punto4


.text
inicializa_puerto_a:
    // conecta reloj 
    ldr R0,=RCC_base
    ldr R1,[R0,#RCC_APB2ENR]
    orrs R1,#IOPAEN_mask
    str R1,[R0,#RCC_APB2ENR]
    //PA0...PA7 como salidas, push-pull, 2_MHz
    ldr R0,=GPIOA_base
    movs R1,#P0_P7_salida_PP_2MHz
    str R1,[R0,#GPIO_CRL]
    bx LR
    
inicializar_SysTick:
//Program reload value.
    ldr R0,=SysTick_base
    ldr R1,=((1*RELOJ_reset)/1000)
    str R1,[R0,#SYST_RVR]
//Clear current value.
    movs R1,#0
    str R1,[R0,#SYST_CVR]
//Program control and status register 
    ldr R1,[R0,#SYST_CSR]
    orrs R1,SYST_CSR_ENABLE_mask
    str R1,[R0,#SYST_CSR]
    bx LR

delay_1ms:
    // COUNTFLAG returns 1 if timer counted to 0 since last time this was read.
    ldr R0, =SysTick_base
0:
    ldr R1,[R0,#SYST_CSR]
    tst R1,#SYST_CSR_Countflag_mask
    beq 0b
    bx lr

delay_ms:
    // R0: cantidad de ms
    push {R4,LR}
    movs R4,R0
    b 1f
0:
    bl delay_1ms
    subs R4,#1
1:
    cmp R4,#0
    bne 0b
    pop {R4,PC}

.set ODR,   0x0c
.set BSRR,  0x10

extraer_dato:
    //R0:dato (1 byte)
    ldr R1,=GPIOA_base
    mvns R2,R0
    bfi R0,R2,#16,#8
    str R0,[R1,#BSRR]
    bx lr

.pool   //FLASH
misDatos:
    .ascii "Electronica IV. Practico 1. P_IV"