//a). Realizar un programa que detecte un flanco ascendente en el pin PB10 (configure
//    como entrada ese pin). Cuando se detecte el flanco, se debe encender el led en el pin
//    PC13, por 200ms. Se considera que en el pin PB10, ingresan señales de mas de
//    0.5Hz.


//Directivas para que el ensambrador tome el lenguaje y el micro 
.syntax unified
.cpu cortex-m3
.thumb


//escribo en memoria flash
.text
// cargo constantes de direcciones de registro del micro para el compilador
.set GPIO_CRH,  0x04        //offset para trabajar sobre pines altos
.set GPIO_ODR,  0x0C
.set GPIO_IDR,  0x08
//contantes para configurar pin PB10 como entrada
.set RCC_Base,  0x40021000  //direccion base de registro de reloj
.set APB2ENR,   0x18        //offset para pararse en la configuracion apb2 asi se enablea el clock de puerto B y C
.set PB_Clk_EN, 0b1000      //mascara para poner el bit 3 en 1 y enablear el clock

.set GPIOB_Base, 0x40010c00 //direc de memoria del puerto gpioB
.set PB10_IN,   0b0100     //pin en modo entrada, entrada flotante
.set PB10_CRH_POS, 8        //para elegir el pin correspondiente


//constantes para configurar pin PC13 como salida
.set PC_Clk_EN, 0b10000

.set GPIOC_Base, 0x40011000
.set PC13_OUT,    0b0010
.set PC13_CRH_POS,    20


.set GPIO_ODR, 0x0C
.set GPIO_IDR, 0x08

//mascaras que determinan si las entradas y salidas estan activas o no
.set PC10_Up,     (1<<10)
.set PC10_Down,   0x0400
.set PC13_Up,     0xDFFF
.set PC13_Down,   (1<<13)

//auxiliares
.set CFG_MASK, 0xF

//constantes timer systick
.set SysTick_base, 0xE000E010
.set SYST_CSR, 0x00
.set SYST_RVR, 0x04
.set SYST_CVR, 0x08
.set RELOJ_reset, 8000000
.set SYST_CSR_Enable_mask, (1<<0)
.set SYST_CSR_Coutflag_mask, (1<<16)


.global main
main:
    bl inicializar_PB10_Reloj
    bl inicializar_PB10_entrada
    bl inicializar_PC13_Reloj
    bl inicializar_PC13_salida
    bl inicializar_systick
control_entrada:                  //bucle para ver si la entrada PB13 esta en alto
    ldr     R2,=0x00000000         
    ldr     R0,=GPIOB_Base       
    ldr     R1, [R0,#GPIO_IDR]     //leo el valor que tiene la salida actualmente
    ands    R1, 0x0400             //verifico si en el bit 13 esta en alto
    beq     control_entrada        //si el bit 13 (pin 13) es 0, el and devuelve 0 y vuelvo a control_entrada
prender_led:                       //bucle para prender led 250ms
    ldr     R0,=GPIOC_Base
    ldr     R1, [R0,#GPIO_ODR]     
    ands    R1, PC13_Up            //coloco "0" en el pin 13 (prendo led)
    str     R1, [R0,#GPIO_ODR]
    movs    R0, #5
    bl      delay_ms               //llamo a un retardo de 250ms             
    ldr     R0,=GPIOC_Base
    ldr     R1, [R0,#GPIO_ODR]
    orrs    R1, PC13_Down          //coloco "1" en el pin 13 (apago led)
    str     R1, [R0,#GPIO_ODR]
    bx      lr
    b       .

delay_ms:
    // R0: cantidad ms
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

delay_1ms:
    // COUNTFLAG Returns 1 if timer counted to 0 since last time this was read.
    ldr R0,=SysTick_base
0:
    ldr R1,[R0,#SYST_CSR]
    tst R1,#SYST_CSR_Coutflag_mask
    beq 0b
    bx  lr

inicializar_PB10_Reloj:
    ldr     R0,=RCC_Base       //muevo la direccion de RCC_Base a R0
    ldr     R1,[R0,#APB2ENR]   //muevo el contenido de APB2ENR a R1
    orrs     R1,PB_Clk_EN       //mascara con or para colocar 1 en el bit 3 de APB2 enableando el clock del puerto B
    str     R1,[R0,#APB2ENR]   //muvo valor de R1 a APB2ENR
    bx      lr
inicializar_PB10_entrada:
    ldr     R0,=GPIOB_Base
    ldr     R1, [R0,#GPIO_CRH]
    ldr     R1, =#(PB10_IN << 4*(10-8))
    str     R1, [R0,#GPIO_CRH]
    bx      lr

inicializar_PC13_Reloj:
    ldr     R0,=RCC_Base       //muevo la direccion de RCC_Base a R0
    ldr     R1,[R0,#APB2ENR]   //muevo el contenido de APB2ENR a R1
    orrs    R1,PC_Clk_EN      
    str     R1,[R0,#APB2ENR]   //muvo valor de R1 a APB2ENR
    bx      lr
inicializar_PC13_salida:
    ldr     R0,=GPIOC_Base
    ldr     R1, [R0,#GPIO_CRH]
    ldr     R1, =#(PC13_OUT << 4*(15-8))
    str     R1,[R0,#GPIO_CRH]
    ldr     R0,=GPIOC_Base      // a partir de aqui coloco en 1 la salida de PC13 (apago led)
    ldr     R1, [R0,#GPIO_ODR]
    orrs    R1, PC13_Down
    str     R1, [R0,#GPIO_ODR]
    bx      lr

inicializar_systick:

// Program reload value.             
    ldr R0,=SysTick_base                      
    ldr R1,=((1*RELOJ_reset)/1000)
    str R1,[R0,#SYST_RVR]
// Clear current value.
    movs R1,#0
    str R1,[R0,#SYST_CVR]
// Program Control and Status register.
    ldr R1,[R0,#SYST_CSR]
    orrs R1,SYST_CSR_Enable_mask
    str R1,[R0,#SYST_CSR]
    bx lr