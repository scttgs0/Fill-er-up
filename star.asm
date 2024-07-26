
;======================================
; Moves the star around the playfield
;--------------------------------------
; The star is rotated and plotted
; (in a player) in the VBI.
;======================================
MoveStar        .proc
                lda vStarMoveTimer      ; time to move?
                beq _movestar           ;   yes, go do it
                jmp GetStick            ;   no, get stick

_movestar       lda StarSpeed           ; set movement timer
                sta vStarMoveTimer      ; with star speed

                lda StarVertPos         ; adjust P/M coordinates to match
                sec                     ; playfield plotting coordinates.
                sbc #13                 ; TODO:
                sta StarLiteralY

                lda StarHorzPos
                sec
                sbc #44                 ; TODO:
                sta StarLiteralX

                .frsRandomByte          ; want to change the star's direction?
                cmp #240
                bcc _samedir            ;   no, use same

_newdir         .frsRandomByte          ; get random direction
                and #7
                jmp _dirchk

_samedir        lda StarDirection       ; get old direction

_dirchk         tax                     ; check to see if star will
                sta TempDirection       ; bump into any playfield object

                lda StarLiteralX
                clc
                adc StarDeltaX,X
                sta PLOTX

                lda StarLiteralY
                clc
                adc StarDeltaY,X
                sta PLOTY

                jsr PlotCalc

                ldy #0
                lda BitsOn,X
                and (LO),Y              ; any collision?
                beq _wayclear           ;   no, all clear!

                lda #15                 ; hit something,
                sta vBumpSndCount       ; start bump sound and
                bne _newdir             ; get new direction

_wayclear       lda PLOTX               ; adjust star coordinates back to
                clc                     ; p/m coordinates from playfield
                adc #44                 ; TODO:
                sta StarHorzPos

;   enforce limits
                cmp #154
                bcc _1

                lda #154
                sta StarHorzPos

_1              lda PLOTY
                clc
                adc #13                 ; TODO:
                sta StarVertPos

;   enforce limits
                cmp #84
                bcc _2

                lda #84
                sta StarVertPos

_2              lda TempDirection       ; restore direction
                sta StarDirection

                jmp GetStick            ; and loop

                .endproc
