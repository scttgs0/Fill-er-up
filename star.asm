;======================================
; MOVES THE STAR AROUND THE PLAYFIELD
;--------------------------------------
; THE STAR IS ROTATED AND PLOTTED
; (IN A PLAYER) IN THE VBI.
;======================================
MoveStar        .proc
                lda vStarMoveTimer      ; time to move?
                beq _movestar           ;   yes, go do it

                jmp GetStick            ;   no, get stick

_movestar       lda StarSpeed           ; set movement timer
                sta vStarMoveTimer      ; with star speed

                lda StarVertPos         ; adjust P/M coordinates to
                sec                     ; match playfield plotting
                sbc #13                 ; coordinates.
                sta StarLiteralY

                lda StarHorzPos
                sec
                sbc #44
                sta StarLiteralX

                .randomByte             ; want to change the star's direction?
                cmp #240
                bcc _samedir            ;   no, use same.

_newdir         .randomByte             ; get random direction
                and #7
                jmp _dirchk

_samedir        lda StarDirection       ; get old direction.

_dirchk         tax                     ; check to see if star will
                sta TempDirection       ; bump into any playfield object.

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
                bne _newdir             ; get new direction.

_wayclear       lda PLOTX               ; adjust star coordinates
                clc                     ; back to p/m coordinates
                adc #44                 ; from playfield.
                sta StarHorzPos

                lda PLOTY               
                clc
                adc #13
                sta StarVertPos

                lda TempDirection       ; restore direction
                sta StarDirection

                jmp GetStick            ; and loop

                .endproc
