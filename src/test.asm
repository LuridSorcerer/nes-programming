.include "defs.asm"
.include "header.asm"

.code

.proc reset
	sei
	cld
	ldx #$ff
	txs
	inx
	stx PPUCTRL
	stx PPUMASK
	stx APUSTATUS

:	bit PPUSTATUS
	bpl :-
:	bit PPUSTATUS
	bpl :-

	txa
:	sta $000, x
	sta $100, x
	sta $200, x
	sta $300, x
	sta $400, x
	sta $500, x
	sta $600, x
	sta $700, x
	inx
	bne :-

:	bit PPUSTATUS
	bpl :-

	lda #$01
	sta $4015
	lda #$08
	sta $4002
	lda #$02
	sta $4003
	lda #$bf
	sta $4000

forever:
	jmp forever
.endproc

.proc nmi
	rti
.endproc

.proc irq
	rti
.endproc

; vectors
.segment "VECTOR"
.addr nmi   ; non-maskable interrupt, called at vblank
.addr reset ; called at power on and reset button press
.addr irq   ; external hardware interrupt, not used yet

.segment "CHR0a"
.segment "CHR0b"
