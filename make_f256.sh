
mkdir -p obj/

# -------------------------------------

64tass  --m65c02 \
        --flat \
        --nostart \
        -D PGX=1 \
        -o obj/fillerup.pgx \
        --list=obj/fillerup.lst \
        --labels=obj/fillerup.lbl \
        fill-er-up.asm


# 64tass  --m65816 \
#         --c256-pgz \
#         --output-exec=BOOT \
#         --long-address \
#         -D PGX=0 \
#         -o obj/fillerup.pgz \
#         --list=obj/fillerup.lst \
#         --labels=obj/fillerup.lbl \
#         fill-er-up.asm
