
IDX_PLYR        = 0
IDX_STAR        = 1

;--------------------------------------
;--------------------------------------
                .align $100,$00
;--------------------------------------

SPR_PLAYER      .byte $00,$00,$09,$09,$00,$00,$00,$00, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$09,$09,$00,$00,$00,$00, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $09,$09,$00,$00,$09,$09,$00,$00, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $09,$09,$00,$00,$09,$09,$00,$00, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$09,$09,$00,$00,$00,$00, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$09,$09,$00,$00,$00,$00, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00, $00,$00,$00,$00,$00,$00,$00,$00

                .byte $00,$00,$00,$00,$00,$00,$00,$00, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00, $00,$00,$00,$00,$00,$00,$00,$00


SPR_STAR0       .byte $0A,$0A,$00,$00,$00,$00,$00,$00, $00,$00,$00,$00,$00,$00,$0A,$0A
                .byte $0A,$0A,$00,$00,$00,$00,$00,$00, $00,$00,$00,$00,$00,$00,$0A,$0A
                .byte $00,$00,$0A,$0A,$00,$00,$00,$00, $00,$00,$00,$00,$0A,$0A,$00,$00
                .byte $00,$00,$0A,$0A,$00,$00,$00,$00, $00,$00,$00,$00,$0A,$0A,$00,$00
                .byte $00,$00,$00,$00,$0A,$0A,$00,$00, $00,$00,$0A,$0A,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$0A,$0A,$00,$00, $00,$00,$0A,$0A,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $0A,$0A,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $0A,$0A,$00,$00,$00,$00,$00,$00

                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $0A,$0A,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $0A,$0A,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$0A,$0A,$00,$00, $00,$00,$0A,$0A,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$0A,$0A,$00,$00, $00,$00,$0A,$0A,$00,$00,$00,$00
                .byte $00,$00,$0A,$0A,$00,$00,$00,$00, $00,$00,$00,$00,$0A,$0A,$00,$00
                .byte $00,$00,$0A,$0A,$00,$00,$00,$00, $00,$00,$00,$00,$0A,$0A,$00,$00
                .byte $0A,$0A,$00,$00,$00,$00,$00,$00, $00,$00,$00,$00,$00,$00,$0A,$0A
                .byte $0A,$0A,$00,$00,$00,$00,$00,$00, $00,$00,$00,$00,$00,$00,$0A,$0A


SPR_STAR1       .byte $00,$00,$0A,$0A,$00,$00,$00,$00, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$0A,$0A,$00,$00,$00,$00, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$0A,$0A,$00,$00,$00,$00, $00,$00,$00,$00,$0A,$0A,$0A,$0A
                .byte $00,$00,$0A,$0A,$00,$00,$00,$00, $00,$00,$00,$00,$0A,$0A,$0A,$0A
                .byte $00,$00,$00,$00,$0A,$0A,$00,$00, $00,$00,$0A,$0A,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$0A,$0A,$00,$00, $00,$00,$0A,$0A,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $0A,$0A,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $0A,$0A,$00,$00,$00,$00,$00,$00

                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $0A,$0A,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $0A,$0A,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$0A,$0A,$00,$00, $00,$00,$0A,$0A,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$0A,$0A,$00,$00, $00,$00,$0A,$0A,$00,$00,$00,$00
                .byte $0A,$0A,$0A,$0A,$00,$00,$00,$00, $00,$00,$00,$00,$0A,$0A,$00,$00
                .byte $0A,$0A,$0A,$0A,$00,$00,$00,$00, $00,$00,$00,$00,$0A,$0A,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00, $00,$00,$00,$00,$0A,$0A,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00, $00,$00,$00,$00,$0A,$0A,$00,$00


SPR_STAR2       .byte $00,$00,$00,$00,$0A,$0A,$00,$00, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$0A,$0A,$00,$00, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$0A,$0A,$00,$00, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$0A,$0A,$00,$00, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $00,$00,$00,$00,$0A,$0A,$0A,$0A
                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $00,$00,$00,$00,$0A,$0A,$0A,$0A
                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $0A,$0A,$0A,$0A,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $0A,$0A,$0A,$0A,$00,$00,$00,$00

                .byte $00,$00,$00,$00,$0A,$0A,$0A,$0A, $0A,$0A,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$0A,$0A,$0A,$0A, $0A,$0A,$00,$00,$00,$00,$00,$00
                .byte $0A,$0A,$0A,$0A,$00,$00,$00,$00, $0A,$0A,$00,$00,$00,$00,$00,$00
                .byte $0A,$0A,$0A,$0A,$00,$00,$00,$00, $0A,$0A,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00, $00,$00,$0A,$0A,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00, $00,$00,$0A,$0A,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00, $00,$00,$0A,$0A,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00, $00,$00,$0A,$0A,$00,$00,$00,$00


