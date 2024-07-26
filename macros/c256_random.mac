
randomByte      .macro
                lda GABE_RNG_DAT_LO
                and #$FF
                .endmacro

randomByteY     .macro
                .setbank $AF
                ldy GABE_RNG_DAT_LO
                .setbank $00
                .endmacro

randomWord      .macro
                lda GABE_RNG_DAT_LO
                .endmacro

random          .macro clamp
                ; TODO:
                .endmacro
