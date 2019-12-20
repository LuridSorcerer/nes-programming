; tutorial:
; https://www.moria.us/blog/2018/03/nes-development

; ASM basics:
; https://nesdoug.com/2016/03/10/26-asm-basics/

; prg pages (16k)
prg_npage = 1
; chr pages (8k)
chr_npage = 1
; mapper number
mapper = 0
; mirroring mode
mirroring = 1

; constants
PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
OAMADDR   = $2003
OAMDATA   = $2004
PPUSCROLL = $2005
PPUADDR   = $2006
PPUDATA   = $2007
OAMDMA    = $4014
APUSTATUS = $4015
JOYPAD1   = $4016
JOYPAD2   = $4017


; 16-byte INES header
.segment "INES"
	.byte 'N', 'E', 'S', $1a
	.byte prg_npage
	.byte chr_npage
	.byte ( (mapper & $0f) << 4 ) | (mirroring & 1) 
	.byte mapper & $f0

; vectors
.segment "VECTOR"
.addr nmi   ; non-maskable interrupt, called at vblank
.addr reset ; called at power on and reset button press
.addr irq   ; external hardware interrupt, not used yet


.code

.proc nmi
	rti
.endproc

.proc irq
	rti
.endproc

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
	sta 4000

forever:
	jmp forever
.endproc
