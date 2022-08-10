randomByte      .macro
                lda GABE_RNG_DAT_LO
                and #$FF
                .endmacro

randomWord      .macro
                lda GABE_RNG_DAT_LO
                .endmacro

random          .macro clamp
                ; TODO:
                .endmacro
