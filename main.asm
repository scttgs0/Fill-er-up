;--------------------------------------
; Start of Code
;--------------------------------------
START           .proc
                .frsGraphics mcTextOn|mcOverlayOn|mcGraphicsOn|mcSpriteOn,mcVideoMode320
                .frsMouse_off
                .frsBorder_off

                jsr InitLUT
                ;jsr InitCharLUT
                jsr InitSprites

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

                jsr ClearScreen

                jsr InitSID             ; init sounds

;   5th-player, player > playfield > background
                ;lda #$11               ; P/M priority
                ;sta GPRIOR

                lda #1                  ; don't show player or star
                sta SHOOFF              ; we still must clear P/M area
                sta isFillOn
                jsr SpritesClear

                lda #64                 ; and set up the star's height and horizontal position
                sta vStarHeight
                lda #128
                sta STRHOR

                lda #$30                ; now let's zero out the score areas!
                ldx #4                  ; 5-digit values
ZSCLP           sta panelTarget,X
                sta panelCurrent,X
                dex
                bpl ZSCLP

                ldx #5
ZSCLP2          sta panelScore,X
                dex
                bpl ZSCLP2

                lda #0                  ; these items must be set to zero on startup or
                sta isFillOn            ; else we'll wind up with nasty things happening!
                sta isDead
                sta NOCCHG
                ;sta HITCLR             ; clear collisions
                ;sta DMACTL             ; turn off the screen
                ;sta NMIEN              ; disable interrupts
                sta HASDRN

                ldx #5                  ; let's zero out the score counter...
CMSLP           sta SCORE,X
                dex
                bpl CMSLP

                sta LEVEL               ; and level #!

                lda #3                  ; we start with 3 lives
                sta LIVES
                ora #$30                ; add color
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

                ;lda #<DLIST          	; we'd better tell the computer where our display list is located!
                ;sta DLISTL
                ;lda #>DLIST
                ;sta DLISTL+1

                ;lda #6
                ;ldy #<Interrupt_VBI    ; tell where the vertical blank interrupt is
                ;ldx #>Interrupt_VBI
                ;jsr SETVBV             ; and set it!

                ;lda #$2E               ; turn on the DMA control
                ;sta DMACTL             ; dma instruction fetch, P/M DMA, standard playfield

                ;lda #$3                ; ... and graphics control!
                ;sta GRACTL             ; turn on P/M

                ;lda #$40               ; enable VBI
                ;sta NMIEN

                jmp ClearDisplay

                .endproc
