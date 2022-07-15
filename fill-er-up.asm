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


;--------------------------------------
; Start of Code
;--------------------------------------
START           .proc
                .frsGraphics mcGraphicsOn|mcSpriteOn,mcVideoMode320
                .frsMouse_off
                .frsBorder_off

                ;jsr SIOINV              ; init sounds

;   5th-player, player > playfield > background
                ;lda #$11                ; P/M priority
                ;sta GPRIOR

                lda #1                  ; don't show player or star
                sta SHOOFF              ; we still must clear P/M area
                sta FILLON
                jsr SpritesClear

                lda #64                 ; and set up the star's height and horizontal position
                sta STRHGT
                lda #128
                sta STRHOR

                lda #$D0                ; now let's zero out the score areas!
                ldx #4
ZSCLP           sta ScoreLine1+4,X
                sta ScoreLine1+15,X
                dex
                bpl ZSCLP

                ldx #5
ZSCLP2          sta ScoreLine2+12,X
                dex
                bpl ZSCLP2

                lda #0                  ; these items must be set to zero on startup or
                sta FILLON              ; else we'll wind up with nasty things happening!
                sta DEADFG
                sta NOCCHG
                ;sta HITCLR             ; clear collisions
                ;sta DMACTL             ; turn off the screen
                ;sta NMIEN              ; disable interrupts
                sta HASDRN
                ;sta AUDCTL             ; reset POKEY

                ldx #5                  ; let's zero out the score counter...
CMSLP           sta SCORE,X
                dex
                bpl CMSLP

                sta LEVEL               ; and level #!

                lda #3                  ; we start with 3 lives
                sta LIVES

                ora #$90                ; and put them in the score line
                sta ScoreLine2+19

                ;lda #$0A               ; next we set up the colors we want to use.
                ;sta COLPF0
                ;lda #$24
                ;sta COLPF1
                ;lda #$94
                ;sta COLPF2
                ;lda #$C4
                ;sta COLPF3
                ;lda #0
                ;sta COLBK
                ;lda #$76
                ;sta COLPM3
                ;lda #$34
                ;sta COLPM0

                ;lda #<DLIST          	; we'd better tell the computer where our display list is located!
                ;sta DLISTL
                ;lda #>DLIST
                ;sta DLISTL+1

                ;lda #6
                ;ldy #<Interrupt_VBI    ; tell where the vertical blank interrupt is
                ;ldx #>Interrupt_VBI
                ;jsr SETVBV             ; and set it!

                ;lda #>PMAREA           ; here's our P/M graphics area!
                ;sta PMBASE

                ;lda #$2E               ; turn on the DMA control
                ;sta DMACTL             ; dma instruction fetch, P/M DMA, standard playfield

                ;lda #$3                ; ... and graphics control!
                ;sta GRACTL             ; turn on P/M

                ;lda #$40               ; enable VBI
                ;sta NMIEN

                jmp ClearDisplay

                .endproc


;--------------------------------------
;--------------------------------------

                .include "SPRITE_player.asm"
                .include "panel.asm"
                .include "SPRITE_star.asm"
                .include "search.asm"
                .include "regionfill.asm"
                .include "interrupt.asm"
                .include "DATA.asm"


;--------------------------------------
                .align $100
;--------------------------------------

                .include "FONT.asm"
