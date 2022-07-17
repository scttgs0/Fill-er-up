;--------------------------------------
; Zero-page Equates
;--------------------------------------

LO              = $CB
HI              = $CC
PLOTX           = $CD
PLOTY           = $CE
LOHLD           = $CF
HIHLD           = $D0
vStarMoveTimer  = $D1
vMoveTimer      = $D2
TIMER           = $D3
isDead          = $D4
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

                * = $F0
SOURCE          .dword ?                ; Starting address for the source data (4 bytes)
DEST            .dword ?                ; Starting address for the destination block (4 bytes)
SIZE            .dword ?                ; Number of bytes to copy (4 bytes)
