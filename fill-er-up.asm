
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

                .cpu "65c02"

                .include "equates/system_f256.equ"
                .include "equates/zeropage.equ"
                .include "equates/game.equ"

                .include "macros/f256_graphic.mac"
                .include "macros/f256_mouse.mac"
                .include "macros/f256_random.mac"
                .include "macros/f256_sprite.mac"
                .include "macros/f256_text.mac"


;--------------------------------------
;--------------------------------------
                * = $2000
;--------------------------------------

                ; .byte $F2,$56           ; signature
                ; .byte $02               ; slot count
                ; .byte $01               ; first slot
                ; .addr BOOT              ; execute address
                ; .word $0001             ; version
                ; .word $0000             ; kernel
                ; .null 'Fill-er Up'      ; binary name

;--------------------------------------

                .text "PGX"
                .byte $03
                .dword BOOT

;--------------------------------------

BOOT            ldx #$FF                ; initialize the stack
                txs

                jmp START


;--------------------------------------
;--------------------------------------

                .include "main.asm"

                .include "player.asm"
                .include "panel.asm"
                .include "star.asm"
                .include "search.asm"
                .include "regionfill.asm"


;--------------------------------------
                .align $100
;--------------------------------------

                .include "interrupt.asm"
                .include "platform_f256.asm"
                .include "facade.asm"

                .include "DATA.inc"


;--------------------------------------
                .align $400
;--------------------------------------

GameFont        .include "FONT.inc"
GameFont_end


;--------------------------------------
                .align $100
;--------------------------------------

Palette         .include "PALETTE.inc"
Palette_end


;--------------------------------------
                .align $100
;--------------------------------------

Stamps          .include "SPRITES.inc"
Stamps_end

Playfield       .fill 86*40,$00
                .fill 10*40,$00         ; overflow to prevent screen artifacts
                .fill 240*40,$00
