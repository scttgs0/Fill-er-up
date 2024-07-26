
frsMouse_off    .macro
                php

                .setbank $AF
                stz MOUSE_PTR_CTRL

                .setbank $00
                plp
                .endmacro

frsMouse_on     .macro
                pha

                lda #1
                sta MOUSE_PTR_CTRL

                pla
                .endmacro
