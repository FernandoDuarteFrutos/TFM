#!/usr/bin/bash
rm -r contigs_meta
mkdir contigs_meta
cd contigs_meta
for f1 in ../trimmomatic_pe/*_1.trimmed.fastq
do
    f2=${f1/%_1.trimmed.fastq/_2.trimmed.fastq}
    megahit -1 $f1 -2 $f2 -o ./`basename $f1 _1.trimmed.fastq`/ --out-prefix `basename $f1 _1.trimmed.fastq` --num-cpu-threads 10 -m 12000000000
    echo $f1 $f2
done
