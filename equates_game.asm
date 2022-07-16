;--------------------------------------
; Miscellaneous Memory Usage
;--------------------------------------

PMAREA          = $1000
MISSLS          = PMAREA+384
PL0             = PMAREA+512
PL1             = PMAREA+640
PL2             = PMAREA+768
PL3             = PMAREA+896

DISP            = $B00000

CharResX        = 40
CharResY        = 30

panelTarget     = ScoreLine1+4
panelCurrent    = ScoreLine1+15
panelLevel      = ScoreLine2+3
panelScore      = ScoreLine2+12
panelLives      = ScoreLine2+19
