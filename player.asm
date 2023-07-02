
;======================================
; Clear out the P/M area
;======================================
SpritesClear    .proc
                lda #0
                ldy #1
_nextPage       ldx #0
_next1          ;!!sta SPR_STAR,X
                ;!!sta SPR_PLAYER,X
                dex
                bne _next1

                dey
                bpl _nextPage

                rts
                .endproc


;======================================
; Plot address calculator
;--------------------------------------
; multiply PLOTY by 40, then calculate
; address of the screen memory to be
; altered.
;--------------------------------------
; at exit:
;   HI:LO       address
;   X           pixel position
;======================================
PlotCalc        .proc                               ; Given: PLOTX=14, PLOTY=10
                lda PLOTY                           ; A=$0A
                asl                     ; *2        ; A=$14
                sta LO                              ; LO=$14

                lda #0                              ; A=0
                sta HI                              ; HI=$00

                asl LO                              ; A=$28, C=0
                rol HI                  ; *4        ; HI=$00

                asl LO                              ; LO=$50, C=0
                lda LO                              ; A=$50
                sta LOHLD                           ; LOHLD=$50

                rol HI                  ; *8        ; HI=$00
                lda HI                              ; A=$00
                sta HIHLD                           ; HIHLD=$00

                asl LO                              ; LO=$A0, C=0
                rol HI                  ; *16       ; HI=$00
                asl LO                              ; LO=$40, C=1
                rol HI                  ; *32       ; HI=$01

                lda LO                              ; A=$40
                clc
                adc LOHLD                           ; A=$90
                sta LO                              ; LO=$90

                lda HI                              ; A=$01
                adc HIHLD                           ; A=$01
                sta HI                  ; +*8=*40   ; HI=$01

                lda #<Playfield                     ; A=$00
                clc
                adc LO                              ; A=$90, C=0
                sta LO                              ; LO=$90

                lda #>Playfield                     ; A=$70
                adc HI                              ; A=$71
                sta HI          ; +display start    ; HI=$71

                lda PLOTX       ; mask x position   ; A=$0E
                and #3                              ; A=$02
                tax                                 ; X=$02

                lda PLOTX                           ; A=$0E
                lsr                     ; /4        ; A=$07, C=0
                lsr                                 ; A=$03, C=1
                clc
                adc LO                              ; A=$93
                sta LO                              ; LO=$93

                lda HI                              ; A=$71
                adc #0          ; lo & hi now hold  ; A=$71
                sta HI          ; the address!      ; HI=$71
                rts                                 ; addr=$7193 = Playfield+403
                .endproc


;--------------------------------------
; Clear the display memory
;--------------------------------------
ClearDisplay    .proc
                ldx #0                  ; this routine will clear the screen ram.
                stx PLOTX               ; it gets the address
_next1          stx PLOTY               ; of the beginning of
                jsr PlotCalc            ; each gr.7 line

                ldx PLOTY               ; then zeroes out each of the

                lda #$00                ; 40 bytes (0-39) in the line.
                ldy #39
_next2          sta (LO),Y
                dey
                bpl _next2

                inx
                cpx #86
                bne _next1

; -------------------------------------
; Draw the color 1 border
; -------------------------------------
; this section draws the 4 lines that
; make the white border on the screen.
; -------------------------------------
                lda #3
                sta BORNUM

_border         ldx BORNUM
                lda BXSTRT,X
                sta PLOTX

                lda BYSTRT,X
                sta PLOTY

                lda BXINC,X             ; delta-X
                sta BDINCX

                lda BYINC,X             ; delta-Y
                sta BDINCY

                lda BORCNT,X
                sta BDCNT

