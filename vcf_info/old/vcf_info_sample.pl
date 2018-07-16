#!/usr/bin/perl
use warnings;
use strict;
use v5.16;

my $filename = "all10-chi.vcf";

# number of samples
open IN, $filename or die "Cannot find file";

my $samples;
while(<IN>){
	if($_ !~ /^#/){
		chomp $_;
		my @check = split("\t", $_);
		$samples = scalar@check - 9;
		last;
	}
}

#say $samples;
my $snps = (`grep -vc "^#" $filename`);

my @missing_array =();
my @het_array =();

for my $i ( 10..$samples ) {
	my $output =
`awk -F"\t" '/^[^#]/ {print substr(\$$i,1,3)}' $filename | sort | uniq -c`;
#`grep -v "^#" $filename | awk -F"\t" '{print \$$i}' | cut -c 1-3 | sort | uniq -c`;
	$output =~ s/\n/ /g;
	#say $output;

	my ( $missing, $hom, $het );
	my @values = split( " ", $output );
	
	if ( not defined $values[1] and not defined $values[0]) {
		$missing = 0;
		#say $missing;
	}
	elsif ( $values[1] eq "./." and defined $values[0]) {
		$missing = $values[0];
		#say $missing;
	}
	
	if (not defined $values[5] and not defined $values[4] and not defined $values[7] and not defined $values[6]) {
		$het = 0;
	}
	elsif (not defined $values[5] and not defined $values[4]){
		$het = $values[6];
	} 
	elsif (not defined $values[7] and not defined $values[6]){
		$het = $values[4];
	}
	elsif ( $values[5] eq "0/1" and defined $values[4] and $values[7] eq "1/0" and defined $values[6]) {
		$het = $values[4] + $values[6];
		#say $het;
	}
	
	# Missing percent
	my $missing_percent = sprintf( "%.2f", ( $missing / $snps * 100 ) );
	# Het percent
	my $het_percent = sprintf( "%.2f", ( $het / $snps * 100 ) );
	
	#say $missing_percent;
	#say $het_percent;
	
	if($missing_percent >= 0 and $missing_percent <10){
			push @{$missing_array[0]}, $missing_percent;
			#say $missing;
		}
		elsif($missing_percent >= 10 and $missing_percent <20){
			push @{$missing_array[1]}, $missing_percent;
		}
		elsif($missing_percent >= 20 and $missing_percent <30){
			push @{$missing_array[2]}, $missing_percent;
		}
		elsif($missing_percent >= 30 and $missing_percent <40){
			push @{$missing_array[3]}, $missing_percent;
		}
		elsif($missing_percent >= 40 and $missing_percent <50){
			push @{$missing_array[4]}, $missing_percent;
		}
		elsif($missing_percent >= 50 and $missing_percent <60){
			push @{$missing_array[5]}, $missing_percent;
		}
		elsif($missing_percent >= 60 and $missing_percent <70){
			push @{$missing_array[6]}, $missing_percent;
		}
		elsif($missing_percent >= 70 and $missing_percent <80){
			push @{$missing_array[7]}, $missing_percent;
		}
		elsif($missing_percent >= 80 and $missing_percent <90){
			push @{$missing_array[8]}, $missing_percent;
		}
		else{
			push @{$missing_array[9]}, $missing_percent;
		}
		
		# access the array of array
		# for HET
		if($het_percent >= 0 and $het_percent <10){
			push @{$het_array[0]}, $het_percent;
		}
		elsif($het_percent >= 10 and $het_percent <20){
			push @{$het_array[1]}, $het_percent;
		}
		elsif($het_percent >= 20 and $het_percent <30){
			push @{$het_array[2]}, $het_percent;
		}
		elsif($het_percent >= 30 and $het_percent <40){
			push @{$het_array[3]}, $het_percent;
		}
		elsif($het_percent >= 40 and $het_percent <50){
			push @{$het_array[4]}, $het_percent;
		}
		elsif($het_percent >= 50 and $het_percent <60){
			push @{$het_array[5]}, $het_percent;
		}
		elsif($het_percent >= 60 and $het_percent <70){
			push @{$het_array[6]}, $het_percent;
		}
		elsif($het_percent >= 70 and $het_percent <80){
			push @{$het_array[7]}, $het_percent;
		}
		elsif($het_percent >= 80 and $het_percent <90){
			push @{$het_array[8]}, $het_percent;
		}
		else{
			push @{$het_array[9]}, $het_percent;
		}
}

say "Distribution of missing in Samples:";
my $first = 0;
my $sec = 10;
foreach my $i (@missing_array) {
 	if (defined $i){say "$first-$sec%: ", scalar@$i};
 	$first += 10;
 	$sec += 10;
}

#say scalar@{$het_array[0]};
 my $first1 += 0;
 my $sec1 += 10;
say "Distribution of Het in Samples:";
foreach my $i (@het_array) {
 	if (defined $i){say "$first1-$sec1%: ", scalar@$i};
 	$first1 += 10;
 	$sec1 += 10;
}


=comment
seriXhartog-tags.fastq.filtered.vcf

Distribution of missing in Samples:
0-10%: 12
10-20%: 122
20-30%: 194
30-40%: 111
40-50%: 51
50-60%: 31
60-70%: 18
70-80%: 10
80-90%: 5
90-100%: 8
Distribution of Het in Samples:
0-10%: 153
10-20%: 399
20-30%: 8
30-40%: 2