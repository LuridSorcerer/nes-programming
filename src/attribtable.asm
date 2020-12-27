; Each byte represents the palette attributes for a 4x4 set of tiles
; They are subdivided into 2x2 tile squares, with two bits each.
; BR -  BL - TR - TL
; more info: https://wiki.nesdev.com/w/index.php/PPU_attribute_tables

	.byte %11111111, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
