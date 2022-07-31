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
                ora #$30
                sta ScoreLine1,Y
                iny
                dex
                bpl _next2

                jsr RenderPanel

_XIT            rts
                .endproc


;======================================
;
;======================================
RenderPanel     .proc
                php
                .m8i8

;   reset color for two 40-char lines
                ldx #$FF
                ldy #$FF
_nextColor      inx
                iny
                cpy #$28
                beq _processText

                lda ScoreLine1Color,Y
                sta CS_COLOR_MEM_PTR+(CharResY-3)*CharResX,X
                inx
                sta CS_COLOR_MEM_PTR+(CharResY-3)*CharResX,X
                bne _nextColor

;   process the text
_processText    ldx #$FF
                ldy #$FF
_nextChar       inx
                iny
                cpy #$28
                beq _XIT

                lda ScoreLine1,Y
                cmp #$20
                beq _space

                cmp #$41
                bcc _number
                bra _letter

_space          sta CS_TEXT_MEM_PTR+(CharResY-3)*CharResX,X
                inx
                sta CS_TEXT_MEM_PTR+(CharResY-3)*CharResX,X

                bra _nextChar

;   (ascii-30)*2+$A0
_number         sec
                sbc #$30
                asl A

                clc
                adc #$A0
                sta CS_TEXT_MEM_PTR+(CharResY-3)*CharResX,X
                inx
                inc A
                sta CS_TEXT_MEM_PTR+(CharResY-3)*CharResX,X

                bra _nextChar

_letter         sta CS_TEXT_MEM_PTR+(CharResY-3)*CharResX,X
                inx
                clc
                adc #$40
                sta CS_TEXT_MEM_PTR+(CharResY-3)*CharResX,X

                bra _nextChar

_XIT            plp
                rts
                .endproc
