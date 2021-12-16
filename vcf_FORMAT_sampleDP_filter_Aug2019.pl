#!/usr/bin/perl
use warnings;
use strict;
use v5.16;

unless ($ARGV[0] && $ARGV[1] && $ARGV[2]){
 print "########## USAGE ##########\n\n";
 print "$0 file.vcf total_samples_in_vcf_file min_depth_at_each_datapoint\n";
 print "$0 file.vcf 17 10\n\n";
 say "It works if FORMAT is: GT:PL:DP:SP:GQ	./.:0,0,0,0,0,0,0,0,0,0:0:0:5\nIf there is some value in DP.\nThis won't work GT:AD:DP:GQ:PL ./. Error: Use of uninitialized value in numeric ge.\nCan filter for no missing and run";	
exit;
}


my $filename = $ARGV[0];
# total samples in the vcf file
my $samples       = $ARGV[1];
# at least read depth (DP) in the sample to be present
my $min_depth     = $ARGV[2];

###################################################################
my $total_columns = $samples + 9;
my $outFile = "dpAtleast$min_depth\_$filename";
open IN, $filename or die "Cannot find file";
open OUT, ">$outFile" or die "Cannot make file";

my @each_depth;
my $FilteredSNPs = 0;
my $totalSNPs = 0;
while (<IN>) {
	my $line = $_;

	# direct headers to output
	if ( $_ =~ /^#/ ) {
		print OUT $_;
	}

	# process SNP locations
	else {
		chomp $_;
		
		# count total SNPs
		$totalSNPs++;

		my @columns = split( "\t", $_ );
		
		# If genotype has . then skip
		if ($columns[3] eq "." or $columns[4] eq "."){
			next;
		}
		
		# If genotype has single "N" then skip
		if ($columns[3] eq "N" or $columns[4] eq "N"){
			next;
		}
		
		
		# If more than one allele
		if (length$columns[3] > 1 or length$columns[4] > 1){
			#say $_;
			next;
		}

		# Column 8 is format
		#say $columns[8];
		my @format_column = split( ":", $columns[8] );

		# finding DP position:
		my $dp_position;
		for ( my $j = 0 ; $j < @format_column ; $j++ ) {
			if ( $format_column[$j] eq "DP" ) {

				#say $j;
				$dp_position = $j;

				#push @count_2, $j;
			}
		}
		#say "DP position in the FORMAT is:";
		#say $dp_position;

	 # starting from column 10, sample starts here, access DP using $dp_position
		for ( my $i = 9 ; $i < $total_columns ; $i++ ) {
			my @each_column = split( ":", $columns[$i] );

			#say $each_column[$dp_position];

			# check if DP at each sample is >= filter value
			if ( $each_column[$dp_position] >= $min_depth ) {

				#say $each_column[$dp_position];

				# count all samples having DP >= given value
				push @each_depth, $each_column[$dp_position];
			}
		}
# check if the total samples equal to total samples having filtered DP, if yes, SNP passed
		if ( scalar @each_depth == $samples ) {
			print OUT "$_\n";
			#say "$samples", " ", scalar @each_depth;
			
			# count filtered SNPs
			$FilteredSNPs++;
		}

		# restart @each_depth array again for another SNP position
		@each_depth = "";
		shift @each_depth;
	}
}

say "Total SNPs in $filename file: $totalSNPs";
say "Total SNPs after filtering in $outFile (DP at each sample >= $min_depth : $FilteredSNPs)";

close(IN);
close(OUT);
exit;
