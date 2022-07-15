;======================================
; FILL 'ER UP!
;--------------------------------------
; BY Tom Hudson
; A.N.A.L.O.G. COMPUTING #10
;======================================

                .include "equates_system_c256.asm"
                .include "equates_zeropage.asm"
                .include "equates_game.asm"

                .include "macros_65816.asm"
                .include "macros_frs_graphic.asm"
                .include "macros_frs_mouse.asm"


;--------------------------------------
;--------------------------------------
                * = START-40
;--------------------------------------
                .text "PGX"
                .byte $01
                .dword BOOT

BOOT            clc
                xce
                .m8i8
                .setdp $0000
                .setbank $00

                jmp START


;--------------------------------------
;--------------------------------------
                * = $1400
;--------------------------------------


;--------------------------------------
; Start of Code
;--------------------------------------
START           .frsGraphics mcGraphicsOn|mcSpriteOn,mcVideoMode320
                .frsMouse_off
                .frsBorder_off

                ;jsr SIOINV              ; init sounds

;   5th-player, player > playfield > background
                ;lda #$11                ; P/M priority
                ;sta GPRIOR

                lda #1                  ; don't show player or star
                sta SHOOFF              ; we still must clear P/M area
                sta FILLON
                jsr PMCLR

                lda #64                 ; and set up the star's height and horizontal position
                sta STRHGT
                lda #128
                sta STRHOR

                lda #$D0                ; now let's zero out the score areas!
                ldx #4
ZSCLP           sta ScoreLine1+4,X
                sta ScoreLine1+15,X
                dex
                bpl ZSCLP

                ldx #5
ZSCLP2          sta ScoreLine2+12,X
                dex
                bpl ZSCLP2

                lda #0                  ; these items must be set to zero on startup or
                sta FILLON              ; else we'll wind up with nasty things happening!
                sta DEADFG
                sta NOCCHG
                ;sta HITCLR             ; clear collisions
                ;sta DMACTL             ; turn off the screen
                ;sta NMIEN              ; disable interrupts
                sta HASDRN
                ;sta AUDCTL             ; reset POKEY

                ldx #5                  ; let's zero out the score counter...
CMSLP           sta SCORE,X
                dex
                bpl CMSLP

                sta LEVEL               ; and level #!

                lda #3                  ; we start with 3 lives
                sta LIVES

                ora #$90                ; and put them in the score line
                sta ScoreLine2+19

                ;lda #$0A               ; next we set up the colors we want to use.
                ;sta COLPF0
                ;lda #$24
                ;sta COLPF1
                ;lda #$94
                ;sta COLPF2
                ;lda #$C4
                ;sta COLPF3
                ;lda #0
                ;sta COLBK
                ;lda #$76
                ;sta COLPM3
                ;lda #$34
                ;sta COLPM0

                ;lda #<DLIST          	; we'd better tell the computer where our display list is located!
                ;sta DLISTL
                ;lda #>DLIST
                ;sta DLISTL+1

                ;lda #6
                ;ldy #<INTRPT           ; tell where the vertical blank interrupt is
                ;ldx #>INTRPT
                ;jsr SETVBV             ; and set it!

                ;lda #>PMAREA           ; here's our P/M graphics area!
                ;sta PMBASE

                ;lda #$2E               ; turn on the DMA control
                ;sta DMACTL             ; dma instruction fetch, P/M DMA, standard playfield

                ;lda #$3                ; ... and graphics control!
                ;sta GRACTL             ; turn on P/M

                ;lda #$40               ; enable VBI
                ;sta NMIEN

                jmp CLRDSP


;======================================
; Clear out the P/M area
;======================================
PMCLR           lda #0
                ldx #127
PMICLR          sta MISSLS,X            ; MISSILES,
                sta PL0,X               ; PLAYER 0,
                sta PL1,X               ; PLAYER 1,
                sta PL2,X               ; PLAYER 2,
                sta PL3,X               ; AND PLAYER 3!
                dex
                bne PMICLR              ; LOOP UNTIL DONE

RETURN          rts                     ; WE'RE DONE!


;======================================
; PLOT ADDRESS CALCULATOR
;--------------------------------------
; multiply PLOTY by 40, then calculate
; address of the screen memory to be
; altered.
;======================================
PLOTCL          lda PLOTY
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
                sta HI                  ; +DISPLAY START
                lda PLOTX               ; MASK X POSITION
                and #3
                tax
                lda PLOTX
                lsr A
                lsr A
                clc
                adc LO
                sta LO
                lda HI
                adc #0                  ; LO & HI NOW HOLD
                sta HI                  ; THE ADDRESS!
                rts                     ; EXIT!


;--------------------------------------
; CLEAR THE DISPLAY MEMORY
;--------------------------------------
CLRDSP          ldx #0                  ; THIS ROUTINE WILL
                stx PLOTX               ; CLEAR THE SCREEN RAM.
                ldx #0                  ; IT GETS THE ADDRESS
DLOOP2          stx PLOTY               ; OF THE BEGINNING OF
                jsr PLOTCL              ; EACH GR.7 LINE

                ldx PLOTY               ; THEN ZEROES OUT
                lda #$00                ; EACH OF THE
                ldy #39                 ; 40 BYTES (0-39)
DLOOP3          sta (LO),Y              ; IN THE LINE.
                dey
                bpl DLOOP3

                inx
                cpx #86
                bne DLOOP2

;
; DRAW THE COLOR 1 BORDER
;
                lda #3                  ; THIS ROUTINE
                sta BORNUM              ; DRAWS THE 4 LINES
BORDER          ldx BORNUM              ; THAT MAKE UP THE
                lda BXSTRT,X            ; WHITE GR.7 BORDER
                sta PLOTX               ; ON THE SCREEN.
                lda BYSTRT,X
                sta PLOTY
                lda BXINC,X
                sta BDINCX
                lda BYINC,X
                sta BDINCY
                lda BORCNT,X
                sta BDCNT
