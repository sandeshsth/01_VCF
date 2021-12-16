# 01_VCF
Scripts to handle VCF files



USAGE:

`vcf_MAF_Missing_Het_filter.pl file.vcf MAF missing% het%`

1. VCF file
2. MAF of 0.05 means: SNPs with at least one allele having MAF of 0.05 are kept
3. missing 90 means: SNPs with <=90% missing are kept (SNPs with >90% missing are removed)
4. Het 10 means: SNPs with <=10% het are kept (SNPs with >10% het are removed)

No filtering:
vcf_MAF_Missing_Het_filter.pl file.vcf MAF(0 no filter) missing(100 no filter) het(100 no filter)


`vcf_INFO_AD_filter.sh file.vcf AD_positionIn_INFO >=total_filteredDP <=total_filteredDP Both_Allele_should_be_at_least`

AD position in INFO
DP is raw read depth.
AD is filtered read depth presence as REF,ALT. Filtered total depth is REF+ALT of AD.

`vcf_INFO_AD_filter.sh file.vcf 2 10 20 3` means:
Total filtered depth is >=10 and <=20
REF and ALT both should have the depth of at least 3.
