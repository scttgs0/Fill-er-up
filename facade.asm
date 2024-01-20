
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

                pha

;   reset to the top of the screen buffer
                lda #<Screen16K         ; Set the source address
                sta zpDest
                lda #>Screen16K         ; Set the source address
                sta zpDest+1

                pla
                bra _next2

_XIT
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
                pha
                phx
                phy

                stz zpIndex1            ; source pointer, range[0:255]
                stz zpIndex2            ; dest pointer, range[0:255]
                stz zpIndex3            ; source byte counter, range[0:40]

_next1          ldy zpIndex1
                lda (zpSource),Y
                inc zpIndex3            ; increment the byte counter
                inc zpIndex1            ; increment the source pointer
                bne _1

                inc zpSource+1

_1              ldx #3
_nextPixel      stz zpTemp1             ; extract 2-bit pixel color
                asl
                rol zpTemp1
                asl
                rol zpTemp1
                pha                     ; preserve

                ;lda zpTemp1    ; HACK:
                lda BlitLines   ; HACK:     color the line so we can analyze the render
                ;and #1         ; HACK:
                ldy zpIndex2
                sta (zpDest),Y
                sta (zpDest2),Y         ; double-height

                iny
                sta (zpDest),Y          ; double-pixel
                sta (zpDest2),Y         ; double-height

                iny
                sty zpIndex2            ; update the dest pointer
                bne _2

                inc zpDest+1
                inc zpDest2+1

_2              pla                     ; restore

                dex
                bpl _nextPixel

                ldx zpIndex3
                cpx #40                 ; <40?
                bcc _next1              ;   yes

;   we completed a line
                stz zpIndex3            ;   no, clear the byte counter
                dec BlitLines           ; one less line to process
                beq _XIT                ; exit when zero lines remain

;   skip the next line since it is already rendered
                lda zpDest
                clc
                adc #$40
                sta zpDest
                lda zpDest+1
                adc #$01
                sta zpDest+1

                lda zpDest2
                clc
                adc #$40
                sta zpDest2
                lda zpDest2+1
                adc #$01
                sta zpDest2+1

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

                ldy #$05                ; perform 5 block-copy operations
                ldx #$00
                stx _index

_nextBank       ;phx                     ; preserve
                ldx _index

                lda _data_count,X
                sta BlitLines

                lda _data_MMUslot,X
                sta MMU_Block3
                inc A
                sta MMU_Block4

                ;plx                     ; restore

                inc _index

                lda _data_Source,X      ; Set the source address
                sta zpSource
                lda _data_Source+1,X    ; Set the source address
                sta zpSource+1

                lda _data_Dest,X        ; Set the destination address
                sta zpDest
                lda _data_Dest+1,X
                sta zpDest+1

                lda _data_Dest2,X        ; Set the destination2 address (double-height lines)
                sta zpDest2
                lda _data_Dest2+1,X
                sta zpDest2+1

                jsr SetScreenRAM

                ;inx
                ;inx
                dey
                bne _nextBank

;   restore IOPAGE control
                pla
                sta IOPAGE_CTRL

                ply
                plx
                pla
                rts

;--------------------------------------

_data_Source    .word Playfield
                .word Playfield+$03C0
                .word Playfield+$05F0
                .word Playfield+$07F8
                .word Playfield+$0A00

_data_Dest      .word Screen16K
                .word Screen16K+$1C00
                .word Screen16K+$1F00
                .word Screen16K+$1F80
                .word Screen16K

_data_Dest2     .word Screen16K+320
                .word Screen16K+$1C00+320
                .word Screen16K+$1F00+320
                .word Screen16K+$1F80+320
                .word Screen16K+320

_data_count     .byte 24,14,13,13,24        ; # of lines to draw

_data_MMUslot   .byte $10,$11,$12,$13,$15

_index          .byte ?
                .endproc
