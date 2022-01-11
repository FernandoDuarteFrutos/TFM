#!user/bin/bash
rm -r archivos_preprocesados
mkdir archivos_preprocesados
cd archivos_preprocesados
for f1 in ../diamond/*.ARO.fa.dm
do
  join -1 2 -2 1 -t $'\t' <(sort -k2 ../abundance/`basename $f1 .ARO.fa.dm`.counts.norm) <(sort $f1) > `basename $f1 .ARO.fa.dm`.pre.txt
  join -1 6 -2 1 -t $'\t' <(sort -k6 `basename $f1 .ARO.fa.dm`.pre.txt) <(sort ../card-data/aro_index.tsv) > `basename $f1 .ARO.fa.dm`.final.txt
done
cat *.final.txt > resistomas.pre
awk -F"\t" '{print $3,$1,$2,$4,$5,$6,$7,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16}' OFS='\t' resistomas.pre > resistomas
sed -i '1i\Sample\tARO Accession\tGeneID\tORF length\tCounts\tRelative abundance\tCVTERM ID\tModel Sequence ID\tModel ID\tModel Name\tARO Name\tProtein Accession\tDNA Accession\tAMR Gene Family\tDrug Class\tResistance Mechanism' resistomas
