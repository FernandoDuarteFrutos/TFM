#!/usr/bin/bash
rm -r diamond
mkdir -p diamond/card
#Se crea la base de datos a paritr de los datos descargados
diamond makedb --in ./card-data/protein_fasta_protein_homolog_model.fasta -d ./diamond/card/card-homolog
#Se ejecuta diamond a partir de la base de datos y se anotan los ARGs
#que se encuentran en el catálogo de genes
for f in ./cd-hit/*.ID.prot.fa
do
  diamond blastp -d ./diamond/card/card-homolog.dmnd -q $f -o ./diamond/`basename $f .ID.prot.fa`.fa.dm -p 8 -e 1e-5 --id 70
  cd diamond
  gawk -F '[\t|]' 'OFS = "\t" {print $1,$4}' `basename $f .ID.prot.fa`.fa.dm > `basename $f .ID.prot.fa`.ARO.fa.dm
  cd ..
done
