#!/usr/bin/bash
rm -r cd-hit
mkdir cd-hit
#Se crea el catálogo de genes no redundantes
for f1 in ./annotations/*.aa.fa
do
  cd-hit -i $f1 -o ./cd-hit/`basename $f1 .aa.fa`.prot.fa -c 0.95 -aL 0.9
  echo $f1
done
#De la descripción de las secuencias, se extraen únicamente los IDs para posteriormente
#poder asociarlos a la abundancia
cd cd-hit
for f2 in ../cd-hit/*.prot.fa
do
  gawk -F'[#;=]' '/^>/ {print ">" $6; next}{print}' $f2 > `basename $f2 .prot.fa`.ID.prot.fa
  echo $f
done
cd ..
