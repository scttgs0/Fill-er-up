
; SPDX-FileName: facade.asm
; SPDX-FileCopyrightText: Copyright 2023, Scott Giese
; SPDX-License-Identifier: GPL-3.0-or-later


;======================================
;
;======================================
ClearScreenRAM  .proc
                pha
                phx
                phy

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

;   ensure edit mode
                lda MMU_CTRL
                pha                     ; preserve
                ora #mmuEditMode
                sta MMU_CTRL

                lda #$10                ; [6000:7FFF]->[2_0000:2_1FFF]
                sta MMU_Block3
                inc A                   ; [8000:9FFF]->[2_2000:2_3FFF]
                sta MMU_Block4

                lda #<Screen16K         ; Set the source address
                sta zpDest
                lda #>Screen16K         ; Set the source address
                sta zpDest+1

                lda #$05                ; quantity of buffer fills (16k/interation)
                sta zpIndex1

                lda #$00
_next2          ldx #$40                ; quantity of pages (16k total)
                ldy #$00
_next1          sta (zpDest),Y

                dey
                bne _next1

                inc zpDest+1

                dex
                bne _next1

                dec zpIndex1
                beq _XIT

                inc MMU_Block3
                inc MMU_Block3
                inc MMU_Block4
                inc MMU_Block4

;   reset to the top of the screen buffer
                pha
                lda #<Screen16K         ; Set the source address
                sta zpDest
                lda #>Screen16K         ; Set the source address
                sta zpDest+1
                pla

                bra _next2

_XIT
;   restore MMU control
                pla
                sta MMU_CTRL

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                ply
                plx
                pla
                rts
                .endproc


;======================================
; Unpack the playfield into Screen RAM
;--------------------------------------
; 24 lines will fit within a slot
;   slot=$2000, 24-lines=$1E00
; double-lines w/in 2-slots
;   =$3C00 (of $4000)
; we then reset the Screen16K buffers
; (one position) to resume at:
;   =slot+($3C00-$2000)
;   =$6000+1C00... =$7C00
; space available is $A000-7C00=$2400
;   14 lines will fit within $2400 bytes
;   14*2*320=$2300
; - - - - - - - - - - - - - - - - - - -
; we intend to resume at line 48 (=24*2)
;   =48*320, =$3C00
;   =$3C00-$2000,.. =$1C00
;   =$6000+$1C00... =$7C00
; - - - - - - - - - - - - - - - - - - -
; - - - - - - - - - - - - - - - - - - -
; we intend to resume at line 76 (=48+14*2)
;   =76*320, =$5F00
;   =$5F00-$4000, =$1F00
;   =$6000+1F00... =$7F00
; space available is $A000-7F00=$2100
;   13 lines will fit within $2100 bytes
;   13*2*320=$2080
; - - - - - - - - - - - - - - - - - - -
; we intend to resume at line 102 (=76+13*2)
;   =102*320, =$7F80
;   =$7F80-$6000, =$1F80
;   =$6000+1F80... =$7F80
; space available is $A000-7F80=$2080
;   13 lines will fit within $2080 bytes
;   13*2*320=$2080
; - - - - - - - - - - - - - - - - - - -
; we intend to resume at line 128 (=102+13*2)
;   =128*320, =$A000
;   =$A000-$A000, =$0000
;   =$6000+0000... =$6000
; space available is $A000-6000=$4000
;   24 lines will fit within $4000 bytes
;   24*2*320=$3C00
;--------------------------------------
; - - - - - - - - - - - - - - - - - - -
; we intend to resume at line 176 (=128+24*2)
;   =176*320, =$DC00
;   =$DC00-$C000, =$1C00
;   =$6000+1C00... =$7C00
; space available is $A000-7C00=$2400
;   14 lines will fit within $2400 bytes
;   14*2*320=$2300
; - - - - - - - - - - - - - - - - - - -
; we intend to resume at line 204 (-176+14*2)
;   =204*320, =$FF00
;   =$FF00-$E000, =$1F00
;   =$6000+1F00... =$7F00
; space available is $A000-7F00=$2100
;   13 lines will fit within $2100 bytes
;   13*2*320=$2080
; - - - - - - - - - - - - - - - - - - -
; we intend to resume at line 230 (=204+13*2)
;   =230*320, =$11F80
;   =$11F80-$10000, =$1F80
;   =$6000+1F80... =$7F80
; - - - - - - - - - - - - - - - - - - -
; we're done @ line 256
;======================================
SetScreenRAM    .proc
zpSRCidx        .var zpIndex1           ; source pointer, range[0:255]
zpDSTidx        .var zpIndex2           ; dest pointer, range[0:255]
zpRowBytes      .var zpIndex3           ; source byte counter, range[0:39]
;---

                pha
                phx
                phy

                lda zpPFDest
                sta zpPFDest_cache
                lda zpPFDest+1
                sta zpPFDest_cache+1
                lda zpPFDest2
                sta zpPFDest2_cache
                lda zpPFDest2+1
                sta zpPFDest2_cache+1

                stz zpSRCidx
                stz zpDSTidx
                stz zpRowBytes