_drawln         jsr PlotCalc            ; alters X:= pixel offset

                lda COLOR1,X            ; X:3=  00 00 00 01
                ldy #0                  ; X:2=  00 00 01 00
                ora (LO),Y              ; X:1=  00 01 00 00
                sta (LO),Y              ; X:0=  01 00 00 00

                lda PLOTX
                clc
                adc BDINCX
                sta PLOTX

                lda PLOTY
                clc
                adc BDINCY
                sta PLOTY

                dec BDCNT
                bne _drawln

                dec BORNUM
                bpl _border

                lda #TRUE
                sta isDirtyPlayfield

; ----------------------------------
; This section starts off each level
; ----------------------------------
                lda #80                 ; position the player
                sta PX
                lda #84
                sta PY

                lda LEVEL               ; increment the level number
                clc
                adc #1
                sta LOWK

                lda #0                  ; zero out current tally work area
                sta CurrentLO
                sta CurrentHI
                sta HIWK
                lda #$FF                ; tell decimal converter not to place result
                sta SLLOC
                jsr ConvertDecimal      ; convert level #

                lda DECIMAL+1           ; get decimal level #
                ora #$30                ; convert to ascii
                sta panelLevel          ; put in score line
                lda DECIMAL             ; same for 2nd
                ora #$30                ; level #
                sta panelLevel+1        ; digit

                ldx LEVEL               ; get this level's parameters
                lda TargetLO,X
                sta LOWK
                lda TargetHI,X
                sta HIWK
                lda STARSP,X
                sta StarSpeed
                lda #4
                sta SLLOC
                jsr ConvertDecimal      ; show target amount

                .endproc


;--------------------------------------
; Clear out the tracking table that
; remembers where the player moved
;--------------------------------------
ClearTrackTbl   .proc
                lda #FALSE
                sta isHidePlayer
                tax
_next1          sta DIR,X               ; clear direction
                sta LGTH,X              ; and length entries
                dex
                bne _next1

                sta MoveIndex           ; clear movement index
                sta isDrawActive        ; and draw flag

                .endproc


;--------------------------------------
;
;--------------------------------------
GetStick        .proc
_wait1          lda isPaused            ; game paused?
                bne _wait1              ;   yes, loop and wait.

                lda isDirtyPlayfield
                beq _1

                ; jsr BlitPlayfield

                stz isDirtyPlayfield

_1              lda #$FD                ; do 'warble' sound
                sta SID1_FREQ1           ; using sound
                lda #$FE                ; channels 1-3
                sta SID1_FREQ2
                lda #$FF
                sta SID1_FREQ3

                lda #$A3                ; volume=3, distortion=5 (pure tone)
                sta SID1_CTRL1
                sta SID1_CTRL2
                sta SID1_CTRL3

                lda isDead              ; did star hit us?
                beq _alive              ;   no!

                ldx LEVEL               ; it hit us -- unconditional kill?
                lda isUnconditionalKill,X
                bne _jCrash             ;   yes! we're dead!!!

                lda PX                  ;   no
                sta PLOTX
                lda PY
                sta PLOTY
                jsr PlotCalc

                ldy #0                  ; if we're on a white line (color 1)
                lda BitsOn,X            ; then we're alive!
                and (LO),Y
                cmp COLOR1,X            ; on color 1?
                beq _alive              ;   yes (whew!)

_jCrash         jmp Crash               ; go kill player

_alive          lda vMoveTimer          ; player moving?
                beq _gotstk             ;   yes--get stick.

                jmp MoveStar            ;   no, move star.

_jGetStick      jmp GetStick            ; go get stick

