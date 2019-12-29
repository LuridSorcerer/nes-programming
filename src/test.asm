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
	stx PPUCTRL		; disable NMI
	stx PPUMASK		; disable rendering
	stx APUSTATUS	; silence sound channels
	stx APUDMC		; disable delta modulation channel IRQs

	jsr vblankwait	; Wait for PPU to warm up
	jsr vblankwait

ClearMem:
	lda #$00		; Loop through memory and zero it out
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
	bne ClearMem

	jsr vblankwait	; Wait one more time for PPU warmup

	lda PPUSTATUS
	lda #$3f		; set palette address
	sta PPUADDR
	lda #$00
	sta PPUADDR
	
	ldx #$00			; load palette
LoadPalette:
	lda PaletteData, x
	sta PPUDATA
	inx
	cpx #$20
	bne LoadPalette

	ldx #$00			; load sprites
LoadSprites:
	lda SpriteData, x
	sta $0200, x
	inx
	cpx #$20
	bne LoadSprites

	lda $2002		; load background nametable
	lda #$20
	sta PPUADDR
	lda #$00
	sta PPUADDR
	ldx #$00
LoadNametable:
	lda NametableData, x
	sta PPUDATA
	inx
	cpx #$80
	bne LoadNametable

	lda $2002		; load attribute table
	lda #$23
	sta PPUADDR
	lda #$C0
	sta PPUADDR
	ldx #$00
LoadAttributetable:	
	lda AttributeTableData, X
	sta PPUDATA
	inx
	cpx #$08
	bne LoadAttributetable

	lda #%10010000		; enable NMI
	sta PPUCTRL

	lda #%00011110		; enable sprites
	sta PPUMASK

forever:			; loop forever, nothing else to do
	jmp forever
.endproc

vblankwait:
	bit PPUSTATUS
	bpl vblankwait
	rts

PaletteData:
	.byte $00,$18,$27,$28, $23,$24,$25,$26, $27,$28,$29,$2a, $2b,$2b,$2c,$2d
	.byte $22,$18,$27,$28, $23,$24,$27,$28, $27,$28,$29,$2a, $2b,$2b,$2c,$2d

SpriteData:
	; y, tile, attributes, x
	.byte $80, $42, $00, $80
	.byte $80, $43, $00, $88
	.byte $88, $52, $00, $80
	.byte $88, $53, $00, $88

	.byte $90, $cb, $01, $80
	.byte $90, $cc, $01, $88
	.byte $98, $db, $01, $80
	.byte $98, $dc, $01, $88

NametableData:
	.byte $04,$04,$04,$04, $04,$04,$04,$04, $04,$04,$04,$04, $04,$04,$04,$04  ; row 1
	.byte $04,$04,$04,$04, $04,$04,$04,$04, $04,$04,$04,$04, $04,$04,$04,$04

	.byte $05,$05,$05,$05, $05,$05,$05,$05, $05,$05,$05,$05, $05,$05,$05,$05  ; row 2
	.byte $05,$05,$05,$05, $05,$05,$05,$05, $05,$05,$05,$05, $05,$05,$05,$05

	.byte $06,$06,$06,$06, $06,$06,$06,$06, $06,$06,$06,$06, $06,$06,$06,$06  ; row 3
	.byte $06,$06,$06,$06, $06,$06,$06,$06, $06,$06,$06,$06, $06,$06,$06,$06 

	.byte $07,$07,$07,$07, $07,$07,$07,$07, $07,$07,$07,$07, $07,$07,$07,$07  ; row 4
	.byte $07,$07,$07,$07, $07,$07,$07,$07, $07,$07,$07,$07, $07,$07,$07,$07

AttributeTableData:
	.byte %00000000, %00010000, %00100000, %00010000, %00000000, %00000000, %00110000, %00000000 

.proc nmi			; NMI interrupt

	lda #$00		; load sprites, low byte
	sta OAMADDR
	lda #$02		; high byte
	sta OAMDMA

	lda #$01	; latch controllers
	sta JOYPAD1
	lda #$00
	sta JOYPAD1

	lda JOYPAD1
	and #%00000001	; check button A
	beq ReadADone	; if not pressed, skip moving sprite
	inc $0203	; Move a sprite
	inc $0203+4	
	inc $0203+8	
	inc $0203+12
ReadADone:
	
	lda #$00		; don't scroll background
	sta PPUSCROLL
	sta PPUSCROLL

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
