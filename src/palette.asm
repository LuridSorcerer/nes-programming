    ; background
    .byte $00,$18,$27,$28 ; bg palette 1
    .byte $00,$24,$25,$26 ; bg palette 2
    .byte $00,$28,$29,$2a ; bg palette 3
    .byte $00,$2b,$2c,$2d ; bg palette 4
	
    ; sprites
    ; I don't understand why the first color for the sprites
    ; appears to overwrite the background color
    .byte $22,$18,$27,$28 ; sprite palette 1 (waffle)
    .byte $00,$24,$27,$28 ; sprite palette 2 (doughnut)
    .byte $00,$06,$20,$00 ; sprite palette 3 (toaster)
    .byte $00,$2b,$2c,$2d ; sprite palette 4
