HandleIrq       .m16i16
                pha
                phx
                phy

                .m8i8
                lda @l INT_PENDING_REG1
                and #FNX1_INT00_KBD
                cmp #FNX1_INT00_KBD
                bne _1

                jsl KeyboardHandler

                lda @l INT_PENDING_REG1
                sta @l INT_PENDING_REG1

_1              lda @l INT_PENDING_REG0
                and #FNX0_INT00_SOF
                cmp #FNX0_INT00_SOF
                bne _XIT

                jsl Interrupt_VBI

                lda @l INT_PENDING_REG0
                sta @l INT_PENDING_REG0

_XIT            .m16i16
                ply
                plx
                pla

                .m8i8
HandleIrq_END   rti
                ;jmp IRQ_PRIOR


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Handle Key notifications
;--------------------------------------
;   ESC         $01/$81  press/release
;   R-Ctrl      $1D/$9D
;   Space       $39/$B9
;   F2          $3C/$BC
;   F3          $3D/$BD
;   F4          $3E/$BE
;   Up          $48/$C8
;   Left        $4B/$CB
;   Right       $4D/$CD
;   Down        $50/$D0
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
KeyboardHandler .proc
KEY_F2          = $3C                   ; Option
KEY_F3          = $3D                   ; Select
KEY_F4          = $3E                   ; Start
KEY_UP          = $48                   ; joystick alternative
KEY_LEFT        = $4B
KEY_RIGHT       = $4D
KEY_DOWN        = $50
KEY_CTRL        = $1D                   ; fire button
;---

                .m16i16
                pha
                phx
                phy

                .m8i8
                .setbank $00

                lda KBD_INPT_BUF
                pha
                sta KEYCHAR

                and #$80                ; is it a key release?
                bne _1r                 ;   yes

_1              pla                     ;   no
                pha
                cmp #KEY_F2
                bne _2

                lda CONSOL
                eor #$04
                sta CONSOL

                jmp _CleanUpXIT

_1r             pla
                pha
                cmp #KEY_F2|$80
                bne _2r

                lda CONSOL
                ora #$04
                sta CONSOL

                jmp _CleanUpXIT

_2              pla
                pha
                cmp #KEY_F3
                bne _3

                lda CONSOL
                eor #$02
                sta CONSOL

                jmp _CleanUpXIT

_2r             pla
                pha
                cmp #KEY_F3|$80
                bne _3r

                lda CONSOL
                ora #$02
                sta CONSOL

                jmp _CleanUpXIT

_3              pla
                pha
                cmp #KEY_F4
                bne _4

                lda CONSOL
                eor #$01
                sta CONSOL

                jmp _CleanUpXIT

_3r             pla
                pha
                cmp #KEY_F4|$80
                bne _4r

                lda CONSOL
                ora #$01
                sta CONSOL

                jmp _CleanUpXIT

_4              pla
                pha
                cmp #KEY_UP
                bne _5

                lda InputFlags
                bit #$01
                beq _4a

                eor #$01
                ora #$02                ; cancel KEY_DOWN
                sta InputFlags

_4a             lda #itKeyboard
                sta InputType

                jmp _CleanUpXIT

_4r             pla
                pha
                cmp #KEY_UP|$80
                bne _5r

                lda InputFlags
                ora #$01
                sta InputFlags

                jmp _CleanUpXIT

_5              pla
                pha
                cmp #KEY_DOWN
                bne _6

                lda InputFlags
                bit #$02
                beq _5a

                eor #$02
                ora #$01                ; cancel KEY_UP
                sta InputFlags

_5a             lda #itKeyboard
                sta InputType

                jmp _CleanUpXIT

_5r             pla
                pha
                cmp #KEY_DOWN|$80
                bne _6r

                lda InputFlags
                ora #$02
                sta InputFlags

                jmp _CleanUpXIT

_6              pla
                pha
                cmp #KEY_LEFT
                bne _7

                lda InputFlags
                bit #$04
                beq _6a

                eor #$04
                ora #$08                ; cancel KEY_RIGHT
                sta InputFlags

_6a             lda #itKeyboard
                sta InputType

                bra _CleanUpXIT

_6r             pla
                pha
                cmp #KEY_LEFT|$80
                bne _7r

                lda InputFlags
                ora #$04
                sta InputFlags

                bra _CleanUpXIT

