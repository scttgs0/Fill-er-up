
; SPDX-FileName: platform_f256jr.asm
; SPDX-FileCopyrightText: Copyright 2023, Scott Giese
; SPDX-License-Identifier: GPL-3.0-or-later


;======================================
; Unpack the playfield into Screen RAM
;======================================
SetScreenRAM    .proc
                pha
                phx
                phy

                lda #<Screen16K          ; Set the destination address
                sta zpDest
                lda #>Screen16K          ; Set the destination address
                sta zpDest+1
                lda #`Screen16K
                sta zpDest+2

                stz zpTemp2     ; HACK:

                ;--.i16
                ldx #0
                stx zpIndex1
                stx zpIndex2
                stx zpIndex3

_nextByte       ldy zpIndex1
                lda [zpSource],Y

                inc zpIndex1            ; increment the byte counter (source pointer)
                bne _1

                inc zpIndex1+1

_1              inc zpIndex3            ; increment the column counter

                ldx #3
_nextPixel      stz zpTemp1             ; extract 2-bit pixel color
                asl
                rol zpTemp1
                asl
                rol zpTemp1
                pha

                lda zpTemp1
                ldy zpIndex2
                sta [zpDest],Y

;   duplicate this in the next line down (double-height)
                phy
                pha
                ;--.m16
                tya
                clc
                adc #320
                tay
                ;--.m8
                pla
                sta [zpDest],Y          ; double-height
                ply
;---

                iny
                sta [zpDest],Y          ; double-pixel

;   duplicate this in the next line down (double-height)
                phy
                pha
                ;--.m16
                tya
                clc
                adc #320
                tay
                ;--.m8
                pla
                sta [zpDest],Y          ; double-height
                ply
;---

                iny
                sty zpIndex2
                pla

                dex
                bpl _nextPixel

                ldx zpIndex3
                cpx #40
                bcc _checkEnd

                inc zpTemp2     ; HACK: exit criterian
                lda zpTemp2
                cmp #12
                beq _XIT

                ;--.m16
                lda zpIndex2            ; we already processed the next line (double-height)...
                clc
                adc #320                ; so move down one additional line
                sta zpIndex2

                lda #0
                sta zpIndex3            ; reset the column counter
                ;--.m8

_checkEnd       ldx zpIndex1
                cpx #$1E0               ; 12 source lines (40 bytes/line)... = 24 destination lines (~8K)
                bcc _nextByte

_XIT            ;--.i8

                ply
                plx
                pla
                rts
                .endproc


;======================================
;
;======================================
ClearScreenRam  .proc
                pha
                phx
                phy

;   switch to system map
                stz IOPAGE_CTRL

;   enable edit mode
                lda MMU_CTRL
                ora #mmuEditMode
                sta MMU_CTRL

                lda #$08                ; [6000:7FFF]->[1_0000:1_1FFF]
                sta MMU_Block3
                inc A                   ; [8000:9FFF]->[1_2000:1_3FFF]
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

                pha

;   reset to the top of the screen buffer
                lda #<Screen16K         ; Set the source address
                sta zpDest
                lda #>Screen16K         ; Set the source address
                sta zpDest+1

                pla
                bra _next2

_XIT            
;   disable edit mode
                lda MMU_CTRL
                and #~mmuEditMode
                sta MMU_CTRL

                ply
                plx
                pla
                rts
                .endproc


;======================================
;
;======================================
BlitScreenRam    .proc
                pha

                lda #<$1E00             ; 24 lines (320 bytes/line)
                sta zpSize
                lda #>$1E00             ; 24 lines (320 bytes/line)
                sta zpSize+1
                stz zpSize+2

                lda #<Screen16K         ; Set the source address
                sta zpSource
                lda #>Screen16K         ; Set the source address
                sta zpSource+1
                stz zpSource+2

                jsr Copy2VRAM

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

                ldy #7                  ; 8 chuncks of 24 lines
                ldx #0

_nextBank       lda _data_Source,X      ; Set the source address
                sta zpSource
                lda _data_Source+1,X    ; Set the source address
                sta zpSource+1
                lda _data_Source+2,X
                sta zpSource+2

                jsr SetScreenRAM

                lda _data_Dest,X        ; Set the destination address
                sta zpDest
                lda _data_Dest+1,X      ; Set the destination address
                sta zpDest+1
                lda _data_Dest+2,X
                sta zpDest+2

                phx
                phy
                jsr BlitScreenRam
                ply
                plx

                inx
                inx
                inx
                dey
                bpl _nextBank

                ply
                plx
                pla
                rts

;--------------------------------------

_data_Source    .long Playfield+$0000,Playfield+$01E0
                .long Playfield+$03C0,Playfield+$05A0
                .long Playfield+$0780,Playfield+$0960
                .long Playfield+$0B40,Playfield+$0D20

_data_Dest      .long Screen16K
                .long Screen16K+$2000

                .endproc
