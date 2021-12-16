#!/bin/bash

if [ $# -ne 3 ]
then
    echo -e "USAGE:\n$0 file.vcf 2 2\n"

    echo -e "This script will filter a VCF file:\nwith at least sample has REF allele\nAND\nwith at least sample has ALT allele\n"
    echo -e "1) vcf file\n2) 2 means: at least 2 samples have REF allele\n3) 2 means: at least 2 samples have ALT allele"
    exit 0
fi

head -1000 $1 | grep '^#' > R${2}A${3}.Samples.$1
grep -v "^#" $1 | awk -v R="$2" -v A="$3" '{countR=gsub(/0\/0/, "0/0"); countA=gsub(/1\/1/, "1/1"); if (countR >= R && countA >= A){print}}' >> R${2}A${3}.Samples.$1

