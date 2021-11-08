#!user/bin/bash
rm sam bam
mkdir sam bam
#Es preciso crear un índice para poder utlizar BWA
bwa index ./contigs_meta/*.contigs.fa
#Se ejetuan BWA de modo que obtengamos el coverage de cada
#contig
for f1 in ./prueba_pe/*_1.fastq
do
  f2=${f1/%_1.fastq/_2.fastq}
  f3=./contigs_meta/`basename $f1 _1.fastq`.contigs.fa
  bwa mem -M -Y -t 8 $f3 $f1 $f2 > ./sam/`basename $f3 .contigs.fa`.sam
  echo $f1 $f2 $f3
done
#Es imprescindible ordenar los archivos .bam por nombre de
#read, de modo que puedan ser utlizados por featurecounts
for f4 in ./sam/*.sam
do
  samtools sort -@ 8 -o ./bam/`basename $f4 .sam`.sort.bam $f4
  echo $f4
done
