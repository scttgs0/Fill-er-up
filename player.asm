;======================================
; Clear out the P/M area
;======================================
SpritesClear    .proc
                lda #0
                ldy #1
_nextPage       ldx #0
_next1          ;--sta SPR_STAR,X
                ;--sta SPR_PLAYER,X
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
; at exit
;   HI:LO       address
;   X           pixel position
;======================================
PlotCalc        .proc                               ; Given: PLOTX=14, PLOTY=10
                lda PLOTY                           ; A=$0A
                asl A                  ; *2         ; A=$14
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
                lsr A                   ; /4        ; A=$07, C=0
                lsr A                               ; A=$03, C=1
                clc
                adc LO                              ; A=$93
                sta LO                              ; LO=$93

                lda HI                              ; A=$71
                adc #0          ; lo & hi now hold  ; A=$71
                sta HI          ; the address!      ; HI=$71
                rts                     ; exit!     ; addr=$7193 = Playfield+403
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

; -----------------------
; Draw the color 1 border
; -----------------------
                lda #3                  ; this routine
                sta BORNUM              ; draws the 4 lines

_border         ldx BORNUM              ; that make up the
                lda BXSTRT,X            ; white gr.7 border
                sta PLOTX               ; on the screen.

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

                jsr BlitPlayfield

;
; This section starts off each level
;
                lda #80                 ; position the
                sta PX                  ; player
                lda #84
                sta PY

                lda LEVEL               ; increment the
                clc                     ; level number
                adc #1
                sta LOWK

                lda #0                  ; zero out current
                sta CurrentLO           ; tally work area
                sta CurrentHI
                sta HIWK
                lda #$FF                ; tell decimal converter
                sta SLLOC               ; not to place result
                jsr ConvertDecimal      ; convert level #

                lda DECIMAL+1           ; get decimal level #
                ora #$30                ; add color
                sta panelLevel          ; put in score line
                lda DECIMAL             ; same for 2nd
                ora #$30                ; level #
                sta panelLevel+1        ; digit

                ldx LEVEL               ; get this level's
                lda TargetLO,X          ; parameters
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
; CLEAR OUT THE TRACKING TABLE THAT
; REMEMBERS WHERE THE PLAYER MOVED
;--------------------------------------
ClearTrackTbl   .proc
                lda #FALSE
                sta isHidePlayer
                tax
_next1          sta DIR,X               ; clear direction
                sta LGTH,X              ; and length entries
                dex
                bne _next1

                sta MOVIX               ; clear movement index
                sta isDrawActive        ; and draw flag

                .endproc


;--------------------------------------
;
;--------------------------------------
GetStick        .proc
_wait1          lda isPaused            ; game paused?
                bne _wait1              ;   yes, loop and wait.

                lda #$FD                ; do 'warble' sound
                sta SID_FREQ1           ; using sound
                lda #$FE                ; channels 1-3
                sta SID_FREQ2
                lda #$FF
                sta SID_FREQ3

                lda #$A3                ; volume=3, distortion=5 (pure tone)
                sta SID_CTRL1
                sta SID_CTRL2
                sta SID_CTRL3

                lda isDead              ; did star hit us?
                beq _alive              ; no!

                ldx LEVEL               ; it hit us--
                lda KILLFG,X            ; unconditional kill?
                bne _jcrsh              ;   yes! we're dead!!!

                lda PX                  ;   no, if we're on a
                sta PLOTX               ; white line (color 1)
                lda PY                  ; then we're alive!
                sta PLOTY
                jsr PlotCalc

                ldy #0
                lda BitsOn,X
                and (LO),Y
                cmp COLOR1,X            ; on color 1?
                beq _alive              ;   yes (whew!)

_jcrsh          jmp Crash               ; go kill player.

_alive          lda vMoveTimer          ; player moving?
                beq _gotstk             ;   yes--get stick.

                jmp MoveStar            ;   no, move star.

_jgstk          jmp GetStick            ; go get stick

_gotstk         lda #4                  ; set up the
                sta vMoveTimer          ; movement timer
                lda InputFlags          ; get the stick
                sta STKHLD              ; and save it
                tax                     ; then look up
                lda XD,X                ; x direction
                clc
                adc XD,X
                sta XI                  ; and
                lda YD,X                ; y direction
                clc
                adc YD,X
                sta YI
                ora XI                  ; any movement?
                beq _jgstk              ;   no, try again.

                lda PX                  ; increment
                clc                     ; player x
                adc XI                  ; position and
                sta CKX                 ; hold it...
                cmp #159                ; offscreen?
                bcs _jgstk              ;   yes!

                sta PLOTX               ;   no, save it
                sec
                sbc XD,X
                sta PXWC
                lda PY                  ; increment
                clc                     ; player y
                adc YI                  ; position and
                sta CKY                 ; hold it...
                cmp #85                 ; offscreen?
                bcs _jgstk              ;   yes!

                sta PLOTY               ;   no, save it
                sec
                sbc YD,X
                sta PYWC
                jsr PlotCalc            ; locate new player

                ldy #0                  ; position.
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
                bne _notdrn             ;   no!

                pla                     ; ok to draw?
                bne _repeat             ;   no!!

                jmp DrawFunc            ;   yes, go draw.

