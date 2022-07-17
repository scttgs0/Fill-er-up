;--------------------------------------
; Miscellaneous Memory Usage
;--------------------------------------

PMAREA          = $1000
SPR_STAR        = PMAREA+512            ; star
SPR_PLAYER      = PMAREA+896            ; player

DISP            = $B00000

CharResX        = 40
CharResY        = 30

panelTarget     = ScoreLine1+4
panelCurrent    = ScoreLine1+14
panelLevel      = ScoreLine2+3
panelScore      = ScoreLine2+12
panelLives      = ScoreLine2+19
