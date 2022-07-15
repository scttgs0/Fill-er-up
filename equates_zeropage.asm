;--------------------------------------
; Zero-page Equates
;--------------------------------------

LO              = $CB
HI              = $CC
PLOTX           = $CD
PLOTY           = $CE
LOHLD           = $CF
HIHLD           = $D0
SMTIM           = $D1
MOVTIM          = $D2
TIMER           = $D3
DEADFG          = $D4
PX              = $D5
PY              = $D6
XI              = $D7
YI              = $D8

JIFFYCLOCK      = $D9
InputFlags      = $DA
InputType       = $DB
itJoystick  = 0
itKeyboard  = 1
KEYCHAR         = $DC                   ; last key pressed
CONSOL          = $DD                   ; state of OPTION,SELECT,START
