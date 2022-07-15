;======================================
; SEARCH FOR FILLABLE AREA
;======================================
; This section searches for the area to
; be filled.  It is so complicated that
; explanation of its finer details
; would be almost impossible without
; writing another complete article.
; At any rate, it works.
;======================================
Search          .proc
                lda #1
                sta FILLON
                lda #0
                sta D
                lda STRHOR
                sec
                sbc #44
                sta SX
                lda STRHGT
                sec
                sbc #13
                sta SY
_findcl         ldx D
                lda SX
                clc
                adc SXD,X
                sta SX
                sta PLOTX
                lda SY
                clc
                adc SYD,X
                sta SY
                sta PLOTY
                jsr PlotCalc

                ldy #0
                lda (LO),Y
                and BITSON,X
                cmp COLOR1,X
                beq _findc2

                cmp COLOR2,X
                bne _findcl

                lda #0
                sta TD
                jmp _found2

_findc2         lda D
                sta TD
                jsr DECD

_fc2a           jsr SRCHLC

                cmp COLOR1,X
                bne _fc2b

                jsr GRABEM

                jmp _findc2

_fc2b           cmp COLOR2,X
                bne _fc2c

                jsr GRABEM
                jmp _outlin

_fc2c           jsr INCD
                jmp _fc2a

_found2         lda #0
                sta TRIES
                jsr DECD

_fnd2a          jsr SRCHLC

                cmp COLOR2,X
                bne _fnd2b

                jsr GRABEM
                jmp _found2

_fnd2b          lda TRIES
                clc
                adc #1
                sta TRIES
                cmp #3
                beq _findc1

                jsr INCD

                jmp _fnd2a

_findc1         lda D
                sta TD
                jsr DECD

_fc1a           jsr SRCHLC

                cmp COLOR1,X
                bne _fc1b

                jsr GRABEM

                jmp _findc2

_fc1b           jsr INCD

                jmp _fc1a

_outlin         jsr PLSXSY

                lda #0
                sta TRIES
_outla          jsr SRCHLC

                cmp COLOR1,X
                bne _outlb

                jsr GRABEM

                jmp _outlin

_outlb          lda TRIES
                clc
                adc #1
                sta TRIES
                cmp #4
                beq _outld

                jsr INCD

                jmp _outla

_outld          jsr LOCTXY

_outld2         cmp COLOR2,X
                bne _outle

                jsr FillRegion

                lda #0
                sta FILLON
                rts

_outle          jsr INCD

                jsr SRCHLC

                jmp _outld2

                .endproc


;======================================
;
;======================================
SRCHLC          .proc
                ldx TD
                lda SX
                clc
                adc SXD,X
                sta TX
                sta PLOTX
                lda SY
                clc
                adc SYD,X
                sta TY
                sta PLOTY

                .endproc

                ;[fall-through]


;======================================
;
;======================================
LOCTXY          .proc
                lda PLOTX
                cmp #159
                bcs _noread

                lda PLOTY
                cmp #85
                bcs _noread

                jsr PlotCalc

                ldy #0
                lda (LO),Y
                and BITSON,X
                rts

_noread         lda #0
                ldx #0
                rts
                .endproc


;======================================
;
;======================================
GRABEM          .proc
                lda TD
                sta D
                lda TX
                sta SX
                lda TY
                sta SY
                rts
                .endproc


;======================================
;
;======================================
INCD            .proc
                lda TD
                clc
                adc #1
                and #3
                sta TD
                rts
                .endproc


;======================================
;
;======================================
DECD            .proc
                lda TD
                sec
                sbc #1
                and #3
                sta TD
                rts
                .endproc


;======================================
;
;======================================
PLSXSY         .proc
                lda SX
                sta PLOTX
                cmp MAXX
                bcc _tminx2

                sta MAXX
                jmp _ckymm2

_tminx2         cmp MINX
                bcs _ckymm2

                sta MINX
_ckymm2         lda SY
                sta PLOTY
                cmp MAXY
                bcc _tminy2

                sta MAXY
                jmp _endmm2

_tminy2         cmp MINY
                bcs _endmm2

                sta MINY
_endmm2         jsr PlotCalc

                ldy #0
                lda BITOFF,X
                and (LO),Y
                ora COLOR2,X
                sta (LO),Y
                rts
                .endproc
