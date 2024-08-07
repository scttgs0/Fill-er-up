
GameOver                .text "     GAME  OVER     "    ; double-wide text
ScoreLine1              .text "TGT:      CUR:      "    ; double-wide text
ScoreLine2              .text "LV:   SCORE:        "    ; double-wide text

GameOverColor           .byte $00,$00,$00,$00,$00       ; separator
                        .byte $E0,$E0,$E0,$E0           ; label
                        .byte $00,$00                   ; separator
                        .byte $E0,$E0,$E0,$E0           ; label
                        .byte $00,$00,$00,$00,$00       ; separator

ScoreLine1Color         .byte $10,$10,$10,$10           ; label
                        .byte $E0,$E0,$E0,$E0,$E0       ; value
                        .byte $00                       ; separator
                        .byte $10,$10,$10,$10           ; label
                        .byte $50,$50,$50,$50,$50       ; value
                        .byte $00                       ; separator

ScoreLine2Color         .byte $10,$10,$10               ; label
                        .byte $30,$30                   ; value
                        .byte $00                       ; separator
                        .byte $10,$10,$10,$10,$10,$10   ; label
                        .byte $50,$50,$50,$50,$50,$50   ; value
                        .byte $00                       ; separator
                        .byte $30                       ; value

;--------------------------------------
; LEVEL TABLES
;--------------------------------------
TargetLO                .byte 64,16,224,40,248,212,16,4
                        .byte 248,224,212,224,68,168,112,212

TargetHI                .byte 31,39,46,35,42,48,39,41
                        .byte 42,46,48,46,47,47,48,48

STARSP                  .byte 4,4,4,3,3,3,2,2
                        .byte 2,2,2,1,1,1,1,1

isUnconditionalKill     .byte 0,0,1,0,1,1,0,1
                        .byte 1,1,1,0,0,1,1,1

SCORE                   .byte 0,0,0,0,0,0
SLLOC                   .byte 0
CurrentLO               .byte 0
CurrentHI               .byte 0
LEVEL                   .byte 0
isPaused                .byte 0
hasDrawn                .byte 0
LOWK                    .byte 0
HIWK                    .byte 0
ScoreTally              .byte 0
LIVES                   .byte 0

;--------------------------------------

StarRotTbl              .addr SPR_STAR0,SPR_STAR1
                        .addr SPR_STAR2,SPR_STAR3
                        .addr SPR_STAR4,SPR_STAR5
                        .addr SPR_STAR6

vStarRotTimer           .byte 0
StarRotPos              .byte 0
StarVertPos             .byte 0
StarHorzPos             .byte 0
StarLiteralX            .byte 0
StarLiteralY            .byte 0
TempDirection           .byte 0
StarDirection           .byte 0
StarDeltaX              .byte 1,1,0,255,255,255,0,1
StarDeltaY              .byte 0,1,1,0,1,255,255,255
StarSpeed               .byte 4

COLOR1                  .byte $40,$10,$04,$01
COLOR2                  .byte $80,$20,$08,$02
COLOR3                  .byte $C0,$30,$0C,$03

BitsOn                  .byte $C0,$30,$0C,$03
BitsOff                 .byte $3F,$CF,$F3,$FC

BXSTRT                  .byte 4,154,154,4
BYSTRT                  .byte 0,0,84,84
BXINC                   .byte 1,0,255,0
BYINC                   .byte 0,1,0,255
BORCNT                  .byte 151,85,151,85
BORNUM                  .byte 0

BDINCX                  .byte 0
BDINCY                  .byte 0
BDCNT                   .byte 0

PXWC                    .byte 0
PYWC                    .byte 0

isHidePlayer            .byte 0
CKX                     .byte 0
CKY                     .byte 0
INIX                    .byte 0
INIY                    .byte 0
MINX                    .byte 0
MINY                    .byte 0
MAXX                    .byte 0
MAXY                    .byte 0
REX                     .byte 0
REY                     .byte 0
X                       .byte 0
Y                       .byte 0
SX                      .byte 0
SY                      .byte 0
TX                      .byte 0
TY                      .byte 0
FX                      .byte 0
FY                      .byte 0
TD                      .byte 0
D                       .byte 0
vBumpSndCount           .byte 0
FILFRQ                  .byte 0
TRIES                   .byte 0
isFillOn                .byte 0
C2TALY                  .byte 0
isPreventColorChange    .byte 0
DEDBRT                  .byte 0
StickHold               .byte 0
RDRCOL                  .byte 0
REDIR                   .byte 0
LGTHY                   .byte 0
TIMES                   .byte 0
CKV                     .byte 0
CKVX                    .byte 0
isDrawActive            .byte 0
MoveIndex               .byte 0

XD                      .byte 0,0,0,0
                        .byte 0,0,0,1       ; %0111 = right := 1
                        .byte 0,0,0,255     ; %1011 = left  := 255
                        .byte 0,0,0,0
YD                      .byte 0,0,0,0
                        .byte 0,0,0,0
                        .byte 0,0,0,0       ; %1101 = down  := 1
                        .byte 0,1,255,0     ; %1110 = up    := 255

SXD                     .byte 0,1,0,255
SYD                     .byte 255,0,1,0

DECIMAL                 .byte 0,0,0,0,0
ZERO2                   .byte 0

HIVALS                  .byte 0,0,0,3,39
LOVALS                  .byte 1,10,100,232,16

DIR                     .fill 256
LGTH                    .fill 256
