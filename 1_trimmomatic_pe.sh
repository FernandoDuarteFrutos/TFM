### Se ejecuta trimmomatic para cada uno de los reads de la carpeta, considerando
### considerando que son paired-end reads
#!/usr/bin/bash
for f1 in ./Secuencias/*_1.fastq
do ### Cuidado con la extensión (gz o fastq)
  f2=${f1/%_1.fastq/_2.fastq}
  trimmomatic PE -threads 8 $f1 $f2 \
                            ./trimmomatic_pe/`basename $f1 .fastq`.trimmed.fastq ./trimmomatic_pe/`basename $f1 .fastq`.trimmed_un.fastq \
                            ./trimmomatic_pe/`basename $f2 .fastq`.trimmed.fastq ./trimmomatic_pe/`basename $f2 .fastq`.trimmed_un.fastq \
              MINLEN:50 AVGQUAL:20
  echo $f1 $f2
done
### Fastqc de nuevo
fastqc ./trimmomatic_pe/*.fastq -o ./fastqc_trimmed/
