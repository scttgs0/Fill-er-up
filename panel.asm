;======================================
; 2-BYTE DECIMAL CONVERTER
;--------------------------------------
; Converts a 2-byte binary number to a
; 5-byte decimal number.  Will place
; the decimal number in ScoreLine1 if
; desired (SLLOC determines position).
;======================================
ConvertDecimal  .proc
                ldx #4
                lda #0
_next1          sta DECIMAL,X
                dex
                bpl _next1

                ldx #4
_ckmag          lda HIWK
                cmp HIVALS,X
                beq _1

                bcs _subem

                bcc _nosub

_1              lda LOWK
                cmp LOVALS,X
                bcs _subem

_nosub          dex
                bpl _ckmag

                jmp _showit

_subem          lda LOWK
                sec
                sbc LOVALS,X
                sta LOWK
                lda HIWK
                sbc HIVALS,X
                sta HIWK
                inc DECIMAL,X
                jmp _ckmag

_showit         ldx #$4
                ldy SLLOC
                bmi _XIT

_next2          lda DECIMAL,X
                ora #$D0
                sta ScoreLine1,Y
                iny
                dex
                bpl _next2

_XIT            rts
                .endproc
