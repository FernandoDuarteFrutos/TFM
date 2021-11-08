#!user/bin/bash
rm -r archivos_preprocesados
mkdir archivos_preprocesados
cd archivos_preprocesados
for f1 in ../diamond/*.ARO.fa.dm
do
  join -1 1 -2 1 -t $'\t' <(sort ../abundance/`basename $f1 .ARO.fa.dm`.cut.counts) <(sort $f1) > `basename $f1 .ARO.fa.dm`.join.txt
  join -1 1 -2 3 -t $'\t' <(sort ../card-data/aro_index.tsv) <(sort -k3 `basename $f1 .ARO.fa.dm`.join.txt) > `basename $f1 .ARO.fa.dm`.txt
  sed -i '1i\ARO Accession\tCVTERM ID\tModel Sequence ID\tModel ID\tModel Name\tARO Name\tProtein Accession\tDNA Accession\tAMR Gene Family\tDrug Class\tResistance Mechanism\tGeneID\tCounts' `basename $f1 .ARO.fa.dm`.txt
done
cd ..



#gawk -F '[\t|]' 'OFS = "\t" {print $1,$4}' *6.fa.dm > prueba.fa.dm

#join -1 1 -2 1 -t $'\t' <(sort *.cut.counts) <(sort prueba.fa.dm) > prueba.join.txt
#join -1 1 -2 3 -t $'\t' <(sort aro_index.tsv) <(sort -k3 prueba.join.txt) > xd.txt
#sed -i '1i\ARO Accession\tCVTERM ID\tModel Sequence ID\tModel ID\tModel Name\tARO Name\tProtein Accession\tDNA Accession\tAMR Gene Family\tDrug Class\tResistance Mechanism\tGeneID\tCounts' xd.txt
