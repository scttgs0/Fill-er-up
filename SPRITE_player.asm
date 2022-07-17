;======================================
; Clear out the P/M area
;======================================
SpritesClear    .proc
                lda #0
                ldx #127
_next1          sta MISSLS,X            ; missiles,
                sta PL0,X               ; player 0,
                sta PL1,X               ; player 1,
                sta PL2,X               ; player 2,
                sta PL3,X               ; and player 3!
                dex
                bne _next1

                rts
                .endproc


;======================================
; PLOT ADDRESS CALCULATOR
;--------------------------------------
; multiply PLOTY by 40, then calculate
; address of the screen memory to be
; altered.
;======================================
PlotCalc        .proc
                lda PLOTY
                asl A
                sta LO
                lda #0
                sta HI                  ; *2
                asl LO
                rol HI                  ; *4
                asl LO
                lda LO
                sta LOHLD
                rol HI                  ; *8
                lda HI
                sta HIHLD
                asl LO
                rol HI                  ; *16
                asl LO
                rol HI                  ; *32
                lda LO
                clc
                adc LOHLD
                sta LO
                lda HI
                adc HIHLD
                sta HI                  ; +*8=*40
                lda #<DISP
                clc
                adc LO
                sta LO
                lda #>DISP
                adc HI
                sta HI                  ; +display start
                lda PLOTX               ; mask x position
                and #3
                tax
                lda PLOTX
                lsr A
                lsr A
                clc
                adc LO
                sta LO
                lda HI
                adc #0                  ; lo & hi now hold
                sta HI                  ; the address!
                rts                     ; exit!
                .endproc


;--------------------------------------
; CLEAR THE DISPLAY MEMORY
;--------------------------------------
ClearDisplay    .proc
                ldx #0                  ; this routine will
                stx PLOTX               ; clear the screen ram.
                ldx #0                  ; it gets the address
_next1          stx PLOTY               ; of the beginning of
                jsr PlotCalc            ; each gr.7 line

                ldx PLOTY               ; then zeroes out
                lda #$00                ; each of the
                ldy #39                 ; 40 bytes (0-39)
_next2          sta (LO),Y              ; in the line.
                dey
                bpl _next2

                inx
                cpx #86
                bne _next1

;
; Draw the color 1 border
;
                lda #3                  ; this routine
                sta BORNUM              ; draws the 4 lines
_border         ldx BORNUM              ; that make up the
                lda BXSTRT,X            ; white gr.7 border
                sta PLOTX               ; on the screen.
                lda BYSTRT,X
                sta PLOTY
                lda BXINC,X
                sta BDINCX
                lda BYINC,X
                sta BDINCY
                lda BORCNT,X
                sta BDCNT
_drawln         jsr PlotCalc

                lda COLOR1,X
                ldy #0
                ora (LO),Y
                sta (LO),Y
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
                lda #0                  ; zero out
                sta CURLO               ; current tally
                sta CURHI               ; work area
                sta HIWK
                lda #$FF                ; tell decimal converter
                sta SLLOC               ; not to place result
                jsr ConvertDecimal      ; convert level #

                lda DECIMAL+1           ; get decimal level #
                ora #$90                ; add color
                sta panelLevel          ; put in score line
                lda DECIMAL             ; same for 2nd
                ora #$90                ; level #
                sta panelLevel+1        ; digit

                ldx LEVEL               ; get this level's
                lda TGTLO,X             ; parameters
                sta LOWK
                lda TGTHI,X
                sta HIWK
                lda STARSP,X
                sta STRSPD
                lda #4
                sta SLLOC
                jsr ConvertDecimal      ; show target amount
                .endproc


;--------------------------------------
; CLEAR OUT THE TRACKING TABLE THAT
; REMEMBERS WHERE THE PLAYER MOVED
;--------------------------------------
ClearTrackTbl   .proc
                lda #0
                sta SHOOFF
                tax
_next1          sta DIR,X               ; clear direction
                sta LGTH,X              ; and length entries
                dex
                bne _next1

                sta MOVIX               ; clear movement index
                sta DRAWFG              ; and draw flag

                .endproc


