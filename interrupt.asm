
; SPDX-FileName: interrupt.asm
; SPDX-FileCopyrightText: Copyright 2024-2025, Scott Giese
; SPDX-License-Identifier: GPL-3.0-or-later


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Main IRQ Handler
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
irqMain         .proc
                pha
                phx
                phy

                cld

; - - - - - - - - - - - - - - - - - - -
;   switch to system map
                lda IOPAGE_CTRL
                pha                     ; preserve
                stz IOPAGE_CTRL
; - - - - - - - - - - - - - - - - - - -

                ;!! lda INT_PENDING_REG1
                ;!! bit #INT01_VIA1
                ;!! beq _1

                ;!! lda INT_PENDING_REG1
                ;!! sta INT_PENDING_REG1

                ;!! jsr KeyboardHandler

_1              lda INT_PENDING_REG0
                bit #INT00_SOF
                beq _XIT

                lda INT_PENDING_REG0
                sta INT_PENDING_REG0

                jsr irqVBIHandler

; - - - - - - - - - - - - - - - - - - -
_XIT            pla                     ; restore
                sta IOPAGE_CTRL
; - - - - - - - - - - - - - - - - - - -

                ply
                plx
                pla

irqMain_END     ;jmp IRQ_PRIOR
                rti
                .endproc


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Key Notifications
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

                pha
                phx
                phy

                lda PS2_KEYBD_IN
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

; - - - - - - - - - - - - - - - - - - -
_1r             pla
                pha
                cmp #KEY_F2|$80
                bne _2r

                lda CONSOL
                ora #$04
                sta CONSOL

                jmp _CleanUpXIT

; - - - - - - - - - - - - - - - - - - -
_2              pla
                pha
                cmp #KEY_F3
                bne _3

                lda CONSOL
                eor #$02
                sta CONSOL

                jmp _CleanUpXIT

; - - - - - - - - - - - - - - - - - - -
_2r             pla
                pha
                cmp #KEY_F3|$80
                bne _3r

                lda CONSOL
                ora #$02
                sta CONSOL

                jmp _CleanUpXIT

; - - - - - - - - - - - - - - - - - - -
_3              pla
                pha
                cmp #KEY_F4
                bne _4

                lda CONSOL
                eor #$01
                sta CONSOL

                jmp _CleanUpXIT

; - - - - - - - - - - - - - - - - - - -
_3r             pla
                pha
                cmp #KEY_F4|$80
                bne _4r

                lda CONSOL
                ora #$01
                sta CONSOL

                jmp _CleanUpXIT

; - - - - - - - - - - - - - - - - - - -
_4              pla
                pha
                cmp #KEY_UP
                bne _5

                lda InputFlags
                bit #joyUP
                beq _4a

                eor #joyUP
                ora #joyDOWN            ; cancel KEY_DOWN
                sta InputFlags

_4a             lda #itKeyboard
                sta InputType

                jmp _CleanUpXIT

; - - - - - - - - - - - - - - - - - - -
_4r             pla
                pha
                cmp #KEY_UP|$80
                bne _5r

                lda InputFlags
                ora #joyUP
                sta InputFlags

                jmp _CleanUpXIT

; - - - - - - - - - - - - - - - - - - -
_5              pla
                pha
                cmp #KEY_DOWN
                bne _6

                lda InputFlags
                bit #joyDOWN
                beq _5a

                eor #joyDOWN
                ora #joyUP              ; cancel KEY_UP
                sta InputFlags

_5a             lda #itKeyboard
                sta InputType

                jmp _CleanUpXIT

; - - - - - - - - - - - - - - - - - - -
_5r             pla
                pha
                cmp #KEY_DOWN|$80
                bne _6r

                lda InputFlags
                ora #joyDOWN
                sta InputFlags

                jmp _CleanUpXIT

; - - - - - - - - - - - - - - - - - - -
_6              pla
                pha
                cmp #KEY_LEFT
                bne _7

                lda InputFlags
                bit #joyLEFT
                beq _6a

                eor #joyLEFT
                ora #joyRIGHT           ; cancel KEY_RIGHT
                sta InputFlags