_next1          ldy zpSRCidx
                lda (zpPFSource),Y
                inc zpRowBytes          ; increment the byte counter
                inc zpSRCidx            ; increment the source pointer
                bne _1

                inc zpPFSource+1

_1              ldx #3
_nextPixel      stz zpTemp1             ; extract 2-bit pixel color
                asl
                rol zpTemp1
                asl
                rol zpTemp1
                pha                     ; preserve

                lda zpTemp1
                ;lda nBlitLines  ; HACK:     color the line so we can analyze the render
                ;and #15         ; HACK:
                ;clc             ; HACK:
                ;adc #15         ; HACK:

                ldy zpDSTidx
                sta (zpPFDest),Y
                sta (zpPFDest2),Y       ; double-height

                iny
                sta (zpPFDest),Y        ; double-pixel
                sta (zpPFDest2),Y       ; double-height

                iny
                sty zpDSTidx            ; update the dest pointer
                bne _2

                inc zpPFDest+1
                inc zpPFDest2+1

_2              pla                     ; restore

                dex
                bpl _nextPixel

                ldx zpRowBytes
                cpx #40                 ; <40?
                bcc _next1              ;   yes

;   we completed a line
                stz zpRowBytes          ;   no, clear the byte counter
                dec nBlitLines          ; one less line to process
                beq _XIT                ; exit when zero lines remain

;   skip the next line since it is already rendered
                lda zpPFDest_cache
                clc
                adc #<$280
                sta zpPFDest
                sta zpPFDest_cache
                lda zpPFDest_cache+1
                adc #>$280
                sta zpPFDest+1
                sta zpPFDest_cache+1

                lda zpPFDest2_cache
                clc
                adc #<$280
                sta zpPFDest2
                sta zpPFDest2_cache
                lda zpPFDest2_cache+1
                adc #>$280
                sta zpPFDest2+1
                sta zpPFDest2_cache+1

                stz zpDSTidx
                bra _next1

_XIT            ply
                plx
                pla
                rts
                .endproc


;======================================
;
;======================================
BlitPlayfield   .proc
                pha
                phx
                phy

;   preserve IOPAGE control
                lda IOPAGE_CTRL
                pha

;   switch to system map
                stz IOPAGE_CTRL

;   ensure edit mode
                lda MMU_CTRL
                pha                     ; preserve
                ora #mmuEditMode
                sta MMU_CTRL

                ldy #$06                ; perform 5 block-copy operations
                stz _index

_nextBank       ldx _index
                inc _index

                lda _data_count,X
                sta nBlitLines

                lda _data_MMUslot,X
                sta MMU_Block3
                inc A
                sta MMU_Block4

                txa                     ; convert to WORD index
                asl
                tax

                lda _data_Source,X      ; set the source address
                sta zpPFSource
                lda _data_Source+1,X
                sta zpPFSource+1

                lda _data_Dest,X        ; set the destination address
                sta zpPFDest
                lda _data_Dest+1,X
                sta zpPFDest+1

                lda _data_Dest2,X       ; set the destination2 address (double-height lines)
                sta zpPFDest2
                lda _data_Dest2+1,X
                sta zpPFDest2+1

                jsr SetScreenRAM

                dey
                bne _nextBank

