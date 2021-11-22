#!/usr/bin/bash
rm annotations
mkdir annotations
for f in ./contigs_meta/*/*.fa
do
  prodigal -a ./annotations/`basename $f .contigs.fa`.aa.fa \
           -d ./annotations/`basename $f .contigs.fa`.nuc.fa \
           -i $f -f gff -p meta > ./annotations/`basename $f .contigs.fa`.gff
  echo $f
done
