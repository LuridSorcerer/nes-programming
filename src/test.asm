.include "defs.asm"
.include "header.asm"

.segment "ZEROPAGE"
controller: .res 1
playerx:	.res 1
playery:	.res 1

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
	cpx #(PaletteEnd - PaletteData)
	bne LoadPalette

	ldx #$00			; load sprites
LoadSprites:
	lda SpriteData, x
	sta $0200, x
	inx
	cpx #(SpriteEnd - SpriteData)
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
	cpx #(NametableEnd - NametableData)
	bne LoadNametable

	lda $2002		; load attribute table
	lda #$23
	sta PPUADDR
	lda #$C0
	sta PPUADDR
	ldx #$00
LoadAttributetable:	
	lda AttributetableData, X
	sta PPUDATA
	inx
	cpx #(AttributetableEnd - AttributetableData)
	bne LoadAttributetable

	lda #%10010000		; enable NMI
	sta PPUCTRL

	lda #%00011110		; enable sprites
	sta PPUMASK

	lda #$80			; move player to center of screen
	sta playerx
	sta playery

forever:			; loop forever, nothing else to do
	jmp forever
.endproc

vblankwait:
	bit PPUSTATUS
	bpl vblankwait
	rts

ReadController:
	lda #$01		; latch controller
	sta JOYPAD1
	lda #$00
	sta JOYPAD1
	ldx #$08		; going to read 8 buttons
ReadControllerLoop:
	lda JOYPAD1		; read a button
	lsr a			; move into carry register
	rol controller	; move from carry to controller byte
	dex
	bne ReadControllerLoop
	rts

DrawPlayer:			; renders the player based on saved x and y coords
	lda playery
	sta $0200
	sta $0200+4
	lda playerx 
	clc
	sta $0203
	adc #$08
	sta $0203+4
	rts

PaletteData:
	.include "palette.asm"
PaletteEnd:

SpriteData:
	.include "sprite.asm"
SpriteEnd:

NametableData:
	.include "nametable.asm"
NametableEnd:

AttributetableData:
	.include "attribtable.asm"
AttributetableEnd:

.proc nmi			; NMI interrupt

	lda #$00		; load sprites, low byte
	sta OAMADDR
	lda #$02		; high byte
	sta OAMDMA

	jsr ReadController

	lda controller	; check if right was pressed
	and #BTN_RIGHT
	beq RightDone	; if not pressed, skip moving sprite
	inc playerx
;	inc $0203		; Move sprite right
;	inc $0203+4	
;	inc $0203+8	
;	inc $0203+12
RightDone:

	lda controller	; check if left was pressed
	and #BTN_LEFT
	beq LeftDone	; if not, skip moving sprite
	dec playerx
;	dec $0203		; move sprite left
;	dec $0203+4
;	dec $0203+8
;	dec $0203+12
LeftDone:

	lda controller	; check if down was pressed
	and #BTN_DOWN
	beq DownDone
	inc playery
;	inc $0200
;	inc $0200+4
;	inc $0200+8
;	inc $0200+12
DownDone:

	lda controller	; check if up was pressed
	and #BTN_UP
	beq UpDone
	dec playery
;	dec $0200
;	dec $0200+4
;	dec $0200+8
;	dec $0200+12
UpDone:

	jsr DrawPlayer

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
