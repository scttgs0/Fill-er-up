;--------------------------------------
; Zero-page Equates
;--------------------------------------

;--------------------------------------
;--------------------------------------
                * = $80
;--------------------------------------

LO                  .byte ?
HI                  .byte ?
PLOTX               .byte ?
PLOTY               .byte ?
LOHLD               .byte ?
HIHLD               .byte ?
vStarMoveTimer      .byte ?
vMoveTimer          .byte ?
TIMER               .byte ?
isDead              .byte ?
PX                  .byte ?
PY                  .byte ?
XI                  .byte ?
YI                  .byte ?

isGameOver          .byte ?

zpPlayerColorIdx    .byte ?
zpPlayerColorClock  .byte ?

isDirtyPlayfield    .byte ?
JIFFYCLOCK          .byte ?
InputFlags          .byte ?
InputType           .byte ?
itJoystick      = 0
itKeyboard      = 1
KEYCHAR             .byte ?             ; last key pressed
CONSOL              .byte ?             ; state of OPTION,SELECT,START

zpSource            .dword ?            ; Starting address for the source data (4 bytes)
zpDest              .dword ?            ; Starting address for the destination block (4 bytes)
zpSize              .dword ?            ; Number of bytes to copy (4 bytes)

zpTemp1             .byte ?
zpTemp2             .byte ?

zpIndex1            .word ?
zpIndex2            .word ?
zpIndex3            .word ?

RND_MIN             .byte ?
RND_SEC             .byte ?
RND_RESULT          .word ?
