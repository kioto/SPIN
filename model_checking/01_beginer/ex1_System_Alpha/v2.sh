#!/bin/sh

pml_file='systemAlpha.pml'
ltl_file='v2.ltl'
exe_file='v2_systemAlpha'

cat <<EOF > $ltl_file
#define p (sw == on)
#define q (sw == off)

EOF

spin -f "[](p -> <>q)" >> $ltl_file

spin -a -N $ltl_file $pml_file
gcc pan.c -o $exe_file

