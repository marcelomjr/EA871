/* This assembly file uses GNU syntax */
	.text
	.section	.rodata
	.align	2
	
	
.LC0:
	
	.text
	.align	2
	.global	main
	.type main function
# parametro: r0: tempo de delay
delay:
	sub r0, r0, #1	@ Decrementa o contador
	cmp r0, #0		@ compara com zero
	bne delay		@ se for diferente de zero volta para o comeco do loop
	mov pc, lr		@ Senao sai da funcao
	
main:
	push {r4, lr}
	
	# Habilita clock GPIO do PORTB
	ldr r0, = SIM_SCGC5	@ carrega em r0 o endereco de SIM_SCGC5
	ldr r0, [r0]
	ldr r1, [r0]		@ carrega o valor do registrador SIM_SCGC5
	mov r2, #128		
	lsl r2, #3			@ Mascara para setar apenas o bit 10
	orr r1, r1, r2		@ OU logico entre o conteudo de SIM_SCGC5 e a mascara criada
	str r1, [r0]		@ Atualiza o registrador SIM_SCGC5
	
	# Zera MUX: bits 10, 9 e 8 de PTB18
	ldr r0, = PORTB_PCR18	@ carrega em r0 o endereco de PORTB_PCR18
	ldr r0, [r0]
	ldr r1, [r0]			@ carrega o valor do registrador PORTB_PCR18
	mov r2, #7		
	lsl r2, #8				@ Mascara para setar apenas o bit 10
	mov r4, #0
	bic r2, r2, r4 			@ Realiza um bitwise AND  entre o conteudo de PORTB_PCR18 e a mascara criada
	and r1, r1, r2
	str r1, [r0]			@ Atualiza o registrador PORTB_PCR18
	
	# Seta MUX: 001 de PTB18
	ldr r1, [r0]			@ carrega o valor do registrador PORTB_PCR18
	mov r2, #128	
	lsl r2, r2, #1			@ Cria mascara 0x00000100
	orr r1, r1, r2			@ OU logico
	str r1, [r0]			@ Atualiza o registrador PORTB_PCR18
	
	# Pino 18 do PORTB como saída
	ldr r0, = GPIOB_PDDR	@ carrega em r0 o endereco de GPIOB_PDDR
	ldr r0, [r0]
	ldr r1, [r0]			@ carrega o valor do registrador GPIOB_PDDR
	mov r2, #1		
	lsl r2, r2, #18			@ Deslocamento para esquerda para seta bit 18
	orr r1, r1, r2			@ OU logico entre o conteudo de GPIOB_PDDR e a mascara criada
	str r1, [r0]			@ Atualiza o registrador GPIOB_PDDR
	
	# vai entrar num laco de repeticao
	mov r2, #1				
	lsl r2, r2, #18			@ Mascara para setar e limpar pino 18
	
laco:
	# Apaga o LED
	ldr r0, = GPIOB_PSOR	@ Carrega o endereco da constante
	ldr r0, [r0]			@ Carrega o endereco do registrador GPIOB_PSOR
	str r2, [r0]			@ Grava o valor da mascara nele
	
	ldr r0, = DELAY_TIME	@ Carrega o endereco da constante
	ldr r0, [r0]			@ Carrega o tempo de delay
	bl delay				@ Salta para funcao delay
	
	# Acende o LED
	ldr r1, = GPIOB_PCOR	@ Carrega o endereco da constante
	ldr r1, [r1]			@ Carrega o endereco do registrador GPIOB_PCOR
	str r2, [r1]			@ Grava o valor da mascara nele
	
	ldr r0, = DELAY_TIME	@ Carrega o endereco da constante
	ldr r0, [r0]			@ Carrega o tempo de delay
	bl delay				@ Salta para funcao delay
	
	b laco 					@ Salta para o inicio do loop
	
	mov	r3, #0
	mov	r0, r3
	pop {r4, pc}
	
	.align	2
	
SIM_SCGC5:		.word 0x40048038  @ Configura clock
PORTB_PCR18:	.word 0x4004A048  @ MUX de PTB18
GPIOB_PDDR:		.word 0x400FF054  @ Data direction do PORTB
GPIOB_PSOR:		.word 0x400FF044  @ Set bit PORTB
GPIOB_PCOR:		.word 0x400FF048  @ Clear bit PORTB
DELAY_TIME: 	.word 0x00500000  @ Delay default time	
