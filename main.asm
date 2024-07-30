
;--------------------------------------
;--------------------------------------
; Start of Code
;--------------------------------------
;--------------------------------------
START           .proc
                sei
                jsr InitCPUVectors
                jsr InitMMU
                jsr InitIRQs
                cli

                lda #TRUE               ; don't show player or star
                sta isHidePlayer        ; we still must clear P/M area
                sta isFillOn

                lda #FALSE
                sta isGameOver

                jsr RandomSeedQuick

                .frsGraphics mcTextOn|mcOverlayOn|mcGraphicsOn|mcBitmapOn|mcSpriteOn,mcVideoMode240|mcTextDoubleX|mcTextDoubleY
                .frsMouse_off
                .frsCursor 0
                .frsBorder_off

                stz BITMAP0_CTRL        ; disable all bitmaps
                stz BITMAP1_CTRL
                stz BITMAP2_CTRL
                stz LAYER_ORDER_CTRL_0
                stz LAYER_ORDER_CTRL_1

                jsr InitGfxPalette
                jsr InitTextPalette
                jsr SetFont
                jsr ClearScreen

                jsr InitSID             ; init sounds

                jsr ClearScreenRAM
                jsr InitBitmap
                jsr InitSprites

                lda #64                 ; and set up the star's vertical and horizontal position
                sta StarVertPos
                lda #128
                sta StarHorzPos

                lda #$30                ; now let's zero out the score areas!
                ldx #4                  ; 5-digit values
_zeroGoal       sta panelTarget,X
                sta panelCurrent,X
                dex
                bpl _zeroGoal

                ldx #5                  ; 6-digit value
_zeroScore      sta panelScore,X
                dex
                bpl _zeroScore

                lda #FALSE              ; these items must be set to zero on startup or
                sta isFillOn            ; else we'll wind up with nasty things happening!
                sta isDead
                sta isPreventColorChange
                ;!! sta HITCLR             ; clear collisions
                ;!! sta NMIEN              ; disable interrupts
                sta hasDrawn

                ldx #5                  ; let's zero out the score counter...
_zeroScoreVal   sta SCORE,X
                dex
                bpl _zeroScoreVal

                sta LEVEL               ; and level #!

                lda #3                  ; we start with 3 lives
                sta LIVES
                ora #$30                ; convert to ascii
                sta panelLives          ; and put them in the score line

                lda JIFFYCLOCK          ; initialize the player color clock
                clc
                adc #4
                sta zpPlayerColorClock

                jmp ClearDisplay

                .endproc