DRAWLN          jsr PLOTCL

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
                bne DRAWLN

                dec BORNUM
                bpl BORDER

;
; THIS SECTION STARTS OFF EACH LEVEL
;
                lda #80                 ; POSITION THE
                sta PX                  ; PLAYER
                lda #84
                sta PY
                lda LEVEL               ; INCREMENT THE
                clc                     ; LEVEL NUMBER
                adc #1
                sta LOWK
                lda #0                  ; ZERO OUT
                sta CURLO               ; CURRENT TALLY
                sta CURHI               ; WORK AREA
                sta HIWK
                lda #$FF                ; TELL DECIMAL CONVERTER
                sta SLLOC               ; NOT TO PLACE RESULT
                jsr CNVDEC              ; CONVERT LEVEL #

                lda DECIMAL+1           ; GET DECIMAL LEVEL #
                ora #$90                ; ADD COLOR
                sta ScoreLine2+3            ; PUT IN SCORE LINE
                lda DECIMAL             ; SAME FOR 2ND
                ora #$90                ; LEVEL #
                sta ScoreLine2+4            ; DIGIT
                ldx LEVEL               ; GET THIS LEVEL'S
                lda TGTLO,X             ; PARAMETERS
                sta LOWK
                lda TGTHI,X
                sta HIWK
                lda STARSP,X
                sta STRSPD
                lda #4
                sta SLLOC
                jsr CNVDEC              ; SHOW TARGET AMOUNT


;--------------------------------------
; CLEAR OUT THE TRACKING TABLE THAT
; REMEMBERS WHERE THE PLAYER MOVED
;--------------------------------------
CLRTRK          lda #0
                sta SHOOFF
                tax
CLRTLP          sta DIR,X               ; CLEAR DIRECTION
                sta LGTH,X              ; AND LENGTH ENTRIES
                dex
                bne CLRTLP

                sta MOVIX               ; CLEAR MOVEMENT INDEX
                sta DRAWFG              ; AND DRAW FLAG
GETSTK          lda PAUSE               ; GAME PAUSED?
                bne GETSTK              ; YES, LOOP AND WAIT.

                ;lda #$FD               ; DO 'WARBLE' SOUND
                ;sta AUDF1              ; USING SOUND
                ;lda #$FE               ; CHANNELS 1-3
                ;sta AUDF2
                ;lda #$FF
                ;sta AUDF3

                ;lda #$A3               ; volume=3, distortion=5 (pure tone)
                ;sta AUDC1
                ;sta AUDC2
                ;sta AUDC3

                ;lda #0                 ; NO ATTRACT MODE!
                ;sta ATTRACT

                lda DEADFG              ; DID STAR HIT US?
                beq ALIVE               ; NO!

                ldx LEVEL               ; IT HIT US--
                lda KILLFG,X            ; UNCONDITIONAL KILL?
                bne JCRSH               ; YES! WE'RE DEAD!!!

                lda PX                  ; NO, IF WE'RE ON A
                sta PLOTX               ; WHITE LINE (COLOR 1)
                lda PY                  ; THEN WE'RE ALIVE!
                sta PLOTY
                jsr PLOTCL

                ldy #0
                lda BITSON,X
                and (LO),Y
                cmp COLOR1,X            ; ON COLOR 1?
                beq ALIVE               ; YES (WHEW!)

JCRSH           jmp CRASH               ; GO KILL PLAYER.

ALIVE           lda MOVTIM              ; PLAYER MOVING?
                beq GOTSTK              ; YES--GET STICK.

                jmp MOVSTR              ; NO, MOVE STAR.

JGSTK           jmp GETSTK              ; GO GET STICK

GOTSTK          lda #4                  ; SET UP THE
                sta MOVTIM              ; MOVEMENT TIMER
                lda JOYSTICK0           ; GET THE STICK
                sta STKHLD              ; AND SAVE IT
                tax                     ; THEN LOOK UP
                lda XD,X                ; X DIRECTION
                clc
                adc XD,X
                sta XI                  ; AND
                lda YD,X                ; Y DIRECTION
                clc
                adc YD,X
                sta YI
                ora XI                  ; ANY MOVEMENT?
                beq JGSTK               ; NO, TRY AGAIN.

                lda PX                  ; INCREMENT
                clc                     ; PLAYER X
                adc XI                  ; POSITION AND
                sta CKX                 ; HOLD IT...
                cmp #159                ; OFFSCREEN?
                bcs JGSTK               ; YES!

                sta PLOTX               ; NO, SAVE IT
                sec
                sbc XD,X
                sta PXWC
                lda PY                  ; INCREMENT
                clc                     ; PLAYER Y
                adc YI                  ; POSITION AND
                sta CKY                 ; HOLD IT...
                cmp #85                 ; OFFSCREEN?
                bcs JGSTK               ; YES!

                sta PLOTY               ; NO, SAVE IT
                sec
                sbc YD,X
                sta PYWC
                jsr PLOTCL              ; LOCATE NEW PLAYER

                ldy #0                  ; POSITION.
                lda BITSON,X
                and (LO),Y
                sta CKV                 ; SAVE THE 'LOCATE'.
                stx CKVX
                lda PXWC                ; CHECK THE
                sta PLOTX               ; POSITION NEXT
                lda PYWC                ; TO THE ONE WE'RE
                sta PLOTY               ; NOW IN...
                jsr PLOTCL

                ldy #0
                lda BITSON,X
                and (LO),Y
                pha                     ; AND SAVE IT!
                lda JOYSTICK0           ; TRIGGER PRESSED?
                and #$10
                bne NOTDRN              ; NO!

                pla                     ; OK TO DRAW?
                bne JGS                 ; NO!!

                jmp DRAWIN              ; YES, GO DRAW.

