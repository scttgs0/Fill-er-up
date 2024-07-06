
mkdir -p obj/

# -------------------------------------

64tass  --m65c02 \
        --flat \
        --nostart \
        -o obj/fillerup.pgx \
        --list=obj/fillerup.lst \
        --labels=obj/fillerup.lbl \
        fill-er-up.asm
