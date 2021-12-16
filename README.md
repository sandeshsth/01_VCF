# Scripts to parse VCF file

## Usage:

### Filter VCF file based on MAF, Missing and Het:
`vcf_MAF_Missing_Het_filter.pl file.vcf MAF missing% het%`

1. VCF file
2. MAF of 0.05 means: SNPs with at least one allele having MAF of 0.05 are kept
3. missing 90 means: SNPs with <=90% missing are kept (SNPs with >90% missing are removed)
4. Het 10 means: SNPs with <=10% het are kept (SNPs with >10% het are removed)

No filtering:
vcf_MAF_Missing_Het_filter.pl file.vcf MAF(0 no filter) missing(100 no filter) het(100 no filter)


### Filter VCF file based on total read depth and individual allele depth
`vcf_INFO_AD_filter.sh file.vcf AD_positionIn_INFO >=total_filteredDP <=total_filteredDP Both_Allele_should_be_at_least`

1. AD position in INFO
2. DP is raw read depth.
3. AD is filtered read depth presence as REF,ALT. Filtered total depth is REF+ALT of AD.

`vcf_INFO_AD_filter.sh file.vcf 2 10 20 3` means:

Total filtered depth is >=10 and <=20

REF and ALT both should have the depth of at least 3.


### Count genotypes in VCF:
`vcf_genotype_count.pl`

### Filter VCF based on sample DP:
`vcf_FORMAT_sampleDP_filter_Aug2019.pl file.vcf total_samples_in_vcf_file min_depth_at_each_datapoint`
`vcf_FORMAT_sampleDP_filter_Aug2019.pl file.vcf 17 10`

It works if FORMAT is: GT:PL:DP:SP:GQ	./.:0,0,0,0,0,0,0,0,0,0:0:0:5

If there is some value in DP.

This won't work GT:AD:DP:GQ:PL ./. Error: Use of uninitialized value in numeric ge.

Can filter for no missing and run