NOTDRN          pla                     ; NOT DRAWING--ARE WE
                cmp COLOR1,X            ; ON COLOR 1?
                bne JGS                 ; NO, TRY AGAIN

                lda CKV                 ; ARE WE MOVING
                ldx CKVX                ; ONTO ANOTHER
                cmp COLOR1,X            ; COLOR 1?
                bne JGS                 ; NO! TRY AGAIN.

                lda CKX                 ; ALL'S WELL...
                sta PX                  ; UPDATE PX
                lda CKY                 ; AND
                sta PY                  ; PY,
JGS             jmp GETSTK              ; GET STICK.


;-------------------------------------
; THIS HANDLES THE DRAW FUNCTION.
;-------------------------------------
DRAWIN          lda DRAWFG              ; ALREADY DRAWING?
                bne DRAWOK              ; YES!

                sta MOVIX               ; NO, THIS IS THE
                lda STKHLD              ; FIRST TIME--SET UP
                sta DIR                 ; INITIAL DRAWING
                lda #1                  ; VARIABLES.
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
DRAWOK          lda CKV                 ; DID WE
                ldx CKVX                ; RUN INTO ANOTHER
                cmp COLOR2,X            ; COLOR 2?
                bne NOCRSH              ; NO, WE'RE OK.

                jmp CRASH               ; CRRAAASSSHHH!

NOCRSH          ldx MOVIX               ; UPDATE THE
                lda STKHLD              ; TRACKING
                cmp DIR,X               ; TABLES WITH
                beq SAMDIR              ; DIRECTION

                inc MOVIX               ; INFORMATION.
                inx
                sta DIR,X
                lda #0
                sta LGTH,X
SAMDIR          inc LGTH,X
                lda #3
                sta BDCNT
                lda PX                  ; NOW PLOT THE
                sta PLOTX               ; LINE WE'RE
                lda PY                  ; DRAWING...
                sta PLOTY
CCLOOP          jsr PLOTCL

                ldy #0
                lda (LO),Y
                and BITOFF,X
                ora COLOR2,X            ; IN COLOR 2.
                sta (LO),Y
                dec BDCNT
                beq CKCOLR

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
                jmp CCLOOP

CKCOLR          lda PLOTX               ; UPDATE X POS.
                sta PX
                cmp MAXX                ; CHECK MINIMUM
                bcc TMINX               ; AND MAXIMUM

                sta MAXX                ; X & Y VALUES
                jmp CHKYMM              ; AND UPDATE IF

TMINX           cmp MINX                ; NECESSARY
                bcs CHKYMM

                sta MINX
CHKYMM          lda PLOTY
                sta PY
                cmp MAXY
                bcc TMINY

                sta MAXY
                jmp ENDMM

TMINY           cmp MINY
                bcs ENDMM

                sta MINY
ENDMM           ldx CKVX                ; DID WE DRAW
                lda CKV                 ; INTO
                cmp COLOR1,X            ; COLOR 1?
                beq ENDLIN              ; YES! END OF LINE!

                jmp GETSTK              ; NO, GO GET STICK.

ENDLIN          lda #0                  ; WE AREN'T
                sta DRAWFG              ; DRAWING ANYMORE
                jsr SEARCH              ; SEARCH AND FILL!!

                lda CURLO               ; GET CURRENT VALUE
                sta LOWK
                lda CURHI
                sta HIWK
                lda #15                 ; PUT AT 15TH
                sta SLLOC               ; POS. IN ScoreLine1
                jsr CNVDEC              ; CONVERT TO DECIMAL

                lda #1                  ; NOW REDRAW THE
                sta RDRCOL              ; PLAYER'S PATH IN
                jsr REDRAW              ; COLOR 1 (WHITE).

                ldx LEVEL               ; CHECK TO SEE
                lda CURLO               ; IF WE'VE HIT
                sec                     ; THE TARGET.
                sbc TGTLO,X
                sta LOWK
                lda CURHI
                sbc TGTHI,X
                sta HIWK                ; HIT TARGET?
                bpl NEWLVL              ; YES--NEW LEVEL!

                jmp CLRTRK              ; NO, GO CLEAR TRACK

NEWLVL          lda LEVEL               ; IF LEVEL < 15
                cmp #15                 ; THEN
                beq NOLINC              ; INCREMENT

                inc LEVEL               ; LEVEL
;
; INCREASE SCORE HERE
;
NOLINC          asl LOWK                ; SCORE INC =
                rol HIWK                ; TGT-CUR * 2
                lda #$FF                ; DON'T PLACE
                sta SLLOC               ; THE RESULT!
                jsr CNVDEC              ; CONVERT TO DECIMAL

                ldx #5                  ; AND ADD TO SCORE
                ldy #0
SCOLP           lda DECIMAL,Y
                clc
                adc SCORE,X
                cmp #10
                bmi NOCARY

                sec
                sbc #10
                sta SCORE,X
                inc SCORE-1,X
                jmp NXSPOS

NOCARY          sta SCORE,X
NXSPOS          iny
                dex
                bpl SCOLP

                ldx #5                  ; NOW PLACE THE
SHSLP           lda SCORE,X             ; SCORE IN
                ora #$10                ; SCORE LINE #2
                sta ScoreLine2+12,X
                dex
                bpl SHSLP

                lda #1                  ; STOP VBI FOR
                sta FILLON              ; A MOMENT
                sta SHOOFF
                jsr PMCLR               ; CLEAR P/M AREA

                lda #64                 ; INITIALIZE
                sta STRHGT              ; THE
                lda #128                ; STAR
                sta STRHOR              ; POSITION
                lda #0                  ; VBI ON AGAIN
                sta FILLON
                jmp CLRDSP              ; GO CLEAR DISPLAY!


