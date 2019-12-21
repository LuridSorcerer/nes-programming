; prg pages (16k)
prg_npage = 1
; chr pages (8k)
chr_npage = 1
; mapper number
mapper = 0
; mirroring mode
mirroring = 1

; 16-byte INES header
.segment "INES"
	.byte 'N', 'E', 'S', $1a
	.byte prg_npage
	.byte chr_npage
	.byte ( (mapper & $0f) << 4 ) | (mirroring & 1) 
	.byte mapper & $f0
