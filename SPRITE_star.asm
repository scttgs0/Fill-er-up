;======================================
; MOVES THE STAR AROUND THE PLAYFIELD
;--------------------------------------
; THE STAR IS ROTATED AND PLOTTED
; (IN A PLAYER) IN THE VBI.
;======================================
MoveStar        .proc
                lda SMTIM               ; time to move?
                beq _mstr               ; yes, go do it

                jmp GetStick            ; no, get stick

_mstr           lda STRSPD              ; set movement timer
                sta SMTIM               ; with star speed
                lda STRHGT              ; adjust p/m
                sec                     ; coordinates to
                sbc #13                 ; match playfield
                sta STRLY               ; plotting
                lda STRHOR              ; coordinates.
                sec
                sbc #44
                sta STRLX
                lda SID_RANDOM          ; want to change
                cmp #240                ; the star's direction?
                bcc _samstd             ; no, use same.

_newdir         lda SID_RANDOM          ; get random
                and #7                  ; direction
                jmp _dirchk

_samstd         lda STRDIR              ; get old direction.
_dirchk         tax                     ; check to see
                sta TMPDIR              ; if star will
                lda STRLX               ; bump into any
                clc                     ; playfield
                adc STRDTX,X            ; object.
                sta PLOTX
                lda STRLY
                clc
                adc STRDTY,X
                sta PLOTY
                jsr PlotCalc

                ldy #0
                lda BITSON,X
                and (LO),Y              ; any collision?
                beq _wayclr             ; no, all clear!

                lda #15                 ; hit something,
                sta BSCNT               ; start bump sound and
                bne _newdir             ; get new direction.

_wayclr         lda PLOTX               ; adjust star
                clc                     ; coordinates
                adc #44                 ; back to p/m
                sta STRHOR              ; coordinates
                lda PLOTY               ; from playfield.
                clc
                adc #13
                sta STRHGT
                lda TMPDIR              ; set direction
                sta STRDIR
                jmp GetStick            ; and loop

                .endproc