;--------------------------------------
; THIS SECTION HANDLES PLAYER'S DEATH
;--------------------------------------
CRASH           ;lda #0                 ; NO WARBLE SOUND
                ;sta AUDC1              ; volume=0, distortion=0
                ;sta AUDC2
                ;sta AUDC3

                lda #1                  ; NO PLAYER COLOR
                sta NOCCHG              ; CHANGE IN VBI
                lda #15                 ; SET BRIGHTNESS OF
                sta DEDBRT              ; PLAYER DEATH.
TIMRST          lda #5                  ; SET DEATH TIMER
                sta TIMER               ; TO 5 JIFFIES.
DEADCC          ;lda DEDBRT             ; MOVE BRIGHTNESS
                ;sta AUDC1              ; TO DEATH SOUND VOLUME ; volume=variable, distortion=0

                ;lda SID_RANDOM         ; GET RANDOM
                ;and #$1F               ; DEATH SOUND
                ;sta AUDF1              ; FREQUENCY

                lda SID_RANDOM          ; GET RANDOM
                and #$F0                ; DEATH COLOR
                ora DEDBRT              ; ADD BRITE
                ;sta COLPF1             ; PUT IN LINE COLOR
                ;sta COLPM3             ; AND PLAYER COLOR
                lda TIMER               ; TIMER DONE YET?
                bne DEADCC              ; NO, GO CHANGE COLOR.

                dec DEDBRT              ; DECREMENT BRIGHTNESS
                bpl TIMRST              ; IF MORE, GO DO IT.

                dec LIVES               ; 1 LESS LIFE
                lda LIVES               ; GET # LIVES
                ora #$90                ; ADD COLOR
                sta ScoreLine2+19       ; AND DISPLAY!
                cmp #$90                ; ZERO LIVES?
                bne NOTDED              ; NO!

                lda #<GameOver          ; WE'RE COMPLETELY
                sta SCDL+1              ; DEAD, SHOW
                lda #>GameOver          ; 'GAME OVER'
                sta SCDL+2              ; MESSAGE
CKSTRT          lda CONSOL              ; WAIT FOR START
                and #1                  ; KEY...
                bne CKSTRT              ; NOT PRESSED--LOOP.

RELEAS          lda CONSOL              ; KEY PRESSED, NOW
                and #1                  ; WAIT FOR RELEASE!
                beq RELEAS              ; NOT RELEASED YET!

                lda #<ScoreLine1        ; PUT SCORE
                sta SCDL+1              ; LINE BACK
                lda #>ScoreLine1        ; IN DISPLAY
                sta SCDL+2              ; LIST...
                jmp START               ; AND START GAME!


;--------------------------------------
; THIS SECTION PLACES PLAYER AT A RANDOM
; LOCATION IF THERE ARE MORE LIVES LEFT.
;--------------------------------------
NOTDED          lda #1                  ; DON'T SHOW
                sta SHOOFF              ; PLAYER
NEWLOC          lda SID_RANDOM          ; GET RANDOM X
                and #$FE                ; MUST BE EVEN
                cmp #159                ; AND ON SCREEN
                bcs NEWLOC

                sta PLOTX
