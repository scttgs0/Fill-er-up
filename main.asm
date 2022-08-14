;--------------------------------------
; Start of Code
;--------------------------------------
START           .proc
                jsr Random_Seed

                .frsGraphics mcTextOn|mcOverlayOn|mcGraphicsOn|mcBitmapOn|mcSpriteOn,mcVideoMode320
                .frsMouse_off
                .frsBorder_off

                jsr InitLUT
                jsr InitCharLUT

                lda #<CharResX
                sta COLS_PER_LINE
                lda #>CharResX
                sta COLS_PER_LINE+1
                lda #CharResX
                sta COLS_VISIBLE

                lda #<CharResY
                sta LINES_MAX
                lda #>CharResY
                sta LINES_MAX+1
                lda #CharResY
                sta LINES_VISIBLE

                jsr SetFont
                jsr ClearScreen

                jsr InitSID             ; init sounds

                lda #TRUE               ; don't show player or star
                sta isHidePlayer        ; we still must clear P/M area
                sta isFillOn

                lda #FALSE
                sta isGameOver

                jsr InitBitmap
                jsr InitSprites
                jsr SpritesClear

                lda #64                 ; and set up the star's vertical and horizontal position
                sta StarVertPos
                lda #128
                sta StarHorzPos

                lda #$30                ; now let's zero out the score areas!
                ldx #4                  ; 5-digit values
_zerogoal       sta panelTarget,X
                sta panelCurrent,X
                dex
                bpl _zerogoal

                ldx #5                  ; 6-digit value
_zeroscore      sta panelScore,X
                dex
                bpl _zeroscore

                lda #FALSE              ; these items must be set to zero on startup or
                sta isFillOn            ; else we'll wind up with nasty things happening!
                sta isDead
                sta isPreventColorChange
                ;sta HITCLR             ; clear collisions
                ;sta NMIEN              ; disable interrupts
                sta hasDrawn

                ldx #5                  ; let's zero out the score counter...
_CMSLP          sta SCORE,X
                dex
                bpl _CMSLP

                sta LEVEL               ; and level #!

                lda #3                  ; we start with 3 lives
                sta LIVES
                ora #$30                ; convert to ascii
                sta panelLives          ; and put them in the score line

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

                jsr InitIRQs

                lda JIFFYCLOCK          ; initialize the player color clock
                clc
                adc #4
                sta zpPlayerColorClock

                jmp ClearDisplay

                .endproc
