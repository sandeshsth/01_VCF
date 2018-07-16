#!/usr/bin/perl
use warnings;
use strict;
use v5.16;

my $filename = "HapMap.vcf";

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

		# If genotype has . then skip
		if ($columns[3] eq "." or $columns[4] eq "."){
			next;
		}


		my $call;
		
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

			}

			# No genotype call in the VCF file
			else {
				$null_count++;
			}
			
		}

		 
		 # for fisher
		 my $total_check = $ref_count+$alt_count+$het_count+$null_count;
		 print OUT4 "$columns[2]\t$columns[1]\t$columns[3]\t$columns[4]\t$het_count\t$ref_count\t$alt_count\t$null_count\t$total_check\n";
	}
	
}

say "Job Done, Please check txt file.";
exit;