CSHY            lda SID_RANDOM          ; GET RANDOM Y
                and #$7E                ; MUST BE EVEN
                cmp #85                 ; AND ON SCREEN
                bcs CSHY

                sta PLOTY
                jsr PLOTCL

                ldy #0
                lda BITSON,X
                and (LO),Y              ; IS LOCATION ON
                cmp COLOR1,X            ; COLOR 1?
                bne NEWLOC              ; NO, TRY AGAIN.

                jsr PMCLR               ; IT'S OK, CLEAR P/M

                lda PLOTX               ; SAVE
                sta PX                  ; THE PLAYER'S
                lda PLOTY               ; NEW
                sta PY                  ; COORDINATES.
                lda #0                  ; REDRAW THE
                sta RDRCOL              ; PLAYER'S TRACK
                lda HASDRN              ; IN COLOR 0
                beq JCTRK

                jsr REDRAW

                lda INIX                ; THIS PART IS
                sta PLOTX               ; NEEDED TO PLOT
                lda INIY                ; A COLOR 1 BLOCK
                sta PLOTY               ; AT THE START OF
                jsr PLOTCL              ; THE PLAYER'S TRACK

                ldy #0                  ; AFTER IT IS ERASED.
                lda BITOFF,X            ; (NOBODY'S PERFECT!)
                and (LO),Y
                ora COLOR1,X
                sta (LO),Y
JCTRK           ;lda #$24               ; RESTORE DRAW LINE
                ;sta COLPF1             ; COLOR

                lda #0
                sta NOCCHG
                ;sta HITCLR             ; clear collisions
                sta DEADFG
                jmp CLRTRK              ; AND GO START NEW TRACK.


;======================================
;
;--------------------------------------
; This routine uses the tracking tables,
; DIR and LGTH, to redraw the line the
; player drew.  RDRCOL indicates the color
; desired.
;======================================
REDRAW          lda INIX
                sta REX
                lda INIY
                sta REY
                lda #0
                sta X
REDXLP          ldx X
                lda DIR,X
                sta REDIR
                lda LGTH,X
                sta LGTHY
                lda #1
                sta Y
REDYLP          lda #3
                sta TIMES
TIMES3          lda REX
                sta PLOTX
                lda REY
                sta PLOTY
                jsr PLOTCL

                ldy #0
                lda RDRCOL
                bne RDC1

                lda BITOFF,X
                and (LO),Y
                sta (LO),Y
                jmp SETNRP

ENDRD           lda #0
                sta DRAWFG
                rts

RDC1            lda BITOFF,X
                and (LO),Y
                ora COLOR1,X
                sta (LO),Y
SETNRP          dec TIMES
                beq NXTY

                ldx REDIR
                lda REX
                clc
                adc XD,X
                sta REX
                lda REY
                clc
                adc YD,X
                sta REY
                jmp TIMES3

NXTY            inc Y
                lda Y
                cmp LGTHY
                beq JNRD

                bcs NXTX

JNRD            jmp REDYLP

NXTX            inc X
                lda X
                cmp MOVIX
                beq JRXLP

                bcs ENDRD

JRXLP           jmp REDXLP


;======================================
; 2-BYTE DECIMAL CONVERTER
;--------------------------------------
; Converts a 2-byte binary number to a
; 5-byte decimal number.  Will place
; the decimal number in ScoreLine1 if
; desired (SLLOC determines position).
;======================================
CNVDEC          ldx #4
                lda #0
CDLP            sta DECIMAL,X
                dex
                bpl CDLP

                ldx #4
CKMAG           lda HIWK
                cmp HIVALS,X
                beq CKM2

                bcs SUBEM

                bcc NOSUB

CKM2            lda LOWK
                cmp LOVALS,X
                bcs SUBEM

NOSUB           dex
                bpl CKMAG

                jmp SHOWIT

SUBEM           lda LOWK
                sec
                sbc LOVALS,X
                sta LOWK
                lda HIWK
                sbc HIVALS,X
                sta HIWK
                inc DECIMAL,X
                jmp CKMAG

SHOWIT          ldx #$4
                ldy SLLOC
                bmi SHEND

SHOLP           lda DECIMAL,X
                ora #$D0
                sta ScoreLine1,Y
                iny
                dex
                bpl SHOLP

SHEND           rts


;======================================
; MOVES THE STAR AROUND ON THE PLAYFIELD.
;--------------------------------------
; THE STAR IS ROTATED AND PLOTTED
; (IN A PLAYER) IN THE VBI.
;======================================
MOVSTR          lda SMTIM               ; TIME TO MOVE?
                beq MSTR                ; YES, GO DO IT

                jmp GETSTK              ; NO, GET STICK

MSTR            lda STRSPD              ; SET MOVEMENT TIMER
                sta SMTIM               ; WITH STAR SPEED
                lda STRHGT              ; ADJUST P/M
                sec                     ; COORDINATES TO
                sbc #13                 ; MATCH PLAYFIELD
                sta STRLY               ; PLOTTING
                lda STRHOR              ; COORDINATES.
                sec
                sbc #44
                sta STRLX
                lda SID_RANDOM          ; WANT TO CHANGE
                cmp #240                ; THE STAR'S DIRECTION?
                bcc SAMSTD              ; NO, USE SAME.

NEWDIR          lda SID_RANDOM          ; GET RANDOM
                and #7                  ; DIRECTION
                jmp DIRCHK

SAMSTD          lda STRDIR              ; GET OLD DIRECTION.
DIRCHK          tax                     ; CHECK TO SEE
                sta TMPDIR              ; IF STAR WILL
                lda STRLX               ; BUMP INTO ANY
                clc                     ; PLAYFIELD
                adc STRDTX,X            ; OBJECT.
                sta PLOTX
                lda STRLY
                clc
                adc STRDTY,X
                sta PLOTY
                jsr PLOTCL

                ldy #0
                lda BITSON,X
                and (LO),Y              ; ANY COLLISION?
                beq WAYCLR              ; NO, ALL CLEAR!

                lda #15                 ; HIT SOMETHING,
                sta BSCNT               ; START BUMP SOUND AND
                bne NEWDIR              ; GET NEW DIRECTION.

WAYCLR          lda PLOTX               ; ADJUST STAR
                clc                     ; COORDINATES
                adc #44                 ; BACK TO P/M
                sta STRHOR              ; COORDINATES
                lda PLOTY               ; FROM PLAYFIELD.
                clc
                adc #13
                sta STRHGT
                lda TMPDIR              ; SET DIRECTION
                sta STRDIR
                jmp GETSTK              ; AND LOOP


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
SEARCH          lda #1
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
FINDCL          ldx D
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
                jsr PLOTCL

                ldy #0
                lda (LO),Y
                and BITSON,X
                cmp COLOR1,X
                beq FINDC2

                cmp COLOR2,X
                bne FINDCL

                lda #0
                sta TD
                jmp FOUND2

FINDC2          lda D
                sta TD
                jsr DECD

FC2A            jsr SRCHLC

                cmp COLOR1,X
                bne FC2B

                jsr GRABEM

                jmp FINDC2

FC2B            cmp COLOR2,X
                bne FC2C

                jsr GRABEM

                jmp OUTLIN

FC2C            jsr INCD

                jmp FC2A

FOUND2          lda #0
                sta TRIES
                jsr DECD

FND2A           jsr SRCHLC

                cmp COLOR2,X
                bne FND2B

                jsr GRABEM

                jmp FOUND2

FND2B           lda TRIES
                clc
                adc #1
                sta TRIES
                cmp #3
                beq FINDC1

                jsr INCD

                jmp FND2A

FINDC1          lda D
                sta TD
                jsr DECD

FC1A            jsr SRCHLC

                cmp COLOR1,X
                bne FC1B

                jsr GRABEM

                jmp FINDC2

FC1B            jsr INCD

                jmp FC1A

OUTLIN          jsr PLSXSY

                lda #0
                sta TRIES
OUTLA           jsr SRCHLC

                cmp COLOR1,X
                bne OUTLB

                jsr GRABEM

                jmp OUTLIN

OUTLB           lda TRIES
                clc
                adc #1
                sta TRIES
                cmp #4
                beq OUTLD

                jsr INCD

                jmp OUTLA

OUTLD           jsr LOCTXY

OUTLD2          cmp COLOR2,X
                bne OUTLE

                jsr FILL

                lda #0
                sta FILLON
                rts

OUTLE           jsr INCD

                jsr SRCHLC

                jmp OUTLD2


;======================================
;
;======================================
SRCHLC          ldx TD
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


;======================================
;
;======================================
LOCTXY          lda PLOTX
                cmp #159
                bcs NOREAD

                lda PLOTY
                cmp #85
                bcs NOREAD

                jsr PLOTCL

                ldy #0
                lda (LO),Y
                and BITSON,X
                rts

NOREAD          lda #0
                ldx #0
                rts


;======================================
;
;======================================
GRABEM          lda TD
                sta D
                lda TX
                sta SX
                lda TY
                sta SY
                rts


;======================================
;
;======================================
INCD            lda TD
                clc
                adc #1
                and #3
                sta TD
                rts


;======================================
;
;======================================
DECD            lda TD
                sec
                sbc #1
                and #3
                sta TD
                rts


;======================================
;
;======================================
PLSXSY          lda SX
                sta PLOTX
                cmp MAXX
                bcc TMINX2

                sta MAXX
                jmp CKYMM2

TMINX2          cmp MINX
                bcs CKYMM2

                sta MINX
CKYMM2          lda SY
                sta PLOTY
                cmp MAXY
                bcc TMINY2

                sta MAXY
                jmp ENDMM2

TMINY2          cmp MINY
                bcs ENDMM2

                sta MINY
ENDMM2          jsr PLOTCL

                ldy #0
                lda BITOFF,X
                and (LO),Y
                ora COLOR2,X
                sta (LO),Y
                rts


;======================================
; FILL ROUTINE
;--------------------------------------
; AS WITH THE 'SEARCH' SUBROUTINE, THE
; FILL SUBROUTINE IS FAR TOO COMPLEX TO
; EXPLAIN HERE.  THIS FILL IS ENTIRELY
; DIFFERENT FROM THE SYSTEM'S FILL
; ROUTINE, AS IT WILL FILL ANY SHAPE
; THAT IS OUTLINED IN COLOR 2.
;======================================
FILL            ;lda #0                 ; TURN OFF
                ;sta AUDC2              ; SOUND CHANNELS
                ;sta AUDC3              ; 2 AND 3.

                lda MAXY                ; INITIALIZE
                sec                     ; THE FILL
                sbc MINY                ; SOUND
                sta FILFRQ              ; FREQUENCY.
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
CLRC2T          lda #0
                sta C2TALY
LOCLP1          jsr LOCATE

                cmp #2
                bne LOCLP1

LOCLP2          inc C2TALY
                jsr LOCATE

                cmp #2
                beq LOCLP2

                and #1
                bne CLRC2T

                lda C2TALY
                cmp #1
                beq FILLIT

                jsr LOCPRV

                beq CLRC2T

FILLIT          lda FX
                sta PLOTX
                lda FY
                sta PLOTY
                jsr PLOTCL

                ldy #0
                lda (LO),Y
                ora COLOR3,X
                sta (LO),Y
                inc SCTALY
                jsr LOCATE

                cmp #0
                beq FILLIT

                and #1
                bne CLRC2T

                lda #1
                sta C2TALY
FOLLOW          jsr LOCATE

                cmp #0
                beq LOCLP3

                and #1
                bne CLRC2T

                inc C2TALY
                jmp FOLLOW

LOCLP3          lda C2TALY
                cmp #1
                bne LOCLP4

                jmp CLRC2T

LOCLP4          jsr LOCPRV

                cmp BITSON,X
                beq FILLIT

                jmp CLRC2T


;======================================
;
;======================================
LOCATE          lda FX
                clc
                adc #1
                sta FX
                cmp MAXX
                bne STOFX

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
                beq NOFFDC

                dec FILFRQ
NOFFDC          lda FY
                clc
                adc #1
                sta FY
                cmp MAXY
                beq FILEND

                lda FX
                cmp MINX
                bne STOFX

                pla
                pla
                jmp CLRC2T

FILEND          pla
                pla
                rts

STOFX           lda FX
                sta PLOTX
                lda FY
                sta PLOTY
                jsr PLOTCL

                ldy #0
                lda BITSON,X
                and (LO),Y
                cmp COLOR2,X
                bne NOTC2

                lda BITSON,X
                ora (LO),Y
                sta (LO),Y
                inc SCTALY
                lda #2
                rts

NOTC2           cmp COLOR1,X
                bne NOTC1

                lda #1
                rts

NOTC1           cmp #0
                bne C3

                rts

C3              lda #3
                rts


;======================================
;
;======================================
LOCPRV          lda FX
                sta PLOTX
                lda FY
                sec
                sbc #1
                cmp MINY
                beq NOLOCP

                sta PLOTY
                jsr PLOTCL

                ldy #0
                lda BITSON,X
                and (LO),Y
                rts

NOLOCP          lda #0
                ldx #0
                rts


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; VBI ROUTINE
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
INTRPT          lda KEYCHAR             ; IS SPACE BAR
                cmp #$21                ; PRESSED?
                bne NOPRES              ; NO, CHECK FOR PAUSE.

                lda #$FF                ; CLEAR OUT
                sta KEYCHAR             ; KEY CODE,
                lda PAUSE               ; COMPLEMENT
                eor #$FF                ; THE PAUSE
                sta PAUSE               ; FLAG.
NOPRES          lda PAUSE               ; ARE WE PAUSED?
                beq NOPAUS              ; NO!

                rti                     ; PAUSED, NO VBI!

NOPAUS          lda BSCNT               ; MORE BUMP SOUND?
                bmi NOBS                ; NO, PROCESS TIMER.

                ;ora #$A0               ; MIX VOLUME WITH
                ;sta AUDC4              ; PURE TONE,

                ;lda #$80               ; SET UP BUMP
                ;sta AUDF4              ; SOUND FREQUENCY
                dec BSCNT               ; AND DECREMENT COUNT.
NOBS            lda TIMER               ; TIMER DOWN TO ZERO?
                beq NODEC               ; YES, DON'T DECREMENT.

                dec TIMER               ; DECREMENT TIMER.
NODEC           lda FILLON              ; ARE WE FILLING?
                beq NOFILL              ; NO, DO REST OF VBI.

                rti                     ; YES, EXIT VBI

NOFILL          lda #0                  ; CLEAR OUT
                sta DEADFG              ; DEAD FLAG

                ;lda P0PL                ; HAS PLAYER 0
                ;and #$08                ; HIT PLAYER 3?
                ;beq NOHITP              ; NO!
                bra NOHITP  ; HACK:

                inc DEADFG              ; YES!!!
NOHITP          ;lda P0PF                ; HAS PLAYER 0
                ;and #$02                ; HIT COLOR 2?
                ;beq NOHITL              ; NO!
                bra NOHITL ; HACK:

                inc DEADFG              ; YES!!!
NOHITL          ;sta HITCLR             ; clear collisions
                lda MOVTIM              ; MOVEMENT TIMER ZERO?
                beq NOMDEC              ; YES, DON'T DECREMENT.

                dec MOVTIM              ; DECREMENT TIMER.
NOMDEC          lda SMTIM               ; STAR MOVE TIMER ZERO?
                beq NMTDEC              ; YES, DON'T DECREMENT.

                dec SMTIM               ; DECREMENT TIMER.
NMTDEC          lda STARCT              ; STAR ROT. TIMER ZERO?
                beq STAROT              ; YES, ROTATE STAR!

                dec STARCT              ; DECREMENT TIMER
                jmp VBREST              ; AND SKIP ROTATION.

STAROT          lda #1                  ; SET ROT. TIMER
                sta STARCT              ; TO 1
                lda STRPOS              ; INCREMENT
                clc                     ; STAR ROTATION
                adc #1                  ; COUNTER,
                cmp #7                  ; ALLOW ONLY 0-6.
                bne STOSTP              ; ROT. COUNT OK

                lda #0                  ; ZERO ROT. COUNTER.
STOSTP          sta STRPOS              ; SAVE ROT. POS.
VBREST          ldy STRPOS              ; THIS SECTION
                ldx STRHGT              ; DRAWS THE STAR
                lda #0                  ; IN PLAYER 0
                sta PL0-1,X             ; MEMORY USING
                sta PL0+8,X             ; THE TABLES
                lda STARB1,Y            ; 'STARB1' THRU
                sta PL0,X               ; 'STARB8'.
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

                lda STRHOR              ; SET STAR'S
                sta SP00_X_POS          ; HORIZ. POS.

                lda SHOOFF              ; OK TO SHOW PLAYER?
                bne ENDVBI              ; NO, EXIT VBI

                lda PX                  ; SET PLAYER'S
                clc                     ; HORIZONTAL
                adc #47                 ; POSITION
                sta SP03_X_POS

                lda PY                  ; DRAW PLAYER
                clc                     ; IN PLAYER 3
                adc #$10                ; MEMORY
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
                lda NOCCHG              ; COLOR CHANGE OK?
                bne ENDVBI              ; NO, EXIT VBI

                ;inc COLPM3             ; YES, CYCLE THE COLOR.
ENDVBI          rti                     ; DONE WITH VBI!


;--------------------------------------
;--------------------------------------

DLIST           ;.byte AEMPTY8,AEMPTY8,AEMPTY8

                ;.byte $0D+ALMS
                ;    .addr DISP
                ;.byte $0D,$0D,$0D,$0D
                ;.byte $0D,$0D,$0D,$0D
                ;.byte $0D,$0D,$0D,$0D
                ;.byte $0D,$0D,$0D,$0D
                ;.byte $0D,$0D,$0D,$0D
                ;.byte $0D,$0D,$0D,$0D
                ;.byte $0D,$0D,$0D,$0D
                ;.byte $0D,$0D,$0D,$0D
                ;.byte $0D,$0D,$0D,$0D
                ;.byte $0D,$0D,$0D,$0D
                ;.byte $0D,$0D,$0D,$0D
                ;.byte $0D,$0D,$0D,$0D
                ;.byte $0D,$0D,$0D,$0D
                ;.byte $0D,$0D,$0D,$0D
                ;.byte $0D,$0D,$0D,$0D
                ;.byte $0D,$0D,$0D,$0D
                ;.byte $0D,$0D,$0D,$0D
                ;.byte $0D,$0D,$0D,$0D
                ;.byte $0D,$0D,$0D,$0D
                ;.byte $0D,$0D,$0D,$0D
                ;.byte $0D,$0D,$0D,$0D
                ;.byte $0D

                ;.byte AEMPTY3
SCDL            ;.byte $06+ALMS
                ;    .addr ScoreLine1
                ;.byte $06+ALMS
                ;    .addr ScoreLine2
                ;.byte AVB+AJMP
                ;    .addr DLIST

ScoreLine1      .text 'TGT:       CUR:     '
ScoreLine2      .text 'LV:   SCORE:        '
GameOver        .text '     GAME  OVER     '

;
; LEVEL TABLES
;
TGTLO           .byte 64,16,224,40,248,212,16,4
                .byte 248,224,212,224,68,168,112,212
TGTHI           .byte 31,39,46,35,42,48,39,41,42
                .byte 46,48,46,47,47,48,48
STARSP          .byte 4,4,4,3,3,3,2,2,2,2,2,1,1
                .byte 1,1,1
KILLFG          .byte 0,0,1,0,1,1,0,1,1,1,1,0,0
                .byte 1,1,1

ZERO1           .byte 0
SCORE           .byte 0,0,0,0,0,0
SLLOC           .byte 0
CURLO           .byte 0
CURHI           .byte 0
LEVEL           .byte 0
PAUSE           .byte 0
HASDRN          .byte 0
LOWK            .byte 0
HIWK            .byte 0
SCTALY          .byte 0
LIVES           .byte 0

;
; STAR PLAYER-MISSILE IMAGES
;
STARB1          ;.byte $81,$40,$20,$10,$08,$04,$02
                .byte %10000001         ; #......#
                .byte %01000000         ; .#......
                .byte %00100000         ; ..#.....
                .byte %00010000         ; ...#....
                .byte %00001000         ; ....#...
                .byte %00000100         ; .....#..
                .byte %00000010         ; ......#.
STARB2          ;.byte $42,$43,$20,$10,$08,$04,$C2
                .byte %01000010         ; .#....#.
                .byte %01000011         ; .#....##
                .byte %00100000         ; ..#.....
                .byte %00010000         ; ...#....
                .byte %00001000         ; ....#...
                .byte %00000100         ; .....#..
                .byte %11000010         ; ##....#.
STARB3          ;.byte $24,$24,$13,$10,$08,$C8,$24
                .byte %00100100         ; ..#..#..
                .byte %00100100         ; ..#..#..
                .byte %00010011         ; ...#..##
                .byte %00010000         ; ...#....
                .byte %00001000         ; ....#...
                .byte %11001000         ; ##..#...
                .byte %00100100         ; ..#..#..
STARB4          ;.byte $18,$18,$1C,$1F,$F8,$38,$18
                .byte %00011000         ; ...##...
                .byte %00011000         ; ...##...
                .byte %00011100         ; ...###..
                .byte %00011111         ; ...#####
                .byte %11111000         ; #####...
                .byte %00111000         ; ..###...
                .byte %00011000         ; ...##...
STARB5          ;.byte $18,$18,$38,$F8,$1F,$1C,$18
                .byte %00011000         ; ...##...
                .byte %00011000         ; ...##...
                .byte %00111000         ; ..###...
                .byte %11111000         ; #####...
                .byte %00011111         ; ...#####
                .byte %00011100         ; ...###..
                .byte %00011000         ; ...##...
STARB6          ;.byte $24,$24,$C8,$08,$10,$13,$24
                .byte %00100100         ; ..#..#..
                .byte %00100100         ; ..#..#..
                .byte %11001000         ; ##..#...
                .byte %00001000         ; ....#...
                .byte %00010000         ; ...#....
                .byte %00010011         ; ...#..##
                .byte %00100100         ; ..#..#..
STARB7          ;.byte $42,$C2,$04,$08,$10,$20,$43
                .byte %01000010         ; .#....#.
                .byte %11000010         ; ##....#.
                .byte %00000100         ; .....#..
                .byte %00001000         ; ....#...
                .byte %00010000         ; ...#....
                .byte %00100000         ; ..#.....
                .byte %01000011         ; .#....##
STARB8          ;.byte $81,$02,$04,$08,$10,$20,$40
                .byte %10000001         ; #......#
                .byte %00000010         ; ......#.
                .byte %00000100         ; .....#..
                .byte %00001000         ; ....#...
                .byte %00010000         ; ...#....
                .byte %00100000         ; ..#.....
                .byte %01000000         ; .#......

STARCT          .byte 0
STRPOS          .byte 0
STRHGT          .byte 0
STRHOR          .byte 0
STRLX           .byte 0
STRLY           .byte 0
TMPDIR          .byte 0
STRDIR          .byte 0
STRDTX          .byte 1,1,0,255,255,255,0,1
STRDTY          .byte 0,1,1,0,1,255,255,255
STRSPD          .byte 4
COLOR1          .byte $40,$10,$04,$01
COLOR2          .byte $80,$20,$08,$02
COLOR3          .byte $C0,$30,$0C,$03
BITSON          .byte $C0,$30,$0C,$03
BITOFF          .byte $3F,$CF,$F3,$FC
BXSTRT          .byte 0,158,158,0
BYSTRT          .byte 0,0,84,84
BXINC           .byte 1,0,255,0
BYINC           .byte 0,1,0,255
BORCNT          .byte 159,85,159,85
BORNUM          .byte 0
BDINCX          .byte 0
BDINCY          .byte 0
BDCNT           .byte 0
PXWC            .byte 0
PYWC            .byte 0
SHOOFF          .byte 0
CKX             .byte 0
CKY             .byte 0
INIX            .byte 0
INIY            .byte 0
MINX            .byte 0
MINY            .byte 0
MAXX            .byte 0
MAXY            .byte 0
REX             .byte 0
REY             .byte 0
X               .byte 0
Y               .byte 0
SX              .byte 0
SY              .byte 0
TX              .byte 0
TY              .byte 0
FX              .byte 0
FY              .byte 0
TD              .byte 0
D               .byte 0
BSCNT           .byte 0
FILFRQ          .byte 0
TRIES           .byte 0
FILLON          .byte 0
C2TALY          .byte 0
NOCCHG          .byte 0
DEDBRT          .byte 0
STKHLD          .byte 0
RDRCOL          .byte 0
REDIR           .byte 0
LGTHY           .byte 0
TIMES           .byte 0
CKV             .byte 0
CKVX            .byte 0
DRAWFG          .byte 0
MOVIX           .byte 0
XD              .byte 0,0,0,0
                .byte 0,0,0,1
                .byte 0,0,0,255
                .byte 0,0,0,0
YD              .byte 0,0,0,0
                .byte 0,0,0,0
                .byte 0,0,0,0
                .byte 0,1,255,0
SXD             .byte 0,1,0,255
SYD             .byte 255,0,1,0
DECIMAL         .byte 0,0,0,0,0
ZERO2           .byte 0
HIVALS          .byte 0,0,0,3,39
LOVALS          .byte 1,10,100,232,16
DIR             .fill 256
LGTH            .fill 256


;--------------------------------------
                .align $100
;--------------------------------------

                .include "FONT.asm"
