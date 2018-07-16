#!/usr/bin/perl
use warnings;
use strict;
use v5.16;

my $filename = $ARGV[0];
open IN, $filename or die "Cannot find file";

my $no_columns;
my $total_snps = 0;
my @missing_array =();
my @het_array =();
my @het_array_5 =();
my ($het5, $het10);

while (<IN>) {
	# skip vcf header and keep heading with sample info
	if ( $_ =~ /^#/ ) {
		if ( $_ =~ /^#CHROM/ ) {
			chomp $_;
			my @header = split( "\t", $_ );

			# number of columns
			$no_columns = scalar @header;
		}
	}
	else {
		# print $_;
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
		
		# count snps
		$total_snps++;

		my $call;

		# for fisher test
		my $ref_count  = 0;
		my $alt_count  = 0;
		my $het_count  = 0;
		my $null_count = 0;


		for ( my $i = 9 ; $i < $no_columns ; $i++) {
			my $genotype = substr( $columns[$i], 0, 3 );

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
					$call = "$columns[3]$columns[3]";
					$ref_count++;
				}

				# Het
				elsif ($genotype eq "0/1"
					or $genotype eq "1/0"
					or $genotype eq "0|1"
					or $genotype eq "1|0" )
				{
					$call = "$columns[3]$columns[4]";
					$het_count++;
				}

				# Hom Alt
				elsif ( $genotype eq "1/1" or $genotype eq "1|1" ) {
					$call = "$columns[4]$columns[4]";
					$alt_count++;
				}
			}

			# No genotype call in the VCF file
			else {
				$null_count++;
			}

		}

		# for MAF
		my $total_check = $ref_count + $alt_count + $het_count + $null_count;
		my $sample_wo_missing = $ref_count + $alt_count + $het_count;
		my $total_allele      = 2 * $sample_wo_missing;
		my $allele_1          = ( 2 * $ref_count + $het_count ) / $total_allele;
		my $allele_2          = ( 2 * $alt_count + $het_count ) / $total_allele;

		my $allele_1_rounded = sprintf( "%.2f", $allele_1 );
		my $allele_2_rounded = sprintf( "%.2f", $allele_2 );

		#say $total_allele;
		#say $allele_1_rounded;
		#say $allele_2_rounded;

		# for missing
		my $missing = sprintf( "%.2f", ( $null_count / $total_check * 100 ) );
		#say $missing;
		
	if($missing >= 0 and $missing <10){
			push @{$missing_array[0]}, $missing;
			#say $missing;
		}
		elsif($missing >= 10 and $missing <20){
			push @{$missing_array[1]}, $missing;
		}
		elsif($missing >= 20 and $missing <30){
			push @{$missing_array[2]}, $missing;
		}
		elsif($missing >= 30 and $missing <40){
			push @{$missing_array[3]}, $missing;
		}
		elsif($missing >= 40 and $missing <50){
			push @{$missing_array[4]}, $missing;
		}
		elsif($missing >= 50 and $missing <60){
			push @{$missing_array[5]}, $missing;
		}
		elsif($missing >= 60 and $missing <70){
			push @{$missing_array[6]}, $missing;
		}
		elsif($missing >= 70 and $missing <80){
			push @{$missing_array[7]}, $missing;
		}
		elsif($missing >= 80 and $missing <90){
			push @{$missing_array[8]}, $missing;
		}
		else{
			push @{$missing_array[9]}, $missing;
		}
		
		# access the array of array
		# for HET
		my $het = sprintf( "%.2f", ( $het_count / $sample_wo_missing * 100 ) );
		if($het >= 0 and $het <2){
			push @{$het_array_5[0]}, $het;
		}
		elsif($het >= 2 and $het <4){
			push @{$het_array_5[1]}, $het;
		}
		elsif($het >= 4 and $het <6){
			push @{$het_array_5[2]}, $het;
		}
		elsif($het >= 6 and $het <8){
			push @{$het_array_5[3]}, $het;
		}
		elsif($het >= 8 and $het <10){
			push @{$het_array_5[4]}, $het;
		}
		
		
		elsif($het >= 10 and $het <20){
			push @{$het_array[0]}, $het;
		}
		elsif($het >= 20 and $het <30){
			push @{$het_array[1]}, $het;
		}
		elsif($het >= 30 and $het <40){
			push @{$het_array[2]}, $het;
		}
		elsif($het >= 40 and $het <50){
			push @{$het_array[3]}, $het;
		}
		elsif($het >= 50 and $het <60){
			push @{$het_array[4]}, $het;
		}
		elsif($het >= 60 and $het <70){
			push @{$het_array[5]}, $het;
		}
		elsif($het >= 70 and $het <80){
			push @{$het_array[6]}, $het;
		}
		elsif($het >= 80 and $het <90){
			push @{$het_array[7]}, $het;
		}
		else{
			push @{$het_array[8]}, $het;
		}
	}	
}

say "Total bi-allelic SNPs: $total_snps";
say "Distribution of missing in SNPs:";
my $first = 0;
my $sec = 10;
foreach my $i (@missing_array) {
 	if (defined $i){say "$first-$sec%: ", scalar@$i};
 	$first += 10;
 	$sec += 10;
}

#say scalar@{$het_array[0]};

say "Distribution of Het in SNPs:";
 my $first2 += 0;
 my $sec2 += 2;
 
foreach my $i (@het_array_5) {
 	if (defined $i){say "$first2-$sec2%: ", scalar@$i};
 	$first2 += 2;
 	$sec2 += 2;
}

 my $first1 += 10;
 my $sec1 += 20;
foreach my $i (@het_array) {
 	if (defined $i){say "$first1-$sec1%: ", scalar@$i};
 	$first1 += 10;
 	$sec1 += 10;
}
close(IN);
exit;

