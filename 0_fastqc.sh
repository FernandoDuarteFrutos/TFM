#!/bin/bash
rm -r fastqc
mkdir fastqc
fastqc ./Secuencias/*.fastq -o ./fastqc
