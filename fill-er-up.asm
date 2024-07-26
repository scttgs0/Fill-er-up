
;======================================
; FILL 'ER UP!
;--------------------------------------
; BY Tom Hudson
; A.N.A.L.O.G. COMPUTING #10
;======================================

;   SP00        player
;   SP01        star

;   Graphics    160x129                 ; 86 graphic; 27 blanks; 16 text
;       ours    320x240                 ; 76,800 bytes [$12C00 = 300 pages]
;   Playfield   318x170

                .include "equates/system_c256.equ"
                .include "equates/zeropage.equ"
                .include "equates/game.equ"

                .include "macros/65816.mac"
                .include "macros/c256_graphic.mac"
                .include "macros/c256_mouse.mac"
                .include "macros/c256_random.mac"


;--------------------------------------
;--------------------------------------
                * = START-40
;--------------------------------------
                .text "PGX"
                .byte $01
                .dword BOOT

BOOT            clc
                xce
                .m8i8
                .setdp $0000
                .setbank $00
                cld

                jmp START


;--------------------------------------
;--------------------------------------
                * = $2000
;--------------------------------------

                .include "main.asm"


;--------------------------------------
;--------------------------------------

                .include "player.asm"
                .include "panel.asm"
                .include "star.asm"
                .include "search.asm"
                .include "regionfill.asm"


;--------------------------------------
                .align $100
;--------------------------------------

                .include "interrupt.asm"
                .include "platform_c256.asm"


;--------------------------------------
                .align $100
;--------------------------------------

                .include "DATA.asm"


;--------------------------------------
                .align $1000
;--------------------------------------

GameFont        .include "FONT.asm"
GameFont_end

Palette         .include "PALETTE.asm"
Palette_end


;--------------------------------------
                .align $100
;--------------------------------------

Stamps          .include "SPRITES.asm"
Stamps_end

Playfield       .fill 86*40,$00
                .fill 10*40,$00         ; overflow to prevent screen artifacts

;--------------------------------------
;--------------------------------------
                .align $100
;--------------------------------------

Video8K         .fill 8192,$00
