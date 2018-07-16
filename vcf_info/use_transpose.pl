#!/usr/bin/perl
use warnings;
use strict;
use v5.16;

my $filename = $ARGV[0];

## using modified file
my @missing_array =();
my @het_array =();
my @het_array_5 =();

open IN1, "transposed-$filename" or die "File not found.";

my $skip = 0;
my $samples =0;
while(<IN1>){
	$skip++;
	if ($skip < 10){
		next;
	}
	
	$samples++;
	#say $_;
	my @all = split("\t", $_);
	#say scalar@all;
	
	my $het = 0;
	my $miss = 0;
	my $hom = 0;
	foreach my $i (@all){
		my $geno = substr($i,0,3);
		if ($geno eq "./."){
			$miss++;
		}
		elsif($geno eq "0/1" or $geno eq "1/0"){
			$het++;
		}
		else{
			$hom++;
		}
	} 
	
	my $total_snps = scalar@all;
	
	my $missing_percent = sprintf( "%.2f", ( $miss / $total_snps * 100 ) );
	# Het percent
	my $het_percent = sprintf( "%.2f", ( $het / $total_snps * 100 ) );
	
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
		if($het_percent >= 0 and $het_percent <2){
			push @{$het_array_5[0]}, $het_percent;
		}
		elsif($het_percent >= 2 and $het_percent <4){
			push @{$het_array_5[1]}, $het_percent;
		}
		elsif($het_percent >= 4 and $het_percent <6){
			push @{$het_array_5[2]}, $het_percent;
		}
		elsif($het_percent >= 6 and $het_percent <8){
			push @{$het_array_5[3]}, $het_percent;
		}
		elsif($het_percent >= 8 and $het_percent <10){
			push @{$het_array_5[4]}, $het_percent;
		}
		
		
		elsif($het_percent >= 10 and $het_percent <20){
			push @{$het_array[0]}, $het_percent;
		}
		elsif($het_percent >= 20 and $het_percent <30){
			push @{$het_array[1]}, $het_percent;
		}
		elsif($het_percent >= 30 and $het_percent <40){
			push @{$het_array[2]}, $het_percent;
		}
		elsif($het_percent >= 40 and $het_percent <50){
			push @{$het_array[3]}, $het_percent;
		}
		elsif($het_percent >= 50 and $het_percent <60){
			push @{$het_array[4]}, $het_percent;
		}
		elsif($het_percent >= 60 and $het_percent <70){
			push @{$het_array[5]}, $het_percent;
		}
		elsif($het_percent >= 70 and $het_percent <80){
			push @{$het_array[6]}, $het_percent;
		}
		elsif($het_percent >= 80 and $het_percent <90){
			push @{$het_array[7]}, $het_percent;
		}
		elsif($het_percent >= 90 and $het_percent <=100){
			push @{$het_array[8]}, $het_percent;
		}
}

say "Total samples: $samples";
say "Distribution of missing in samples:";
my $first = 0;
my $sec = 10;
foreach my $i (@missing_array) {
 	if (defined $i){say "$first-$sec%: ", scalar@$i};
 	$first += 10;
 	$sec += 10;
}

#say scalar@{$het_array[0]};
say "Distribution of Het in samples:";
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

# remove transposed file
`rm transposed-$filename`;



