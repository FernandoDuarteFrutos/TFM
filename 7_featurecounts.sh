#!user/bin/bash
rm -r abundance
mkdir abundance
#Featurecounts permite el contaje de reads alineados a contigs
#teniendo en cuenta los genes asociados, utlizando para ello un archivo .gff
for f1 in ./annotations/*.gff
do
  featureCounts -T 8 -p -a $f1 -t CDS -g ID -o ./abundance/`basename $f1 .gff`.counts ./bam/`basename $f1 .gff`.sort.bam
  cd abundance
  cut -f1,7,8,9,10,11,12 `basename $f1 .gff`.counts > `basename $f1 .gff`.cut.counts
  cd ..
done
#sed -i 'id'
