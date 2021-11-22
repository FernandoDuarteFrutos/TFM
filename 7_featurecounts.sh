#!user/bin/bash
rm -r abundance
mkdir abundance
cd abundance
#Featurecounts permite el contaje de reads alineados a contigs
#teniendo en cuenta los genes asociados, utlizando para ello un archivo .gff
for f1 in ../annotations/*.gff
do
  featureCounts -T 8 -p -a $f1 -t CDS -g ID -o ./`basename $f1 .gff`.counts ../bam/`basename $f1 .gff`.sort.bam
  cut -f1,6,7 `basename $f1 .gff`.counts > `basename $f1 .gff`.cut.counts
  #Se calcula el número de reads
  f2=$(bioawk -c fastx 'END{print NR}' /mnt/c/users/dfern/tfm/trimmomatic_pe/`basename $f1 .gff`_1.trimmed.fastq)
  #¿Coger una de las dos parejas de pares?f3=$(bioawk -c fastx 'END{print NR}' /mnt/c/users/dfern/tfm/trimmomatic_pe/`basename $f1 .ARO.fa.dm`_2.trimmed.fastq)
  #rsuma=$(($f2 + $f3}))
  #Se calcula la longitud media de los reads
  f4=$(bioawk -c fastx '{s+=length($seq)} END{print s/NR}' /mnt/c/users/dfern/tfm/trimmomatic_pe/`basename $f1 .gff`_1.trimmed.fastq)
  f5=$(bioawk -c fastx '{s+=length($seq)} END{print s/NR}' /mnt/c/users/dfern/tfm/trimmomatic_pe/`basename $f1 .gff`_2.trimmed.fastq)
  f6=$(echo "scale=3; $f4+$f5"|bc)
  lmedia=$(echo "scale=3; $f6/2"|bc)
  #lmedia=$(awk -v 'BEGIN{print ($f4 + $f5)/2}')
  echo $lmedia
  #Se aplica la normalización
  awk -v reads_total="$f2" -v length_reads="$lmedia" -v sample="$(basename $f1 .gff)" \
          'NR>2 {print sample,$0,$3*length_reads/$2/reads_total}' OFS='\t' \
          `basename $f1 .gff`.cut.counts > `basename $f1 .gff`.counts.norm
done
cd ..
#sed -i 'id'
