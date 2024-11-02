		.text
		.global	_start

__vector:	b	Reset_Handler
		b	.
		b	.
		b	.
		b	.
		b	.
		b	IRQ_Handler
		b	.

_start:
Reset_Handler:
		bl	WT_SETUP
		bl	CLK_SETUP
		bl	MC_SETUP
		bl	PIO_SETUP
		bl	STACK_SETUP
HALT_LOOP:
		b	HALT_LOOP

/* Disable WatchDog */
WT_SETUP:	.equ	WT_BASE,	0x53000000
		.equ	WTCON_OFS,	0x0
		.equ	WTDAT_OFS,	0x4
		.equ	WTCNT_OFS,	0x8
		.equ	WTCON_Val,	0x8000	@ disable wt & reset signal
		.equ	WTDAT_Val,	0x8000	@ wt count
		ldr	r0,	=WT_BASE
		ldr	r1,	=WTCON_Val
		ldr	r2,	=WTDAT_Val
		str	r2,	[r0, #WTCNT_OFS]
		str	r2,	[r0, #WTDAT_OFS]
		str	r1,	[r0, #WTCON_OFS]
		mov	pc,	lr

/* CLK setup */
CLK_SETUP:	.equ	CLK_BASE,	0x4c000000
		.equ	LOCKTIME_OFS,	0x0
		.equ	MPLLCON_OFS,	0x4
		.equ	UPLLCON_OFS,	0x8
		.equ	CLKCON_OFS,	0xc
		.equ	CLKSLOW_OFS,	0x10
		.equ	CLKDIVN_OFS,	0x14
		ldr	r0,	=CLK_BASE
		adr	r8,	CLK_CFG
		ldmia	r8,	{r1-r6}
		str	r1,	[r0, #LOCKTIME_OFS]
		str	r2,	[r0, #CLKDIVN_OFS]
		str	r3,	[r0, #MPLLCON_OFS]
		str	r4,	[r0, #UPLLCON_OFS]
		str	r5,	[r0, #CLKSLOW_OFS]
		str	r6,	[r0, #CLKCON_OFS]
		mov	pc,	lr

/* Memory Controller setup */
MC_SETUP:	.equ	MC_BASE,	0x48000000
		adr	r13,	MC_CFG
		ldmia	r13,	{r0-r12}
		ldr	r13,	=MC_BASE
		stmia	r13,	{r0-r12}
		mov	pc,	lr
	
/* GPIO setup */
PIO_SETUP:	.equ	PIO_BASE,	0x56000000
		mov	r0,	#PIO_BASE
		adr	r1,	PIO_CFG
		add	r2,	r1,	#20
loop:		ldr	r3,	[r1],	#4
		str	r3,	[r0],	#16
		cmp	r1,	r2
		bne	loop
		mov	pc,	lr
/* 
PIO_SETUP:	ldr	r0,	=PCONA_Val
		str	r0,	[r14, #PCONA_OFS]
		ldr	r0,	=PCONB_Val
		ldr	r1,	=PUPB_Val
		str	r0,	[r14, #PCONB_OFS]
		str	r1,	[r14, #PUPB_OFS]
		ldr	r0,	=PCONC_Val
		ldr	r1,	=PUPC_Val
		str	r0,	[r14, #PCONC_OFS]
		str	r1,	[r14, #PUPC_OFS]
		ldr	r0,	=PCOND_Val
		ldr	r1,	=PUPD_Val
		str	r0,	[r14, #PCOND_OFS]
		str	r1,	[r14, #PUPD_OFS]
		ldr	r0,	=PCONE_Val
		ldr	r1,	=PUPE_Val
		str	r0,	[r14, #PCONE_OFS]
		str	r1,	[r14, #PUPE_OFS]
		ldr	r0,	=PCONF_Val
		ldr	r1,	=PUPF_Val
		str	r0,	[r14, #PCONF_OFS]
		str	r1,	[r14, #PUPF_OFS]
		ldr	r0,	=PCONG_Val
		ldr	r1,	=PUPG_Val
		str	r0,	[r14, #PCONG_OFS]
		str	r1,	[r14, #PUPG_OFS]
		ldr	r0,	=PCONH_Val
		ldr	r1,	=PUPH_Val
		str	r0,	[r14, #PCONH_OFS]
		str	r1,	[r14, #PUPH_OFS]
		mov	pc,	lr
 */
/* Stack space setup */
STACK_SETUP:	.equ	MODE_BITS,	0x1F
		.equ	USR_MODE,	0x10
		.equ	FIQ_MODE,	0x11
		.equ	IRQ_MODE,	0x12
		.equ	SVC_MODE,	0x13
		.equ	ABT_MODE,	0x17
		.equ	UND_MODE,	0x1B
		.equ	SYS_MODE,	0x1F
		.equ	RAM_START,	0x08000000
		.equ	RAM_END,	0x08040000	@ RAM size:	256K
							@ stack start:	0x0803db00
		.equ	CSTACK_SIZE,	0x2000		@ system mode	8K
		.equ	STACK_SIZE,	0x100		@ other mode	256B
		.equ	ABT_STACK,	(RAM_END - STACK_SIZE * 1)
		.equ	SVC_STACK,	(RAM_END - STACK_SIZE * 2)
		.equ	UND_STACK,	(RAM_END - STACK_SIZE * 3)
		.equ	FIQ_STACK,	(RAM_END - STACK_SIZE * 4)
		.equ	IRQ_STACK,	(RAM_END - STACK_SIZE * 5)
		.equ	CSTACK,		(IRQ_STACK - CSTACK_SIZE)

		mrs	r0,	cpsr
	
		bic	r0,	r0,	#MODE_BITS
		orr	r0,	r0,	#ABT_MODE
		msr	cpsr_c,	r0
		ldr	sp,	=ABT_STACK
		bic	r0,	r0,	#MODE_BITS
		orr	r0,	r0,	#SVC_MODE
		msr	cpsr_c,	r0
		ldr	sp,	=SVC_STACK
		bic	r0,	r0,	#MODE_BITS
		orr	r0,	r0,	#UND_MODE
		msr	cpsr_c,	r0
		ldr	sp,	=UND_STACK
		bic	r0,	r0,	#MODE_BITS
		orr	r0,	r0,	#FIQ_MODE
		msr	cpsr_c,	r0
		ldr	sp,	=FIQ_STACK
		bic	r0,	r0,	#MODE_BITS
		orr	r0,	r0,	#IRQ_MODE
		msr	cpsr_c,	r0
		ldr	sp,	=IRQ_STACK
		bic	r0,	r0,	#MODE_BITS
		orr	r0,	r0,	#SYS_MODE
		msr	cpsr_c,	r0
		ldr	sp,	=CSTACK
		mov	pc,	lr
	
/* Interrupt Vector Table */
		.equ	INTOFFSET,	0x4a000014
		.equ	IntVTaddress,	0x08039F20
		.equ	HandleEINT0,	(IntVTaddress + 4)
IRQ_Handler:
		sub	sp,	sp,	#4	@ reserve for pc
		stmfd	sp!,	{r8-r9}

		ldr	r9,	=INTOFFSET
		ldr	r9,	[r9]
		ldr	r8,	=HandleEINT0
		add	r8,	r8,	r9,	lsl #2
		ldr	r8,	[r8]
		str	r8,	[sp, #8]
		ldmfd	sp!,	{r8-r9, pc}

		.align	4
		.type	CLK_CFG,#object
CLK_CFG:	.word	0x005a55a5	@ LOCKTIME 0x5a5->120us
		.word	0x000a1031	@ MPLL 202.80MHz
		.word	0x00078023	@ UPLL 48MHz
		.word	0x00006130	@ CLK ON NAND, LCDC, PWM, GPIO, RTC
		.word	0x00000084	@ SLOW UCLK ON
		.word	0x00000003	@ DIVN 1:2:4
		.size	CLK_CFG, . - CLK_CFG

		.align	4
		.type	MC_CFG,#object
MC_CFG:		.word	0x00000090	@ BWSCON_Val
		.word	0x00000600	@ BANKCON0_Val
		.word	0x00000700	@ BANKCON1_Val
		.word	0x00000700	@ BANKCON2_Val
		.word	0x00000700	@ BANKCON3_Val
		.word	0x00000700	@ BANKCON4_Val
		.word	0x00000700	@ BANKCON5_Val
		.word	0x00018008	@ BANKCON6_Val
		.word	0x00018008	@ BANKCON7_Val
		.word	0x002c0000	@ REFRESH_Val
		.word	0x00000000	@ BANKSIZE_Val
		.word	0x00000020	@ MRSRB6_Val
		.word	0x00000000	@ MRSRB7_Val  
		.size	MC_CFG, . - MC_CFG

		.align	4
		.type	PIO_CFG,#object
PIO_CFG:	.word	0x0000103F	@ PCONA_Val
		.word	0x00155565	@ PCONB_Val
		.word	0x00AA56A9	@ PCONC_Val
		.word	0x55555555	@ PCOND_Val
		.word	0x05555555	@ PCONE_Val
		.word	0x00004014	@ PCONF_Val
		.word	0x55550001	@ PCONG_Val
		.word	0x00155555	@ PCONH_Val
		.size	PIO_CFG, . - PIO_CFG
