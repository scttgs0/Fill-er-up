;======================================
; FILL 'ER UP!
;--------------------------------------
; BY Tom Hudson
; A.N.A.L.O.G. COMPUTING #10
;======================================

                .include "equates_system_c256.asm"
                .include "equates_zeropage.asm"
                .include "equates_game.asm"

                .include "macros_65816.asm"
                .include "macros_frs_graphic.asm"
                .include "macros_frs_mouse.asm"


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

                jmp START


;--------------------------------------
;--------------------------------------
                * = $1400
;--------------------------------------

                .include "main.asm"


;--------------------------------------
;--------------------------------------

                .include "SPRITE_player.asm"
                .include "panel.asm"
                .include "SPRITE_star.asm"
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
                .align $100
;--------------------------------------

                .include "FONT.asm"