;--------------------------------------
;
;--------------------------------------
GetStick        .proc
                lda PAUSE               ; game paused?
                bne GetStick            ; yes, loop and wait.

                ;lda #$FD               ; do 'warble' sound
                ;sta AUDF1              ; using sound
                ;lda #$FE               ; channels 1-3
                ;sta AUDF2
                ;lda #$FF
                ;sta AUDF3

                ;lda #$A3               ; volume=3, distortion=5 (pure tone)
                ;sta AUDC1
                ;sta AUDC2
                ;sta AUDC3

                ;lda #0                 ; no attract mode!
                ;sta ATTRACT

                lda isDead              ; did star hit us?
                beq _alive              ; no!

                ldx LEVEL               ; it hit us--
                lda KILLFG,X            ; unconditional kill?
                bne _jcrsh              ; yes! we're dead!!!

                lda PX                  ; no, if we're on a
                sta PLOTX               ; white line (color 1)
                lda PY                  ; then we're alive!
                sta PLOTY
                jsr PlotCalc

                ldy #0
                lda BITSON,X
                and (LO),Y
                cmp COLOR1,X            ; on color 1?
                beq _alive              ; yes (whew!)

_jcrsh          jmp Crash               ; go kill player.

_alive          lda vMoveTimer          ; player moving?
                beq _gotstk             ; yes--get stick.

                jmp MoveStar            ; no, move star.

_jgstk          jmp GetStick            ; go get stick

_gotstk         lda #4                  ; set up the
                sta vMoveTimer          ; movement timer
                lda JOYSTICK0           ; get the stick
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
                beq _jgstk              ; no, try again.

                lda PX                  ; increment
                clc                     ; player x
                adc XI                  ; position and
                sta CKX                 ; hold it...
                cmp #159                ; offscreen?
                bcs _jgstk              ; yes!

                sta PLOTX               ; no, save it
                sec
                sbc XD,X
                sta PXWC
                lda PY                  ; increment
                clc                     ; player y
                adc YI                  ; position and
                sta CKY                 ; hold it...
                cmp #85                 ; offscreen?
                bcs _jgstk              ; yes!

                sta PLOTY               ; no, save it
                sec
                sbc YD,X
                sta PYWC
                jsr PlotCalc            ; locate new player

                ldy #0                  ; position.
                lda BITSON,X
                and (LO),Y
                sta CKV                 ; save the 'locate'.
                stx CKVX
                lda PXWC                ; check the
                sta PLOTX               ; position next
                lda PYWC                ; to the one we're
                sta PLOTY               ; now in...
                jsr PlotCalc

                ldy #0
                lda BITSON,X
                and (LO),Y
                pha                     ; and save it!
                lda JOYSTICK0           ; trigger pressed?
                and #$10
                bne _notdrn             ; no!

                pla                     ; ok to draw?
                bne _repeat             ; no!!

                jmp DrawFunc            ; yes, go draw.

_notdrn         pla                     ; not drawing--are we
                cmp COLOR1,X            ; on color 1?
                bne _repeat             ; no, try again

                lda CKV                 ; are we moving
                ldx CKVX                ; onto another
                cmp COLOR1,X            ; color 1?
                bne _repeat             ; no! try again.

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
                lda DRAWFG              ; already drawing?
                bne _drawok             ; yes!

                sta MOVIX               ; no, this is the
                lda STKHLD              ; first time--set up
                sta DIR                 ; initial drawing
                lda #1                  ; variables.
                sta DRAWFG
                sta HASDRN
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
                bne _nocrash            ; no, we're ok.

                jmp Crash               ; crraaassshhh!

_nocrash        ldx MOVIX               ; update the
                lda STKHLD              ; tracking
                cmp DIR,X               ; tables with
                beq _samdir             ; direction

                inc MOVIX               ; information.
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
                and BITOFF,X
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

                sta MAXX                ; x & y values
                jmp _chkymm             ; and update if

_tminx          cmp MINX                ; necessary
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
                beq _endlin             ; yes! end of line!

                jmp GetStick            ; no, go get stick.

_endlin         lda #0                  ; we aren't
                sta DRAWFG              ; drawing anymore
                jsr Search              ; search and fill!!

                lda CURLO               ; get current value
                sta LOWK
                lda CURHI
                sta HIWK
                lda #15                 ; put at 15th
                sta SLLOC               ; pos. in scoreline1
                jsr ConvertDecimal      ; convert to decimal

                lda #1                  ; now redraw the
                sta RDRCOL              ; player's path in
                jsr Redraw              ; color 1 (white).

                ldx LEVEL               ; check to see
                lda CURLO               ; if we've hit
                sec                     ; the target.
                sbc TGTLO,X
                sta LOWK
                lda CURHI
                sbc TGTHI,X
                sta HIWK                ; hit target?
                bpl _newlvl             ; yes--new level!

                jmp ClearTrackTbl       ; no, go clear track

