#!/usr/bin/perl
use warnings;
use strict;
use v5.16;

my $filename = "LF-tags.fastq-all.vcf";
my $REF      = 0;
my $HET      = -1;
my $ALT      = 1;
my $MISSING  = "N";

open IN, $filename or die "Cannot find file";
open OUT, ">$filename.txt";

my @count_2;
my $no_columns;
my @each_depth;
my $filterd_snps = 0;
while (<IN>) {

	my $line = $_;

	# skip vcf header and keep heading with sample info
	if ( $_ =~ /^#/ ) {
		if ( $_ =~ /^#CHROM/ ) {
			chomp $_;
			my @header = split( "\t", $_ );

			# number of columns
			$no_columns = scalar @header;

			## Making header with chr pos and samples
			$header[0] =~ s/#//;               # remove#
			my $top = "$header[0]\t$header[1]\t$header[3]\t$header[4]\t";

			for ( my $j = 9 ; $j < $no_columns ; $j++ ) {
				$top = $top . $header[$j] . "\t";
			}
			say OUT $top;

		}
	}
	else {

		#print $_;
		chomp $_;

		# split all columns of a line
		my @columns = split( "\t", $_ );

		# If genotype has . then skip
		if ( $columns[3] eq "." or $columns[4] eq "." ) {
			next;
		}

		# If more than one allele
		if ( length $columns[3] > 1 or length $columns[4] > 1 ) {

			#say $_;
			next;
		}

		# Chr and Pos
		my $GENO = "$columns[0]\t$columns[1]\t$columns[3]\t$columns[4]\t";

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
					$call = "$REF";
				}

				# Het
				elsif ($genotype eq "0/1"
					or $genotype eq "1/0"
					or $genotype eq "0|1"
					or $genotype eq "1|0" )
				{
					$call = "$HET";
				}

				# Hom Alt
				elsif ( $genotype eq "1/1" or $genotype eq "1|1" ) {
					$call = "$ALT";
				}
			}

			# No genotype call in the VCF file
			else {
				$call = "$MISSING";
			}

			$GENO = $GENO . $call . "\t";
		}
		say OUT $GENO;
	}
}
exit;
