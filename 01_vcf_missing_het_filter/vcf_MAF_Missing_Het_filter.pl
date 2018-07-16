#!/usr/bin/perl
use warnings;
use strict;
use v5.16;

my $filename = "blk-removed_am_cimmyt-tags.fastq.Fisher.vcf";
# at least one allele has MAF of >=0.1
my $MAF = 0.1;
# if missing <= 30%, keep
my $missing_per = 30;
# If <=5% het, keep
my $het_percent = 10;

open IN, $filename or die "Cannot find file";

# for fisher
open OUT4, ">F_MAF_Miss_Het-$filename.txt";
open OUT5, ">F_MAF_Miss_Het-$filename";
			
#for missing file
print OUT4 "CHROM\tPOS\tREF\tALT\thet_count\tref_count\talt_count\tNA_count\ttotal_sample_check\tmissing_%\tallele1_ref\tallele2_alt\tHet_%\n";

my @count_2;
my $no_columns;
my @each_depth;
my $filterd_snps = 0;
while (<IN>) {

	my $line = $_;
	
	# skip vcf header and keep heading with sample info
	if ( $_ =~ /^#/ ) {
		print OUT5 $_;
		
		if ( $_ =~ /^#CHROM/ ) {
			chomp $_;
			my @header = split( "\t", $_ );
			# number of columns
			$no_columns = scalar @header;
	}
}
	else {

		#print $_;
		chomp $_;

		# split all columns of a line
		my @columns = split( "\t", $_ );

		# If genotype has . then skip
		if ($columns[3] eq "." or $columns[4] eq "."){
			next;
		}
		
		# If more than one allele
		if (length$columns[3] > 1 or length$columns[4] > 1){
			#say $_;
			next;
		}

		my $ref_allele;
		my $alt_allele;
		my $call;
		my $call_genotype_only;
		my $for_only_allele;
		my $cov_only;
		
		# for fisher test
		my $ref_count = 0;
		my $alt_count = 0;
		my $het_count = 0;
		my $null_count = 0;

		#print "$columns[0]\t";

# accessing all samples: splitting each sample from coming single line to get genotype, DP and AD
# 9th index is sample one

		for ( my $i = 9 ; $i < $no_columns ; $i++ ) {

			# checking genotype
			my $genotype = substr($columns[$i],0,3);

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

				# Het
				elsif ( $genotype eq "0/1" or $genotype eq "1/0" or $genotype eq "0|1" or $genotype eq "1|0") {
					$call = "$columns[3]$columns[4]";
					$het_count++;
				}

				# Hom Alt
				elsif ( $genotype eq "1/1" or $genotype eq "1|1") {
					$call = "$columns[4]$columns[4]";
					$alt_count++;
				}
			}

			# No genotype call in the VCF file
			else {
				$call_genotype_only .= "NA\t";
				# for allele only
				$for_only_allele .= "NA\tNA\t";
				$cov_only        .= "NA\t";
				$null_count++;
			}
			
		}
		 # for MAF
		 my $total_check = $ref_count+$alt_count+$het_count+$null_count;
		 my $sample_wo_missing = $ref_count+$alt_count+$het_count;
		 my $total_allele = 2*$sample_wo_missing;
		 my $allele_1 = (2*$ref_count + $het_count)/ $total_allele;
		 my $allele_2 = (2*$alt_count + $het_count)/ $total_allele;
		 
		 my $allele_1_rounded = sprintf("%.3f", $allele_1);
		 my $allele_2_rounded = sprintf("%.3f", $allele_2);
		 
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
		 
		 print OUT4 "$columns[0]\t$columns[1]\t$columns[3]\t$columns[4]\t$het_count\t$ref_count\t$alt_count\t$null_count\t$total_check\t$missing%\t$allele_1_rounded\t$allele_2_rounded\t$het%\n";
	}
}
say "Total SNPs after filtering (MAF= $MAF Missing= $missing_per Het= $het_percent): $filterd_snps";
exit;