_newlvl         lda LEVEL               ; if level < 15
                cmp #15                 ; then
                beq _nolinc             ; increment

                inc LEVEL               ; level
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

                lda #1                  ; stop VBI for a moment
                sta isFillOn
                sta SHOOFF

                jsr SpritesClear        ; clear p/m area

                lda #64                 ; initialize the star position
                sta vStarHeight
                lda #128
                sta STRHOR

                lda #0                  ; VBI on again
                sta isFillOn

                jmp ClearDisplay        ; go clear display!

                .endproc


;--------------------------------------
; THIS SECTION HANDLES PLAYER'S DEATH
;--------------------------------------
Crash           .proc
                ;lda #0                 ; no warble sound
                ;sta AUDC1              ; volume=0, distortion=0
                ;sta AUDC2
                ;sta AUDC3

                lda #1                  ; no player color
                sta NOCCHG              ; change in vbi
                lda #15                 ; set brightness of
                sta DEDBRT              ; player death.
_timrst         lda #5                  ; set death timer
                sta TIMER               ; to 5 jiffies.
_deadcc         ;lda DEDBRT             ; move brightness
                ;sta AUDC1              ; to death sound volume ; volume=variable, distortion=0

                ;lda SID_RANDOM         ; get random
                ;and #$1F               ; death sound
                ;sta AUDF1              ; frequency

                lda SID_RANDOM          ; get random
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
                ora #$90                ; add color
                sta panelLives          ; and display!

                cmp #$90                ; zero lives?
                bne RandomLocation      ; no!

                lda #<GameOver          ; we're completely
                sta SCDL+1              ; dead, show
                lda #>GameOver          ; 'game over'
                sta SCDL+2              ; message
_ckstrt         lda CONSOL              ; wait for start
                and #1                  ; key...
                bne _ckstrt             ; not pressed--loop.

_releas         lda CONSOL              ; key pressed, now
                and #1                  ; wait for release!
                beq _releas              ; not released yet!

                lda #<ScoreLine1        ; put score
                sta SCDL+1              ; line back
                lda #>ScoreLine1        ; in display
                sta SCDL+2              ; list...
                jmp START               ; and start game!

                .endproc


;--------------------------------------
; THIS SECTION PLACES PLAYER AT A RANDOM
; LOCATION IF THERE ARE MORE LIVES LEFT.
;--------------------------------------
RandomLocation  .proc
                lda #1                  ; don't show
                sta SHOOFF              ; player
_newloc         lda SID_RANDOM          ; get random x
                and #$FE                ; must be even
                cmp #159                ; and on screen
                bcs _newloc

                sta PLOTX
_cshy           lda SID_RANDOM          ; get random y
                and #$7E                ; must be even
                cmp #85                 ; and on screen
                bcs _cshy

                sta PLOTY
                jsr PlotCalc

                ldy #0
                lda BITSON,X
                and (LO),Y              ; is location on
                cmp COLOR1,X            ; color 1?
                bne _newloc             ; no, try again.

                jsr SpritesClear        ; it's ok, clear p/m

                lda PLOTX               ; save
                sta PX                  ; the player's
                lda PLOTY               ; new
                sta PY                  ; coordinates.
                lda #0                  ; redraw the
                sta RDRCOL              ; player's track
                lda HASDRN              ; in color 0
                beq _jctrk

                jsr Redraw

                lda INIX                ; this part is
                sta PLOTX               ; needed to plot
                lda INIY                ; a color 1 block
                sta PLOTY               ; at the start of
                jsr PlotCalc            ; the player's track

                ldy #0                  ; after it is erased.
                lda BITOFF,X            ; (nobody's perfect!)
                and (LO),Y
                ora COLOR1,X
                sta (LO),Y
_jctrk          ;lda #$24               ; restore draw line
                ;sta COLPF1             ; color

                lda #0
                sta NOCCHG
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

                lda BITOFF,X
                and (LO),Y
                sta (LO),Y
                jmp _setnrp

_endrd          lda #0
                sta DRAWFG
                rts

_rdc1           lda BITOFF,X
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
