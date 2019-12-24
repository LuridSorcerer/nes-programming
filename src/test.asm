.include "defs.asm"
.include "header.asm"

.code

.proc reset

	sei		; SEt Interrupt: disable interrupts
	cld		; CLear Decimal: disable binary coded decimal mode
			; 	(not supported by the 2A03 anyway)

	
	ldx #$ff	; Set stack pointer to $FF
	txs

	inx				; Set X to zero (overflow from $FF)
	stx PPUCTRL
	stx PPUMASK
	stx APUSTATUS

:	bit PPUSTATUS	; Wait for PPU to warm up
	bpl :-
:	bit PPUSTATUS	; Still waiting...
	bpl :-

	txa				; Loop through memory and zero it out
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

:	bit PPUSTATUS	; Wait one more time for PPU
	bpl :-

;	lda #$01		; play an annoying continuous beep
;	sta $4015
;	lda #$08
;	sta $4002
;	lda #$02
;	sta $4003
;	lda #$bf
;	sta $4000
	
;	lda #%10000000	; intensify blues
;	sta PPUMASK

	lda PPUSTATUS
	lda #$3f		; set palette address
	sta PPUADDR
	lda #$00
	sta PPUADDR
	
	ldx #$00			; load palette
PaletteLoop:
	lda PaletteData, x
	sta PPUDATA
	inx
	cpx #$20
	bne PaletteLoop

	lda #$80
	sta $0200
	sta $0203
	lda #$00
	sta $0201
	sta $0202

	lda #%10000000
	sta PPUCTRL

	lda #%00010000
	sta PPUMASK

forever:			; loop forever, nothing else to do
	jmp forever
.endproc

PaletteData:
	.byte $1d,$20,$21,$22, $23,$24,$25,$26, $27,$28,$29,$2a, $2b,$2b,$2c,$2d
	.byte $1d,$20,$21,$22, $23,$24,$25,$26, $27,$28,$29,$2a, $2b,$2b,$2c,$2d

.proc nmi			; NMI interrupt

	lda #$00		; load sprites, low byte
	sta OAMADDR
	lda #$02		; high byte
	sta OAMDATA
	rti

.endproc

.proc irq			; IRQ interrupt, empty
	rti
.endproc

; vectors
.segment "VECTOR"
.addr nmi   ; non-maskable interrupt, called at vblank
.addr reset ; called at power on and reset button press
.addr irq   ; external hardware interrupt, not used yet

; Empty CHR data
.segment "CHR0a"
.incbin "test.chr"

.segment "CHR0b"
