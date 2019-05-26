#!/bin/sh

pml_file='systemAlpha.pml'
ltl_file='v1.ltl'
exe_file='v1_systemAlpha'

cat <<EOF > $ltl_file
#define p (sw == off)
#define q (sw == on)

EOF

spin -f "[](p -> <>q)" >> $ltl_file

spin -a -N $ltl_file $pml_file
gcc pan.c -o $exe_file