_gotstk         lda #4                  ; reset the movement timer
                sta vMoveTimer

                lda InputFlags          ; get the stick
                and #$0F
                sta StickHold           ; and save it

                tax                     ; then look up
                lda XD,X                ; x direction
                clc
                adc XD,X
                sta XI                  ; XI := [2]right | [-2]left

                lda YD,X                ; and y direction
                clc
                adc YD,X
                sta YI                  ; YI := [2]down | [-2]up

                ora XI                  ; any movement?
                beq _jGetStick          ;   no, try again.

                lda PX                  ; increment player x position
                clc                     ; and hold it...
                adc XI
                sta CKX
                cmp #155                ; offscreen?
                bcs _jGetStick          ;   yes! ignore

                cmp #4                  ; offscreen?
                bcc _jGetStick          ;   yes! ignore

                sta PLOTX               ;   no, save it
                sec
                sbc XD,X
                sta PXWC

                lda PY                  ; increment player y position
                clc                     ; and hold it...
                adc YI
                sta CKY
                cmp #85                 ; offscreen?
                bcs _jGetStick          ;   yes! ignore

                sta PLOTY               ;   no, save it
                sec
                sbc YD,X
                sta PYWC

                jsr PlotCalc            ; locate new player position

                ldy #0
                lda BitsOn,X
                and (LO),Y
                sta CKV                 ; save the 'locate'.
                stx CKVX

                lda PXWC                ; check the
                sta PLOTX               ; position next
                lda PYWC                ; to the one we're
                sta PLOTY               ; now in...
                jsr PlotCalc

                ldy #0
                lda BitsOn,X
                and (LO),Y
                pha                     ; and save it!
                lda InputFlags          ; trigger pressed?
                and #$10
                bne _notdrawing         ;   no!

                pla                     ; ok to draw?
                bne _repeat             ;   no!!

                jmp DrawFunc            ;   yes, go draw.

_notdrawing     pla                     ; not drawing--are we
                cmp COLOR1,X            ; on color 1?
                bne _repeat             ;   no, try again

                lda CKV                 ; are we moving
                ldx CKVX                ; onto another
                cmp COLOR1,X            ; color 1?
                bne _repeat             ;   no! try again.

                lda CKX                 ; all's well...
                sta PX                  ; update px
                lda CKY                 ; and py
                sta PY
_repeat         jmp GetStick            ; get stick

                .endproc


;-------------------------------------
; Handles the draw function.
;-------------------------------------
DrawFunc        .proc
                lda isDrawActive        ; already drawing?
                bne _drawok             ;   yes!

                sta MoveIndex           ;   no, this is the first time--
                lda StickHold           ; set up initial drawing variables.
                sta DIR

                lda #TRUE
                sta isDrawActive
                sta hasDrawn

                lda PX
                sta INIX
                sta MINX
                sta MAXX

                lda PY
                sta INIY
                sta MINY
                sta MAXY

_drawok         lda CKV                 ; did we
                ldx CKVX                ; run into another
                cmp COLOR2,X            ; color 2?
                bne _nocrash            ;   no, we're ok.

                jmp Crash               ; crraaassshhh!

_nocrash        ldx MoveIndex           ; update the tracking tables
                lda StickHold           ; with direction information
                cmp DIR,X
                beq _samdir

                inc MoveIndex
                inx
                sta DIR,X
                lda #0
                sta LGTH,X
_samdir         inc LGTH,X
                lda #3
                sta BDCNT

                lda PX                  ; now plot the line we're drawing...
                sta PLOTX
                lda PY
                sta PLOTY
_ccloop         jsr PlotCalc

                ldy #0
                lda (LO),Y
                and BitsOff,X
                ora COLOR2,X            ; in color 2.
                sta (LO),Y

                lda #TRUE
                sta isDirtyPlayfield

                dec BDCNT
                beq _ckcolr

                ldy MoveIndex
                ldx DIR,Y
                lda XD,X
                clc
                adc PLOTX
                sta PLOTX
                lda YD,X
                clc
                adc PLOTY
                sta PLOTY
                jmp _ccloop

_ckcolr         lda PLOTX               ; update x pos.
                sta PX
                cmp MAXX                ; check minimum
                bcc _tminx              ; and maximum

                sta MAXX                ; x & y values and
                jmp _chkymm             ; update if necessary

_tminx          cmp MINX
                bcs _chkymm

                sta MINX
_chkymm         lda PLOTY
                sta PY
                cmp MAXY
                bcc _tminy

                sta MAXY
                jmp _endmm

