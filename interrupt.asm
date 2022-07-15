;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; VBI ROUTINE
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Interrupt_VBI   lda KEYCHAR             ; is space bar
                cmp #$21                ; pressed?
                bne _nopres             ; no, check for pause.

                lda #$FF                ; clear out
                sta KEYCHAR             ; key code,
                lda PAUSE               ; complement
                eor #$FF                ; the pause
                sta PAUSE               ; flag.
_nopres         lda PAUSE               ; are we paused?
                beq _nopaus             ; no!

                rti                     ; paused, no vbi!

_nopaus         lda BSCNT               ; more bump sound?
                bmi _nobs               ; no, process timer.

                ;ora #$A0               ; mix volume with
                ;sta AUDC4              ; pure tone,

                ;lda #$80               ; set up bump
                ;sta AUDF4              ; sound frequency
                dec BSCNT               ; and decrement count.
_nobs           lda TIMER               ; timer down to zero?
                beq _nodec              ; yes, don't decrement.

                dec TIMER               ; decrement timer.
_nodec          lda FILLON              ; are we filling?
                beq _nofill             ; no, do rest of vbi.

                rti                     ; yes, exit vbi

_nofill         lda #0                  ; clear out
                sta DEADFG              ; dead flag

                ;lda P0PL               ; has player 0
                ;and #$08               ; hit player 3?
                ;beq _nohitp            ; no!
                bra _nohitp  ; HACK:

                inc DEADFG              ; yes!!!
_nohitp         ;lda P0PF               ; has player 0
                ;and #$02               ; hit color 2?
                ;beq _nohitl            ; no!
                bra _nohitl ; HACK:

                inc DEADFG              ; yes!!!
_nohitl         ;sta HITCLR             ; clear collisions
                lda MOVTIM              ; movement timer zero?
                beq _nomdec             ; yes, don't decrement.

                dec MOVTIM              ; decrement timer.
_nomdec         lda SMTIM               ; star move timer zero?
                beq _nmtdec             ; yes, don't decrement.

                dec SMTIM               ; decrement timer.
_nmtdec         lda STARCT              ; star rot. timer zero?
                beq _starot             ; yes, rotate star!

                dec STARCT              ; decrement timer
                jmp _vbrest             ; and skip rotation.

_starot         lda #1                  ; set rot. timer
                sta STARCT              ; to 1
                lda STRPOS              ; increment
                clc                     ; star rotation
                adc #1                  ; counter,
                cmp #7                  ; allow only 0-6.
                bne _stostp             ; rot. count ok

                lda #0                  ; zero rot. counter.
_stostp         sta STRPOS              ; save rot. pos.
_vbrest         ldy STRPOS              ; this section
                ldx STRHGT              ; draws the star
                lda #0                  ; in player 0
                sta PL0-1,X             ; memory using
                sta PL0+8,X             ; the tables
                lda STARB1,Y            ; 'starb1' thru
                sta PL0,X               ; 'starb8'.
                lda STARB2,Y
                sta PL0+1,X
                lda STARB3,Y
                sta PL0+2,X
                lda STARB4,Y
                sta PL0+3,X
                lda STARB5,Y
                sta PL0+4,X
                lda STARB6,Y
                sta PL0+5,X
                lda STARB7,Y
                sta PL0+6,X
                lda STARB8,Y
                sta PL0+7,X

                lda STRHOR              ; set star's
                sta SP00_X_POS          ; horiz. pos.

                lda SHOOFF              ; ok to show player?
                bne _XIT                ; no, exit vbi

                lda PX                  ; set player's
                clc                     ; horizontal
                adc #47                 ; position
                sta SP03_X_POS

                lda PY                  ; draw player
                clc                     ; in player 3
                adc #$10                ; memory
                tax
                lda #0
                sta PL3-3,X
                sta PL3-2,X
                sta PL3+2,X
                sta PL3+3,X
                lda #$40
                sta PL3-1,X
                sta PL3+1,X
                lda #$A0
                sta PL3,X
                lda NOCCHG              ; color change ok?
                bne _XIT                ; no, exit vbi

                ;inc COLPM3             ; yes, cycle the color.
_XIT            rti                     ; done with vbi!