_6a             lda #itKeyboard
                sta InputType

                bra _CleanUpXIT

_6r             pla
                pha
                cmp #KEY_LEFT|$80
                bne _7r

                lda InputFlags
                ora #joyLEFT
                sta InputFlags

                bra _CleanUpXIT

_7              pla
                pha
                cmp #KEY_RIGHT
                bne _8

                lda InputFlags
                bit #joyRIGHT
                beq _7a

                eor #joyRIGHT
                ora #joyLEFT            ; cancel KEY_LEFT
                sta InputFlags

_7a             lda #itKeyboard
                sta InputType

                bra _CleanUpXIT

_7r             pla
                pha
                cmp #KEY_RIGHT|$80
                bne _8r

                lda InputFlags
                ora #joyRIGHT
                sta InputFlags

                bra _CleanUpXIT

_8              pla
                cmp #KEY_CTRL
                bne _XIT

                lda InputFlags
                eor #joyButton0
                sta InputFlags

                lda #itKeyboard
                sta InputType

                stz KEYCHAR
                bra _XIT

_8r             pla
                cmp #KEY_CTRL|$80
                bne _XIT

                lda InputFlags
                ora #joyButton0
                sta InputFlags

                stz KEYCHAR
                bra _XIT

_CleanUpXIT     stz KEYCHAR
                pla

_XIT            ply
                plx
                pla
                rts
                .endproc


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Vertical Blank Interrupt (SOF)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
irqVBIHandler   .proc
KEY_SPACE       = $39
;---

                pha
                phx
                phy

                inc JIFFYCLOCK          ; increment the jiffy clock each VBI

;   when already in joystick mode, bypass the override logic
                lda InputType
                cmp #itJoystick
                beq _joyModeP1

                lda JOYSTICK0           ; read joystick0
                and #$1F
                cmp #$1F
                beq _pause              ; when no activity, keyboard is alternative

                sta InputFlags          ; joystick activity -- override keyboard input
                lda #itJoystick
                sta InputType

                bra _pause

_joyModeP1      lda JOYSTICK0           ; read joystick0
                sta InputFlags

_pause          lda KEYCHAR
                cmp #KEY_SPACE          ; is spacebar?
                bne _1                  ;   no, check for pause

                lda #$FF                ; clear key code -- (processed)
                sta KEYCHAR

                lda isPaused            ; toggle pause state
                eor #$FF
                sta isPaused

_1              lda isPaused            ; are we paused?
                beq _2                  ;   no!
                jmp _XIT                ; when paused, no VBI!

; - - - - - - - - - - - - - - - - - - -
_2              lda vBumpSndCount       ; more bump sound?
                bmi _3                  ;   no, process timer

                ora #$A0                ; mix volume with pure-tone
                sta SID2_CTRL1

                lda #$80                ; set up bump sound frequency
                sta SID2_FREQ1

                dec vBumpSndCount

_3              lda TIMER               ; timer down to zero?
                beq _4                  ;   yes, don't decrement

                dec TIMER

_4              lda isFillOn            ; are we filling?
                beq _5                  ;   no, do rest of VBI
                jmp _XIT                ; when filling, exit VBI

; - - - - - - - - - - - - - - - - - - -
_5              lda #0                  ; clear out dead flag
                sta isDead

                ;!! lda P0PL               ; has player 0 hit player 1?
                ;!! and #$08
                ;!! beq _6                 ;   no!
                bra _6  ; HACK:

                inc isDead              ;   yes!!!

_6              ;!! lda P0PF               ; has player 0 hit color 2?
                ;!! and #$02
                ;!! beq _7                 ;   no!
                bra _7 ; HACK:

                inc isDead              ;   yes!!!

_7              ;!! sta HITCLR             ; clear collisions

                lda vMoveTimer          ; movement timer zero?
                beq _8                  ;   yes, don't decrement.

                dec vMoveTimer

_8              lda vStarMoveTimer      ; star move timer zero?
                beq _9                  ;   yes, don't decrement.

                dec vStarMoveTimer

