
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

.if PGX=1
                .text "PGX"
                .byte $03
                .dword BOOT
;--------------------------------------
; .elsif PGZ=1
;                 .text "PGZ"
;                 .byte $03
;                 .dword BOOT
;--------------------------------------
; .else
;                 .byte $F2,$56           ; signature
;                 .byte $02               ; slot count
;                 .byte $01               ; first slot
;                 .addr BOOT              ; execute address
;                 .word $0001             ; version
;                 .word $0000             ; kernel
;                 .null 'Fill-er Up'      ; binary name
.endif

;--------------------------------------

BOOT            ldx #$FF                ; initialize the stack
                txs

                stz IOPAGE_CTRL

                stz BACKGROUND_COLOR_R
                stz BACKGROUND_COLOR_G
                stz BACKGROUND_COLOR_B

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

                .include "data/DATA.inc"


;--------------------------------------
                .align $400
;--------------------------------------

GameFont        .include "data/FONT.inc"
GameFont_end


;--------------------------------------
                .align $100
;--------------------------------------

Palette         .include "data/PALETTE.inc"
Palette_end


;--------------------------------------
                .align $100
;--------------------------------------

Stamps          .include "data/SPRITES.inc"
Stamps_end

Playfield       .fill 86*40,$00
                .fill 10*40,$00         ; overflow to prevent screen artifacts
                .fill 240*40,$00