_7              pla
                pha
                cmp #KEY_RIGHT
                bne _8

                lda InputFlags
                bit #$08
                beq _7a

                eor #$08
                ora #$04                ; cancel KEY_LEFT
                sta InputFlags

_7a             lda #itKeyboard
                sta InputType

                bra _CleanUpXIT

_7r             pla
                pha
                cmp #KEY_RIGHT|$80
                bne _8r

                lda InputFlags
                ora #$08
                sta InputFlags

                bra _CleanUpXIT

_8              pla
                cmp #KEY_CTRL
                bne _XIT

                lda InputFlags
                eor #$10
                sta InputFlags

                lda #itKeyboard
                sta InputType

                stz KEYCHAR
                bra _XIT

_8r             pla
                cmp #KEY_CTRL|$80
                bne _XIT

                lda InputFlags
                ora #$10
                sta InputFlags

                stz KEYCHAR
                bra _XIT

_CleanUpXIT     ;stz KEYCHAR    HACK:
                pla

_XIT            .m16i16
                ply
                plx
                pla

                .m8i8
                rtl
                .endproc


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; VBI ROUTINE
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Interrupt_VBI   lda KEYCHAR
                cmp #$21                ; is spacebar?
                bne _1                  ;   no, check for pause

                lda #$FF                ; clear key code -- (processed)
                sta KEYCHAR

                lda PAUSE               ; toggle pause state
                eor #$FF
                sta PAUSE

_1              lda PAUSE               ; are we paused?
                beq _2                  ;   no!

                rtl                     ; when paused, no VBI!

_2              lda vBumpSndCount       ; more bump sound?
                bmi _3                  ;   no, process timer

                ;ora #$A0               ; mix volume with pure-tone
                ;sta AUDC4

                ;lda #$80               ; set up bump sound frequency
                ;sta AUDF4

                dec vBumpSndCount

_3              lda TIMER               ; timer down to zero?
                beq _4                  ;   yes, don't decrement

                dec TIMER

_4              lda isFillOn            ; are we filling?
                beq _5                  ;   no, do rest of VBI

                rtl                     ; when filling, exit VBI

_5              lda #0                  ; clear out dead flag
                sta isDead

                ;lda P0PL               ; has player 0 hit player 3?
                ;and #$08
                ;beq _6                 ;   no!
                bra _6  ; HACK:

                inc isDead              ;   yes!!!

_6              ;lda P0PF               ; has player 0 hit color 2?
                ;and #$02
                ;beq _7                 ;   no!
                bra _7 ; HACK:

                inc isDead              ;   yes!!!

_7              ;sta HITCLR             ; clear collisions

                lda vMoveTimer          ; movement timer zero?
                beq _8                  ;   yes, don't decrement.

                dec vMoveTimer

_8              lda vStarMoveTimer      ; star move timer zero?
                beq _9                  ;   yes, don't decrement.

                dec vStarMoveTimer

_9              lda vStarRotTimer       ; star rot. timer zero?
                beq _10                 ;   yes, rotate star!

                dec vStarRotTimer       ; decrement timer
                jmp _12                 ; and skip rotation.

_10             lda #1                  ; set rot. timer to 1
                sta vStarRotTimer

                lda vStarRotPosition    ; increment star rotation counter
                clc
                adc #1

                cmp #7                  ; allow only 0-6.
                bne _11                 ; rot. count ok

                lda #0                  ; zero rot. counter.
_11             sta vStarRotPosition    ; save rot. pos.


;   this section draws the star in player-0 memory
;   using the tables 'starb1' thru 'starb8'.

_12             ldy vStarRotPosition
                ldx vStarHeight

                lda #0
                sta PL0-1,X
                sta PL0+8,X

                lda STARB1,Y
                sta PL0,X

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

                lda STRHOR              ; set star's horiz. pos.
                sta SP00_X_POS

                lda SHOOFF              ; ok to show player?
                bne _XIT                ;   no, exit VBI

                lda PX                  ; set player's horizontal position
                clc
                adc #47
                sta SP03_X_POS

                lda PY                  ; draw player in player-3 memory
                clc
                adc #$10
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
                bne _XIT                ;   no, exit VBI

                ;inc COLPM3             ;   yes, cycle the color
_XIT            rtl
