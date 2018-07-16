#!/usr/bin/perl
use warnings;
use strict;
use v5.16;

my $filename = "gbs-bowtie-vs5.sam-all.vcf";

open IN, $filename or die "Cannot find file";

# for fisher
open OUT4, ">Count_Geno-$filename.txt";

my @count_2;
my $no_columns;
my @each_depth;
while (<IN>) {

	my $line = $_;

	# skip vcf header and keep heading with sample info
	if ( $_ =~ /^#/ ) {

		# put header in txt output
		if ( $_ =~ /^#CHROM/ ) {
			chomp $_;
			my $header_mod;
			my $header_mod1;
			my @header = split( "\t", $_ );

			# number of columns
			$no_columns = scalar @header;
			for ( my $m = 9 ; $m < $no_columns ; $m++ ) {

				# Samples header

				# genotype and coverage only
				$header_mod .= "$header[$m]\t";

				# allele depth
				$header_mod1 .= "$header[$m]_ref\t$header[$m]_alt\t";
			}
			
			#for fisher
			print OUT4 "CHROM\tPOS\tREF\tALT\thet_count\tref_count\talt_count\tnull_count\ttotal_check\n";
		}
	}

	# finding DP and AD
	else {

		#print $_;
		chomp $_;

		# split all columns of a line
		my @columns = split( "\t", $_ );

		# say $columns[13];
		# say scalar@columns;
		# access format column to find DP and AD
		my @format_column = split( ":", $columns[8] );
		
		
		# If genotype has . then skip
		if ($columns[3] eq "." or $columns[4] eq "."){
			next;
		}

		#say $format_column[2];

		# finding DP position:
		my $dp_position;
		my $allele_depth;

		# find (total depth in a sample) DP and AD positions
		for ( my $j = 0 ; $j < @format_column ; $j++ ) {
			if ( $format_column[$j] eq "DP" ) {

				#say $j;
				$dp_position = $j;

				#push @count_2, $j;
			}
			if ( $format_column[$j] eq "AD" ) {

				#say $j;
				$allele_depth = $j;

				#push @count_2, $j;
			}
		}

		#say $dp_position;
		#say $allele_depth;
		

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
			my @each_column = split( ":", $columns[$i] );

# split AD inside sample (using allele depth because earlier found the position of AD and DP from format)
			if (   $each_column[0] eq "0/0"
				or $each_column[0] eq "0/1"
				or $each_column[0] eq "1/0"
				or $each_column[0] eq "1/1" )
			{
				# Make the call
				# Hom ref
				if ( $each_column[0] eq "0/0" ) {
					$call = "$columns[3]$columns[3]";
					$ref_count++;
				}

				# Het
				elsif ( $each_column[0] eq "0/1" or $each_column[0] eq "1/0") {
					$call = "$columns[3]$columns[4]";
					$het_count++;
				}

				# Hom Alt
				elsif ( $each_column[0] eq "1/1" ) {
					$call = "$columns[4]$columns[4]";
					$alt_count++;
				}

				# Get AD and DP
				my @alleles = split( ",", $each_column[$allele_depth] );

				#say $each_column[2];
				#say "$alleles[0]\t$alleles[1]\t$each_column[$dp_position]\t";
				$ref_allele = $alleles[0];
				$alt_allele = $alleles[1];

				# total depth in a sample
				my $AD = $each_column[$dp_position];

				############# Make string from numerical, non-numerical and zero
			 # make string of ref and alt frequency for all samples to use later
			 # say print "$ref_fre\t$alt_fre\t";
			 # $to_split .= "$ref_fre\t$alt_fre\t";

			  # made string to print later with genotype call and all other info

				# for genotype:
				$call_genotype_only .= "$call\t";

				# for allele only
				#if (not defined $alt_allele){print 
					#$alt_allele
					#exit;
				#}
				$for_only_allele .= "$ref_allele\t$alt_allele\t";

				# for cov only
				$cov_only .= "$AD\t";
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

		 
		 # for fisher
		 my $total_check = $ref_count+$alt_count+$het_count+$null_count;
		 print OUT4 "$columns[0]\t$columns[1]\t$columns[3]\t$columns[4]\t$het_count\t$ref_count\t$alt_count\t$null_count\t$total_check\n";
	}
	
}

say "Job Done, Please check txt file.";
exit;