_notdrn         pla                     ; not drawing--are we
                cmp COLOR1,X            ; on color 1?
                bne _repeat             ;   no, try again

                lda CKV                 ; are we moving
                ldx CKVX                ; onto another
                cmp COLOR1,X            ; color 1?
                bne _repeat             ;   no! try again.

                lda CKX                 ; all's well...
                sta PX                  ; update px
                lda CKY                 ; and
                sta PY                  ; py,
_repeat         jmp GetStick            ; get stick.

                .endproc


;-------------------------------------
; THIS HANDLES THE DRAW FUNCTION.
;-------------------------------------
DrawFunc        .proc
                lda isDrawActive        ; already drawing?
                bne _drawok             ;   yes!

                sta MOVIX               ;   no, this is the first time--
                lda STKHLD              ; set up initial drawing variables.
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

_nocrash        ldx MOVIX               ; update the tracking
                lda STKHLD              ; tables with direction
                cmp DIR,X               ; information.
                beq _samdir

                inc MOVIX
                inx
                sta DIR,X
                lda #0
                sta LGTH,X
_samdir         inc LGTH,X
                lda #3
                sta BDCNT
                lda PX                  ; now plot the
                sta PLOTX               ; line we're
                lda PY                  ; drawing...
                sta PLOTY
_ccloop         jsr PlotCalc

                ldy #0
                lda (LO),Y
                and BitsOff,X
                ora COLOR2,X            ; in color 2.
                sta (LO),Y
                dec BDCNT
                beq _ckcolr

                ldy MOVIX
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
                lda #15                 ; put at 15th
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

;
; INCREASE SCORE HERE
;
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

                ldx #5                  ; now place the
_shslp          lda SCORE,X             ; score in
                ora #$10                ; score line #2
                sta panelScore,X
                dex
                bpl _shslp

                lda #TRUE               ; stop VBI for a moment
                sta isFillOn
                sta isHidePlayer

                jsr SpritesClear        ; clear p/m area

                lda #64                 ; initialize the star position
                sta StarVertPos
                lda #128
                sta StarHorzPos

                lda #0                  ; VBI on again
                sta isFillOn

                jmp ClearDisplay        ; go clear display!

                .endproc


;--------------------------------------
; THIS SECTION HANDLES PLAYER'S DEATH
;--------------------------------------
Crash           .proc
                lda #0                  ; no warble sound
                sta SID_CTRL1           ; volume=0, distortion=0
                sta SID_CTRL2
                sta SID_CTRL3

                lda #TRUE               ; no player color
                sta isPreventColorChange ; change in vbi

                lda #15                 ; set brightness of
                sta DEDBRT              ; player death.
_timrst         lda #5                  ; set death timer
                sta TIMER               ; to 5 jiffies.
_deadcc         lda DEDBRT              ; move brightness
                sta SID_CTRL1           ; to death sound volume ; volume=variable, distortion=0

                .randomByte
                and #$1F                ; death sound
                sta SID_FREQ1           ; frequency

                .randomByte
                and #$F0                ; death color
                ora DEDBRT              ; add brite
                ;sta COLPF1             ; put in line color
                ;sta COLPM3             ; and player color
                lda TIMER               ; timer done yet?
                bne _deadcc             ; no, go change color.

                dec DEDBRT              ; decrement brightness
                bpl _timrst             ; if more, go do it.

                dec LIVES               ; 1 less life
                lda LIVES               ; get # lives
                ora #$30                ; add color
                sta panelLives          ; and display!

                cmp #$30                ; zero lives?
                bne RandomLocation      ; no!

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
; THIS SECTION PLACES PLAYER AT A RANDOM
; LOCATION IF THERE ARE MORE LIVES LEFT.
;--------------------------------------
RandomLocation  .proc
                lda #TRUE               ; don't show
                sta isHidePlayer        ; player
_newloc         .randomByte             ; get random x
                and #$FE                ; must be even
                cmp #159                ; and on screen
                bcs _newloc

                sta PLOTX
_cshy           .randomByte             ; get random y
                and #$7E                ; must be even
                cmp #85                 ; and on screen
                bcs _cshy

                sta PLOTY
                jsr PlotCalc

                ldy #0
                lda BitsOn,X
                and (LO),Y              ; is location on
                cmp COLOR1,X            ; color 1?
                bne _newloc             ;   no, try again.

                jsr SpritesClear        ; it's ok, clear p/m

                lda PLOTX               ; save
                sta PX                  ; the player's
                lda PLOTY               ; new
                sta PY                  ; coordinates.

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
_jctrk          ;lda #$24               ; restore draw line
                ;sta COLPF1             ; color

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
                jmp _setnrp

_endrd          lda #FALSE
                sta isDrawActive
                rts

_rdc1           lda BitsOff,X
                and (LO),Y
                ora COLOR1,X
                sta (LO),Y
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
                cmp MOVIX
                beq _jrxlp

                bcs _endrd

_jrxlp          jmp _redxlp

                .endproc
