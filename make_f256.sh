
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


64tass  --m65c02 \
        --flat \
        --nostart \
        -D PGX=0 \
        -o obj/fillerup.bin \
        --list=obj/fillerupB.lst \
        --labels=obj/fillerupB.lbl \
        fill-er-up.asm