_tminy          cmp MINY
                bcs _endmm

                sta MINY
_endmm          ldx CKVX                ; did we draw
                lda CKV                 ; into
                cmp COLOR1,X            ; color 1?
                beq _endlin             ;   yes! end of line!

                jmp GetStick            ;   no, go get stick.

_endlin         lda #FALSE              ; we aren't
                sta isDrawActive        ; drawing anymore
                jsr Search              ; search and fill!!

                lda CurrentLO           ; get current value
                sta LOWK
                lda CurrentHI
                sta HIWK
                lda #14                 ; put at 14th
                sta SLLOC               ; pos. in scoreline1
                jsr ConvertDecimal      ; convert to decimal

                lda #1                  ; now redraw the
                sta RDRCOL              ; player's path in
                jsr Redraw              ; color 1 (white).

                ldx LEVEL               ; check to see if we've
                lda CurrentLO           ; hit the target.
                sec
                sbc TargetLO,X
                sta LOWK
                lda CurrentHI
                sbc TargetHI,X
                sta HIWK                ; hit target?
                bpl _newlvl             ;   yes--new level!

                jmp ClearTrackTbl       ;   no, go clear track

_newlvl         lda LEVEL               ; if level < 15 then
                cmp #15
                beq _nolinc

                inc LEVEL               ; increment level

; --------------
; Increase score
; --------------
_nolinc         asl LOWK                ; score inc =
                rol HIWK                ; tgt-cur * 2
                lda #$FF                ; don't place
                sta SLLOC               ; the result!
                jsr ConvertDecimal      ; convert to decimal

                ldx #5                  ; and add to score
                ldy #0
_scolp          lda DECIMAL,Y
                clc
                adc SCORE,X
                cmp #10
                bmi _nocary

                sec
                sbc #10
                sta SCORE,X
                inc SCORE-1,X
                jmp _nxspos

_nocary         sta SCORE,X
_nxspos         iny
                dex
                bpl _scolp

;   now place the score in score line #2
                ldx #5                  ; 6-digit score
_showscore      lda SCORE,X
                ora #$30                ; convert to ascii
                sta panelScore,X
                dex
                bpl _showscore

                lda #TRUE               ; stop VBI for a moment
                sta isFillOn
                sta isHidePlayer

                ;!!jsr SpritesClear        ; clear p/m area

                lda #64                 ; initialize the star position
                sta StarVertPos
                lda #128
                sta StarHorzPos

                lda #0                  ; VBI on again
                sta isFillOn

                jmp ClearDisplay        ; go clear display!

                .endproc


;--------------------------------------
; Handles player's death
;--------------------------------------
Crash           .proc
                lda #0                  ; no warble sound
                sta SID1_CTRL1           ; volume=0, distortion=0
                sta SID1_CTRL2
                sta SID1_CTRL3

                lda #TRUE               ; no player color change in vbi
                sta isPreventColorChange

                lda #15                 ; set brightness of player death
                sta DEDBRT
_timrst         lda #5                  ; set death timer to 5 jiffies
                sta TIMER
_deadcc         lda DEDBRT              ; move brightness to death sound volume
                sta SID1_CTRL1           ; volume=variable, distortion=0

                .frsRandomByte
                and #$1F                ; death sound frequency
                sta SID1_FREQ1

                .frsRandomByte
                and #$F0                ; death color
                ora DEDBRT              ; add brite
                ;sta COLPF1             ; put in line color
                ;sta COLPM3             ; and player color
                lda TIMER               ; timer done yet?
                bne _deadcc             ;   no, go change color.

                dec DEDBRT              ; decrement brightness
                bpl _timrst             ; if more, go do it.

                dec LIVES               ; 1 less life
                lda LIVES               ; get # lives
                ora #$30                ; convert to ascii
                sta panelLives          ; and display!

                cmp #$30                ; zero lives?
                bne RandomLocation      ;   no!

