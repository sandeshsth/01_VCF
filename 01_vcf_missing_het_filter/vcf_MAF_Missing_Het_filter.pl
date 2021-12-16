#!/usr/bin/perl
use warnings;
use strict;
use v5.16;
​
########################################## 
# Sandesh Shrestha (sshrest1@ksu.edu)    #
# Please verify the output before using. #
##########################################
​
unless(defined $ARGV[0] and defined $ARGV[1] and defined $ARGV[2] and defined $ARGV[3]){
    say "USAGE:\n/homes/sshrest1/scripts/vcf/vcf_MAF_Missing_Het_filter.pl file.vcf MAF missing% het%";
    say "\n1. VCF file";
    say "2. MAF of 0.05 means: SNPs with at least one allele having MAF of 0.05 are kept";
    say "3. missing 90 means: SNPs with <=90% missing are kept (SNPs with >90% missing are removed)";
    say "4. Het 10 means: SNPs with <=10% het are kept (SNPs with >10% het are removed)";
    say "\nNo filtering:\n /homes/sshrest1/scripts/vcf/vcf_MAF_Missing_Het_filter.pl file.vcf MAF(0 no filter) missing(100 no filter) het(100 no filter)";
​
    exit;
}
​
# vcf_MAF_Missing_Het_filter.pl file.vcf MAF(0 no filter) missing(100 no filter) het(100 no filter)
​
my $filename = $ARGV[0];
# at least one allele has MAF of 0.1 , No filter = 0;
my $MAF = $ARGV[1];  # 0.1;
# if missing <= 30%, No filter = 100
my $missing_per = $ARGV[2]; #30;
# If het <= 5% keep; No filter = 100
my $het_percent = $ARGV[3]; #5;
​
open IN, $filename or die "Cannot find file";
​
open OUT4, ">F_MAF$MAF\_Miss$missing_per\_Het$het_percent-$filename.txt";
open OUT5, ">F_MAF$MAF\_Miss$missing_per\_Het$het_percent-$filename";
​
print OUT4 "CHROM\tPOS\tREF\tALT\thet_count\tref_count\talt_count\tNA_count\ttotal_sample_check\tmissing_%\tallele1_ref\tallele2_alt\tHet_%\tMAF\n";
​
my @count_2;
my $no_columns;
my @each_depth;
my $filterd_snps = 0;
my $total_snps_vcf = 0;
while (<IN>) {
​
	my $line = $_;
	
	# skip vcf header and keep heading with sample info
	if ( $_ =~ /^#/ ) {
	      # keep header	
               print OUT5 $_;
		
		if ( $_ =~ /^#CHROM/ ) {
		#	print OUT5 $_;
                        chomp $_;
			my @header = split( "\t", $_ );
			# number of columns
			$no_columns = scalar @header;
	}
}
	else {
		$total_snps_vcf++;
		#print $_;
		chomp $_;
​
		# split all columns of a line
		my @columns = split( "\t", $_ );
​
		# If genotype has . then skip
		if ($columns[3] eq "." or $columns[4] eq "."){
			next;
		}
		
                #If genotype has single "N" then skip
                if ($columns[3] eq "N" or $columns[4] eq "N"){
                	next;
                	}
                 
		# If more than one allele
		if (length$columns[3] > 1 or length$columns[4] > 1){
			#say $_;
			next;
		}
​
	
		my $call;
		
		
		my $ref_count = 0;
		my $alt_count = 0;
		my $het_count = 0;
		my $null_count = 0;
​
# accessing all samples: splitting each sample from coming single line to get genotype, DP and AD
# 9th index is sample one
​
		for ( my $i = 9 ; $i < $no_columns ; $i++ ) {
​
			# checking genotype
			my $genotype = substr($columns[$i],0,3);
​
# split AD inside sample (using allele depth because earlier found the position of AD and DP from format)
			if (   $genotype eq "0/0"
				or $genotype eq "0/1"
				or $genotype eq "1/0"
				or $genotype eq "1/1"
				or $genotype eq "0|0"
				or $genotype eq "0|1"
				or $genotype eq "1|0"
				or $genotype eq "1|1" )
			{
				# Make the call
				# Hom ref
				if ( $genotype eq "0/0" or $genotype eq "0|0") {
					$call = "$columns[3]$columns[3]";
					$ref_count++;
				}
​
				# Het
				elsif ( $genotype eq "0/1" or $genotype eq "1/0" or $genotype eq "0|1" or $genotype eq "1|0") {
					$call = "$columns[3]$columns[4]";
					$het_count++;
				}
​
				# Hom Alt
				elsif ( $genotype eq "1/1" or $genotype eq "1|1") {
					$call = "$columns[4]$columns[4]";
					$alt_count++;
				}
			}
​
			# No genotype call in the VCF file
			else {
				$null_count++;
			}
			
		}
		 my $total_check = $ref_count+$alt_count+$het_count+$null_count;
		 
		 # remove monomorphic SNPs
		 #my $only_ref = $ref_count+$null_count;
		 #my $only_alt = $alt_count+$null_count;
		 #my $only_het = $het_count+$null_count;
		 #if($only_ref == $total_check or $only_alt == $total_check or $only_het == $total_check){
		 #	next;
		 #}
​
		 # for MAF
		 my $sample_wo_missing = $ref_count+$alt_count+$het_count;
		 my $total_allele = 2*$sample_wo_missing;
		 
 		 #say $total_allele;
 		 #SNP without any genotype
 		 if ($total_allele == 0){
 		 	next;
 		 }
​
		 my $allele_1 = (2*$ref_count + $het_count)/ $total_allele;
		 my $allele_2 = (2*$alt_count + $het_count)/ $total_allele;
		 
		 my $allele_1_rounded = sprintf("%.3f", $allele_1);
		 my $allele_2_rounded = sprintf("%.3f", $allele_2);
		 
   		 #cal maf
                 my $cal_maf;
		 if ($allele_1_rounded <= $allele_2_rounded){
		 	$cal_maf = $allele_1_rounded;
		 }
		 else{
		 	$cal_maf = $allele_2_rounded;
		 }
                 
                 
		 #say $total_allele;
		 #say $allele_1_rounded;
		 #say $allele_2_rounded;
		 
		 # for missing
		 my $missing = sprintf ("%.2f", ($null_count/$total_check *100));
		 #say $missing;
		 
		 # for HET
		 my $het = sprintf ("%.2f", ($het_count/$sample_wo_missing *100));
		 #say $het;
		 
		 if ($allele_1 >= $MAF and $allele_2 >= $MAF and $missing <= $missing_per and $het <= $het_percent){
		 	print OUT5 $_, "\n";
		 	$filterd_snps++;
		 }
		 print OUT4 "$columns[0]\t$columns[1]\t$columns[3]\t$columns[4]\t$het_count\t$ref_count\t$alt_count\t$null_count\t$total_check\t$missing%\t$allele_1_rounded\t$allele_2_rounded\t$het%\t$cal_maf\n";
	}
}
​
open OUT2, ">snps-F_MAF$MAF\_Miss$missing_per\_Het$het_percent-$filename.txt";
say OUT2 "Total bi-allelic SNPs in $filename is $total_snps_vcf";
say OUT2 "Total SNPs after filtering (MAF >= $MAF kept; Missing > $missing_per % removed; Het > $het_percent % removed): $filterd_snps";
exit;
