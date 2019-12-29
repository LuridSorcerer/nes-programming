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
	stx $4010

:	bit PPUSTATUS	; Wait for PPU to warm up
	bpl :-
:	bit PPUSTATUS	; Still waiting...
	bpl :-

	txa				; Loop through memory and zero it out
:	lda #$00
	sta $0000, x
	sta $0100, x
	sta $0300, x
	sta $0400, x
	sta $0500, x
	sta $0600, x
	sta $0700, x
	lda #$fe		; Except sprite locations, move them offscreen
	sta $0200, x
	inx
	bne :-

:	bit PPUSTATUS	; Wait one more time for PPU
	bpl :-

	lda PPUSTATUS
	lda #$3f		; set palette address
	sta PPUADDR
	lda #$00
	sta PPUADDR
	
	ldx #$00			; load palette
:	lda PaletteData, x
	sta PPUDATA
	inx
	cpx #$20
	bne :-

	ldx #$00			; load sprites
:	lda SpriteData, x
	sta $0200, x
	inx
	cpx #$10
	bne :-

	lda #%10000000		; enable NMI
	sta PPUCTRL

	lda #%00010000		; enable sprites
	sta PPUMASK

forever:			; loop forever, nothing else to do
	jmp forever
.endproc

PaletteData:
	.byte $00,$18,$27,$28, $23,$24,$25,$26, $27,$28,$29,$2a, $2b,$2b,$2c,$2d
	.byte $22,$18,$27,$28, $23,$24,$25,$26, $27,$28,$29,$2a, $2b,$2b,$2c,$2d

SpriteData:
	; y, tile, attributes, x
	.byte $80, $42, $00, $80
	.byte $80, $43, $00, $88
	.byte $88, $52, $00, $80
	.byte $88, $53, $00, $88


.proc nmi			; NMI interrupt

	lda #$00		; load sprites, low byte
	sta OAMADDR
	lda #$02		; high byte
	sta OAMDMA
	
	inc $0203	; Move a sprite
	inc $0203+4	
	inc $0203+8	
	inc $0203+12
	
	rti

.endproc

.proc irq	; IRQ interrupt, empty
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
.incbin "test2.chr"
