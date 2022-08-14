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

                .cpu "65816"

                .include "equates_system_c256.asm"
                .include "equates_zeropage.asm"
                .include "equates_game.asm"

                .include "macros_65816.asm"
                .include "macros_frs_graphic.asm"
                .include "macros_frs_mouse.asm"
                .include "macros_frs_random.asm"


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
                .align $1000
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

;--------------------------------------
;--------------------------------------
                .align $1000
;--------------------------------------

Playfield       .fill 86*40,$00
Video8K         .fill 8192