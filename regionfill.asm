;======================================
; FillRegion Routine
;--------------------------------------
; As with the 'Search' subroutine, the
; FillRegion subroutine is far too complex to
; explain here.  This fill is entirely
; different from the system's fill
; routine, as it will fill any shape
; that is outlined in COLOR 2.
;======================================
FillRegion      .proc
                ;lda #0                 ; turn off
                ;sta AUDC2              ; sound channels
                ;sta AUDC3              ; 2 and 3.

                lda MAXY                ; initialize
                sec                     ; the fill
                sbc MINY                ; sound
                sta FILFRQ              ; frequency.
                lda MINX
                sec
                sbc #1
                sta MINX
                sta FX
                lda MINY
                sta FY
                sec
                sbc #1
                sta MINY
                lda MAXX
                clc
                adc #1
                sta MAXX
                lda MAXY
                clc
                adc #1
                sta MAXY
                lda #0
                sta SCTALY

                .endproc


;--------------------------------------
;
;--------------------------------------
CLRC2T          .proc
                lda #0
                sta C2TALY
_next1          jsr Locate

                cmp #2
                bne _next1

_next2          inc C2TALY
                jsr Locate

                cmp #2
                beq _next2

                and #1
                bne CLRC2T

                lda C2TALY
                cmp #1
                beq _fillit

                jsr LOCPRV

                beq CLRC2T

_fillit         lda FX
                sta PLOTX
                lda FY
                sta PLOTY
                jsr PlotCalc

                ldy #0
                lda (LO),Y
                ora COLOR3,X
                sta (LO),Y
                inc SCTALY
                jsr Locate

                cmp #0
                beq _fillit

                and #1
                bne CLRC2T

                lda #1
                sta C2TALY
_follow         jsr Locate

                cmp #0
                beq _loclp3

                and #1
                bne CLRC2T

                inc C2TALY
                jmp _follow

_loclp3         lda C2TALY
                cmp #1
                bne _loclp4

                jmp CLRC2T

_loclp4         jsr LOCPRV

                cmp BITSON,X
                beq _fillit

                jmp CLRC2T

                .endproc


;======================================
;
;======================================
Locate          .proc
                lda FX
                clc
                adc #1
                sta FX
                cmp MAXX
                bne _stofx

                lda CURLO
                clc
                adc SCTALY
                sta CURLO
                lda CURHI
                adc #0
                sta CURHI
                lda #0
                sta SCTALY
                lda MINX
                sta FX
                lda #0
                sta C2TALY

                ;lda #$86               ; volume=6, distortion=4
                ;sta AUDC1

                lda FILFRQ              ; variable frequency
                ;sta AUDF1
                beq _noffdc

                dec FILFRQ
_noffdc         lda FY
                clc
                adc #1
                sta FY
                cmp MAXY
                beq _filend

                lda FX
                cmp MINX
                bne _stofx

                pla
                pla
                jmp CLRC2T

_filend         pla
                pla
                rts

_stofx          lda FX
                sta PLOTX
                lda FY
                sta PLOTY
                jsr PlotCalc

                ldy #0
                lda BITSON,X
                and (LO),Y
                cmp COLOR2,X
                bne _notc2

                lda BITSON,X
                ora (LO),Y
                sta (LO),Y
                inc SCTALY
                lda #2
                rts

_notc2          cmp COLOR1,X
                bne _notc1

                lda #1
                rts

_notc1          cmp #0
                bne _c3

                rts

_c3             lda #3
                rts
                .endproc


;======================================
;
;======================================
LOCPRV          .proc
                lda FX
                sta PLOTX
                lda FY
                sec
                sbc #1
                cmp MINY
                beq _nolocp

                sta PLOTY
                jsr PlotCalc

                ldy #0
                lda BITSON,X
                and (LO),Y
                rts

_nolocp         lda #0
                ldx #0
                rts
                .endproc
