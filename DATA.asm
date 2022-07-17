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

ScoreLine1      .text 'TGT:      CUR:      '
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

vStarRotTimer   .byte 0
vStarRotPosition .byte 0
vStarHeight     .byte 0
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
vBumpSndCount   .byte 0
FILFRQ          .byte 0
TRIES           .byte 0
isFillOn        .byte 0
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