SPR_STAR3       .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A

                .byte $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A, $0A,$0A,$00,$00,$00,$00,$00,$00
                .byte $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A, $0A,$0A,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00, $0A,$0A,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00, $0A,$0A,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00, $0A,$0A,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00, $0A,$0A,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00, $0A,$0A,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00, $0A,$0A,$00,$00,$00,$00,$00,$00


SPR_STAR4       .byte $00,$00,$00,$00,$00,$00,$00,$00, $0A,$0A,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00, $0A,$0A,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00, $0A,$0A,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00, $0A,$0A,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00, $0A,$0A,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00, $0A,$0A,$00,$00,$00,$00,$00,$00
                .byte $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A, $0A,$0A,$00,$00,$00,$00,$00,$00
                .byte $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A, $0A,$0A,$00,$00,$00,$00,$00,$00

                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $00,$00,$00,$00,$00,$00,$00,$00


SPR_STAR5       .byte $00,$00,$00,$00,$00,$00,$00,$00, $00,$00,$0A,$0A,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00, $00,$00,$0A,$0A,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00, $00,$00,$0A,$0A,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00, $00,$00,$0A,$0A,$00,$00,$00,$00
                .byte $0A,$0A,$0A,$0A,$00,$00,$00,$00, $0A,$0A,$00,$00,$00,$00,$00,$00
                .byte $0A,$0A,$0A,$0A,$00,$00,$00,$00, $0A,$0A,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$0A,$0A,$0A,$0A, $0A,$0A,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$0A,$0A,$0A,$0A, $0A,$0A,$00,$00,$00,$00,$00,$00

                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $0A,$0A,$0A,$0A,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $0A,$0A,$0A,$0A,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $00,$00,$00,$00,$0A,$0A,$0A,$0A
                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $00,$00,$00,$00,$0A,$0A,$0A,$0A
                .byte $00,$00,$00,$00,$0A,$0A,$00,$00, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$0A,$0A,$00,$00, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$0A,$0A,$00,$00, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$0A,$0A,$00,$00, $00,$00,$00,$00,$00,$00,$00,$00


SPR_STAR6       .byte $00,$00,$00,$00,$00,$00,$00,$00, $00,$00,$00,$00,$0A,$0A,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$00,$00, $00,$00,$00,$00,$0A,$0A,$00,$00
                .byte $0A,$0A,$0A,$0A,$00,$00,$00,$00, $00,$00,$00,$00,$0A,$0A,$00,$00
                .byte $0A,$0A,$0A,$0A,$00,$00,$00,$00, $00,$00,$00,$00,$0A,$0A,$00,$00
                .byte $00,$00,$00,$00,$0A,$0A,$00,$00, $00,$00,$0A,$0A,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$0A,$0A,$00,$00, $00,$00,$0A,$0A,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $0A,$0A,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $0A,$0A,$00,$00,$00,$00,$00,$00

                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $0A,$0A,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$00,$00,$0A,$0A, $0A,$0A,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$0A,$0A,$00,$00, $00,$00,$0A,$0A,$00,$00,$00,$00
                .byte $00,$00,$00,$00,$0A,$0A,$00,$00, $00,$00,$0A,$0A,$00,$00,$00,$00
                .byte $00,$00,$0A,$0A,$00,$00,$00,$00, $00,$00,$00,$00,$0A,$0A,$0A,$0A
                .byte $00,$00,$0A,$0A,$00,$00,$00,$00, $00,$00,$00,$00,$0A,$0A,$0A,$0A
                .byte $00,$00,$0A,$0A,$00,$00,$00,$00, $00,$00,$00,$00,$00,$00,$00,$00
                .byte $00,$00,$0A,$0A,$00,$00,$00,$00, $00,$00,$00,$00,$00,$00,$00,$00