;   restore MMU control
                pla
                sta MMU_CTRL

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                ply
                plx
                pla
                rts

;--------------------------------------

_data_Source    .word Playfield
                .word Playfield+$01E0
                .word Playfield+$0410
                .word Playfield+$0618
                .word Playfield+$0820
                .word Playfield+$0BE0

_data_Dest      .word Screen16K+$1E00
                .word Screen16K+$1C00
                .word Screen16K+$1F00
                .word Screen16K+$1F80
                .word Screen16K
                .word Screen16K+$1C00

_data_Dest2     .word Screen16K+320+$1E00
                .word Screen16K+320+$1C00
                .word Screen16K+320+$1F00
                .word Screen16K+320+$1F80
                .word Screen16K+320
                .word Screen16K+320+$1C00

_data_count     .byte 12,14,13,13,24,9      ; # of lines to draw

_data_MMUslot   .byte $10,$11,$12,$13,$15,$16

_index          .byte ?

tblRowPTR       .word $0010,$1E00       ; 12 lines; bank $10
                .word $0010,$2080
                .word $0010,$2300
                .word $0010,$2580
                .word $0010,$2800
                .word $0010,$2A80
                .word $0010,$2D00
                .word $0010,$2F80
                .word $0010,$3200
                .word $0010,$3480
                .word $0010,$3700
                .word $0010,$3980

                .word $0011,$1C00       ; 14 lines; bank $11
                .word $0011,$1E80
                .word $0011,$2100
                .word $0011,$2380
                .word $0011,$2600
                .word $0011,$2880
                .word $0011,$2B00
                .word $0011,$2D80
                .word $0011,$3000
                .word $0011,$3280
                .word $0011,$3500
                .word $0011,$3780
                .word $0011,$3A00
                .word $0011,$3C80

                .word $0012,$1F00       ; 13 lines; bank $12
                .word $0012,$2180
                .word $0012,$2400
                .word $0012,$2680
                .word $0012,$2900
                .word $0012,$2B80
                .word $0012,$2E00
                .word $0012,$3080
                .word $0012,$3300
                .word $0012,$3580
                .word $0012,$3800
                .word $0012,$3A80
                .word $0012,$3D00

                .word $0013,$1F80       ; 13 lines; bank $13
                .word $0013,$2200
                .word $0013,$2480
                .word $0013,$2700
                .word $0013,$2980
                .word $0013,$2C00
                .word $0013,$2E80
                .word $0013,$3100
                .word $0013,$3380
                .word $0013,$3600
                .word $0013,$3880
                .word $0013,$3B00
                .word $0013,$3D80

                .word $0015,$0000       ; 24 lines; bank $15
                .word $0015,$0280
                .word $0015,$0500
                .word $0015,$0780
                .word $0015,$0A00
                .word $0015,$0C80
                .word $0015,$0F00
                .word $0015,$1180
                .word $0015,$1400
                .word $0015,$1680
                .word $0015,$1900
                .word $0015,$1B80
                .word $0015,$1E00
                .word $0015,$2080
                .word $0015,$2300
                .word $0015,$2580
                .word $0015,$2800
                .word $0015,$2A80
                .word $0015,$2D00
                .word $0015,$2F80
                .word $0015,$3200
                .word $0015,$3480
                .word $0015,$3700
                .word $0015,$3980

                .word $0016,$1C00       ; 9 lines; bank $16
                .word $0016,$1E80
                .word $0016,$2100
                .word $0016,$2380
                .word $0016,$2600
                .word $0016,$2880
                .word $0016,$2B00
                .word $0016,$2D80
                .word $0016,$3000
                .endproc
