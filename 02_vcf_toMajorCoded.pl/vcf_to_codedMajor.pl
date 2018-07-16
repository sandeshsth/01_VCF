#!/usr/bin/perl
use warnings;
use strict;
use v5.16;

my $vcf = "error2.vcf";
my $info_file = "filtered_MAF0_Miss-lte100_Het-lte100-error2.vcf.txt";

open IN1, $vcf or die "Cannot find file";
open IN2, $info_file or die "Cannot find file";

open OUT, ">$vcf.coded.txt";

my $no_columns;
my ($major, $minor); 

while (my $line_vcf = <IN1>, my $line_info = <IN2>) {
	if ( $line_vcf =~ /^#CHROM/) {
			chomp $line_vcf;
			my @header = split( "\t", $line_vcf );

			# number of columns
			$no_columns = scalar @header;

			## Making header with chr pos and samples
			$header[0] =~ s/#//;               # remove#
			my $top = "$header[0]\t$header[1]\t$header[3]\t$header[4]\t";

			for ( my $j = 9 ; $j < $no_columns ; $j++ ) {
				$top = $top . $header[$j] . "\t";
			}
			#say $line_info;
			say OUT $top;
	}
	else {
		#say $line_info;
		#exit;

# VCF file SNP lines:
		chomp $line_vcf;
		# split all columns of a line
		my @columns = split( "\t", $line_vcf );
		# Chr and Pos
		my $GENO = "$columns[0]\t$columns[1]\t$columns[3]\t$columns[4]\t";
		
# Info file SNP lines:
       chomp $line_info;
       my @info_elements = split("\t", $line_info); 
            
# check same chr and pos:
       if($columns[0] eq $info_elements[0] and $columns[1] eq $info_elements[1] and $columns[3] eq $info_elements[2] and $columns[4] eq $info_elements[3]){
       		if ($info_elements[10] >= $info_elements[11]){
       			$major = $columns[3];
       			$minor = $columns[4];
       		}
       		elsif($info_elements[10] < $info_elements[11]){
       			$major = $columns[4];
       			$minor = $columns[3];
       		}
       }

# accessing all samples: splitting each sample from coming single line to get genotype, DP and AD
# 9th index is sample one
		my $call;
		for ( my $i = 9 ; $i < $no_columns ; $i++ ) {

			# checking genotype
			my $genotype = substr( $columns[$i], 0, 3 );

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
				if ( $genotype eq "0/0" or $genotype eq "0|0" ) {
					if ($major eq $columns[3]){
						$call = "1";
					}
					elsif($minor eq $columns[3]){
						$call = "-1";
					}
					
				}

				# Het
				elsif ($genotype eq "0/1"
					or $genotype eq "1/0"
					or $genotype eq "0|1"
					or $genotype eq "1|0" )
				{
					$call = "0";
				}

				# Hom Alt
				elsif ( $genotype eq "1/1" or $genotype eq "1|1" ) {
					if ($major eq $columns[4]){
						$call = "1";
					}
					elsif($minor eq $columns[4]){
						$call = "-1";
					}
				}
			}

			# No genotype call in the VCF file
			else {
				$call = "NA";
			}

			$GENO = $GENO . $call . "\t";
		}
		say OUT $GENO;
	}
}
exit;