_9              lda vStarRotTimer       ; star rotation timer zero?
                beq _rotate             ;   yes, rotate star!

                dec vStarRotTimer       ; decrement timer
                jmp _12                 ; and skip rotation.

; - - - - - - - - - - - - - - - - - - -
_rotate         lda #1                  ; set rot. timer to 1
                sta vStarRotTimer

                lda StarRotPos          ; increment star rotation counter
                clc
                adc #1

                cmp #7                  ; allow only 0-6.
                bne _11                 ; rot. count ok

                lda #0                  ; zero rot. counter.
_11             sta StarRotPos          ; save rot. pos.

; - - - - - - - - - - - - - - - - - - -
;   this section draws the star
; - - - - - - - - - - - - - - - - - - -

;   star X
_12             stz zpTemp1
                stz zpTemp2

                lda StarHorzPos         ; set star's horiz. pos.
                asl                     ; *2, account for double-pixel display
                rol zpTemp1
                clc                     ; +32, account for off-screen border
                adc #32-6               ; -6, distance to star center
                rol zpTemp2
                sta SPR(sprite_t.X, IDX_STAR)

                clc
                lda zpTemp1
                adc zpTemp2
                sta SPR(sprite_t.X+1, IDX_STAR)

;   star Y
                stz zpTemp1
                stz zpTemp2

                lda StarVertPos         ; set star's vert. pos.
                asl                     ; *2, account for double-pixel display
                rol zpTemp1
                clc                     ; +32, account for off-screen border
                adc #32+24-6            ; +24, account for playfield vertical displacement
                rol zpTemp2             ; -6, distance to star center
                sta SPR(sprite_t.Y, IDX_STAR)

                clc
                lda zpTemp1
                adc zpTemp2
                sta SPR(sprite_t.Y+1, IDX_STAR)

;   star rotation
                lda StarRotPos
                asl                     ; *2, word lookup table
                tay

                lda StarRotTbl,Y
                sta SPR(sprite_t.ADDR, IDX_STAR)
                lda StarRotTbl+1,Y
                sta SPR(sprite_t.ADDR+1, IDX_STAR)

; - - - - - - - - - - - - - - - - - - -
;   this section draws the player
; - - - - - - - - - - - - - - - - - - -

;   color cycle timer
                lda zpPlayerColorClock  ; is it time to change color?
                cmp JIFFYCLOCK
                bne _13                 ;   no, skip

                lda JIFFYCLOCK
                clc                     ;   yes, reset the color clock
                adc #4
                sta zpPlayerColorClock

_13             lda isHidePlayer        ; ok to show player?
                bne _XIT                ;   no, exit VBI

;   player X
                stz zpTemp1
                stz zpTemp2

                lda PX                  ; set player's horizontal position
                asl                     ; *2, account for double-pixel display
                rol zpTemp1
                clc                     ; +32, account for off-screen border
                adc #32-2               ; -2, distance to player center
                rol zpTemp2
                sta SPR(sprite_t.X, IDX_PLYR)

                clc
                lda zpTemp1
                adc zpTemp2
                sta SPR(sprite_t.X+1, IDX_PLYR)

;   player Y
                lda PY                  ; set player's vertical position
                asl                     ; *2, account for double-pixel display
                clc                     ; +32, account for off-screen border
                adc #32+24-2            ; +24, account for playfield vertical displacement; -2, distance to player center
                sta SPR(sprite_t.Y, IDX_PLYR)

;   color cycle
                lda isPreventColorChange ; color change ok?
                bne _XIT                ;   no, exit VBI

                inc zpPlayerColorIdx    ;   yes, cycle the color
                cmp #$10
                bcc _14

                stz zpPlayerColorIdx

_14             lda zpPlayerColorIdx
                asl                     ; *4
                asl
                tax

                ldy #0
_nextColor      lda palColor0,X
                sta SprColor0,Y

                inx
                iny
                cpy #4
                bne _nextColor

                jsr InitGfxPalette

_XIT            ply
                plx
                pla
                rts
                .endproc