;   we're completely dead, show 'game over' message
                lda #TRUE
                sta isGameOver
                jsr RenderPanel

_ckstrt         lda CONSOL              ; wait for start
                and #1                  ; key...
                bne _ckstrt             ;   not pressed--loop.

_releas         lda CONSOL              ; key pressed, now
                and #1                  ; wait for release!
                beq _releas             ;   not released yet!

;   put the normal score line back (replace 'game over')
                lda #FALSE
                sta isGameOver
                jsr RenderPanel

                jmp START               ; and start game!

                .endproc


;--------------------------------------
; Places player at a random location if
; there are more lives left.
;--------------------------------------
RandomLocation  .proc
                lda #TRUE               ; don't show player
                sta isHidePlayer
_newloc         .frsRandomByte          ; get random value for x
                and #$FE                ; must be even and on screen
                cmp #159
                bcs _newloc

                sta PLOTX
_cshy           .frsRandomByte          ; get random value for y
                and #$7E                ; must be even and on screen
                cmp #85
                bcs _cshy

                sta PLOTY
                jsr PlotCalc

                ldy #0
                lda BitsOn,X
                and (LO),Y              ; is location on
                cmp COLOR1,X            ; color 1?
                bne _newloc             ;   no, try again.

                ;!!jsr SpritesClear        ; it's ok, clear p/m

                lda PLOTX               ; save the player's
                sta PX                  ; new coordinates
                lda PLOTY
                sta PY

                lda #FALSE              ; redraw the
                sta RDRCOL              ; player's track
                lda hasDrawn            ; in color 0
                beq _jctrk

                jsr Redraw

                lda INIX                ; this part is
                sta PLOTX               ; needed to plot
                lda INIY                ; a color 1 block
                sta PLOTY               ; at the start of
                jsr PlotCalc            ; the player's track

                ldy #0                  ; after it is erased.
                lda BitsOff,X           ; (nobody's perfect!)
                and (LO),Y
                ora COLOR1,X
                sta (LO),Y

                lda #TRUE
                sta isDirtyPlayfield

_jctrk          ;lda #$24               ; restore draw line color
                ;sta COLPF1

                lda #FALSE
                sta isPreventColorChange
                ;sta HITCLR             ; clear collisions
                sta isDead

                jmp ClearTrackTbl       ; and go start new track.

                .endproc


;======================================
;
;--------------------------------------
; This routine uses the tracking tables,
; DIR and LGTH, to redraw the line the
; player drew.  RDRCOL indicates the color
; desired.
;======================================
Redraw          .proc
                lda INIX
                sta REX
                lda INIY
                sta REY
                lda #0
                sta X
_redxlp         ldx X
                lda DIR,X
                sta REDIR
                lda LGTH,X
                sta LGTHY
                lda #1
                sta Y
_redylp         lda #3
                sta TIMES
_times3         lda REX
                sta PLOTX
                lda REY
                sta PLOTY
                jsr PlotCalc

                ldy #0
                lda RDRCOL
                bne _rdc1

                lda BitsOff,X
                and (LO),Y
                sta (LO),Y

                lda #TRUE
                sta isDirtyPlayfield

                jmp _setnrp

_endrd          lda #FALSE
                sta isDrawActive
                rts

_rdc1           lda BitsOff,X
                and (LO),Y
                ora COLOR1,X
                sta (LO),Y

                lda #TRUE
                sta isDirtyPlayfield

_setnrp         dec TIMES
                beq _nxty

                ldx REDIR
                lda REX
                clc
                adc XD,X
                sta REX
                lda REY
                clc
                adc YD,X
                sta REY
                jmp _times3

_nxty           inc Y
                lda Y
                cmp LGTHY
                beq _jnrd

                bcs _nxtx

_jnrd           jmp _redylp

_nxtx           inc X
                lda X
                cmp MoveIndex
                beq _jrxlp

                bcs _endrd

_jrxlp          jmp _redxlp

                .endproc
