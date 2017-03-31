/* This assembly file uses GNU syntax  */
    .data                @ area de dados - inicio memoria SRAM
    .align    2            @ alinhado em fronteiras de palavras (32 bits)
RAM_START:


    .text                @ area de codigo 
    .global main            @ torna main visivel para o ambiente de execucao 
    
main:
	@@ Habilita a porta B com o registrador SIM_SCGC5
    ldr    r3,SIM_SCGC5		@ Carrega em r3 o endereco de SIM_SCGC5 
    ldr    r2,SIM_SCGC5		@ Carrega em r2 o endereco de SIM_SCGC5
    ldr    r2, [r2, #0]		@ Carrega em r2 o conteudo de do registrador SIM_SCGC5
    movs   r1, #128			@ Carrega o valor 128 em r1, r1 = 0b10000000
    lsl    r1, r1, #3		@ seta o bit 10 e limpa os outros bits de r1  
    orr    r2, r1			@ r2 = r2 OR r1. Seta o bit 10 de r2 sem alterar os seus outros bits
    str    r2, [r3, #0]		@ atualiza o valor do registrador SIM_SCGC5
    
    @@ Configura o pino 18 da porta B como GPIO
    ldr    r3, PORTB_PCR18	@ Carrega em r3 o endereco do registrador PORTB_PCR18    
    movs   r2, #128    		@ Carrega o valor 128 em r1, r1 = 0b10000000 
    lsl    r2, r2, #1		@ Seta o pino 8 e limpa os restantes, configura o pino para o MUX de GPIO
    str    r2, [r3, #0]		@ atualiza o valor do registrador PORTB_PCR18
    
    @ Configura a direcao do pino 18 da porta B como saida.
    ldr    r3, GPIOB_PDDR	@ Carrega em r3 o endereco do GPIOB_PDDR
    ldr    r2, GPIOB_PDDR   @ Carrega em r2 o endereco do GPIOB_PDDR
    ldr    r2, [r2, #0]		@ Carrega em r2 o conteudo do GPIOB_PDDR
    movs   r1, #128    		@ Carrega o valor 128 em r1, r1 = 0b10000000
    lsl    r1, r1, #11		@ Desloca 11 bits para esquerda (seta o bit 18 e limpa os reseta os restantes).
    orr    r2, r1			@ Seta o bit 18, mas mantem o conteudo restante do GPIO_PDDR em r2
    str    r2, [r3, #0]		@ Atualiza o valor do registrador GPIOB_PDDR
    
    
loop:
	@ Nega o valor do LED (se esta acesso apaga e vice versa)    
    ldr    r3, GPIOB_PTOR	@ Carrega em r3 o endereco do GPIOB_PTOR
    movs   r2, #128 	   	@ Carrega o valor 128 em r2, r2 = 0b10000000
    lsl    r2, r2, #11		@ Desloca 11 bits para esquerda (seta o bit 18 e reseta os restantes)
    str    r2, [r3, #0]		@ Carrega o valor atualizado no registrador GPIOB_PTOR
espera:
	@ Atualiza o valor do tempo de delay
    ldr   r3, VAR_TEMPO		@ Carrega em r3 o endereco da varivael VAR_TEMPO    
    ldr   r2, TEMPO			@ Carrega em r2 o valor de dalay TEMPO
    str   r2, [r3, #0]		@ Salva o tempo na variavel VAR_TEMPO
    b     testa				@ salta para o rotulo testa
decrementa: 
	@ Decrementa o valor da variavel VAR_TEMPO
    ldr   r3, VAR_TEMPO    @ Carrega em r3 o endereco da variavel VAR_TEMPO
	ldr   r3, [r3, #0]	   @ Carrega em r3 o valor da variavel VAR_TEMPO
    sub   r2, r3, #1	   @ Decrementa uma unidade
    ldr   r3, VAR_TEMPO    @ Carrega em r3 o endereco da variavel VAR_TEMPO
    str   r2, [r3, #0]	   @ Atualiza o valor da variavel VAR_TEMPO
testa:
	@
    ldr   r3, VAR_TEMPO	   @ Carrega em r3 o endereco da variavel VAR_TEMPO
    ldr   r3, [r3, #0]	   @ Carrega em r3 o valor da variavel VAR_TEMPO
    cmp   r3, #0		   @ Compara r3 com zero
    bne   decrementa	   @ Se o valor da variavel for diferente de zero salta para decrementa
    b     loop			   @ Senao salta para o rotulo loop

    .align 2                    @ a partir deste ponto alinhado em fronteiras de palavras (32 bits)

SIM_SCGC5:        .word    0x40048038        @ Habilita as Portas do GPIO (Reg. SIM_SCGC5)
PORTB_PCR18:        .word    0x4004A048        @ MUX de PTB18 (Reg. PORTB_PCR18)
GPIOB_PDDR:        .word    0x400FF054        @ Data direction do PORTB (Reg. GPIOB_PDDR)
GPIOB_PTOR:        .word    0x400FF04C        @ Toggle register do PORTB (Reg. GPIOB_PTOR)
TEMPO:            .word    500000            @ valor inicial do contador de tempo
VAR_TEMPO:        .word    RAM_START        @ variavel de contagem de tempo alocada na memoria SRAM
    
    
    .end        @ final do arquivo do programa
