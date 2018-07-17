#!/usr/bin/perl
use warnings;
use strict;
use v5.16;

my $filename = "seriXhartog-tags.fastq.filtered.vcf";
open IN, $filename or die "Cannot find file";
open OUT, ">transposed-$filename";

my(%data);          # main storage
my($maxcol) = 0;
my($rownum) = 0;
while (<IN>)
{
	if ($_ =~ /^#/){next};
	
    my(@row) = split /\s+/;
    my($colnum) = 0;
    foreach my $val (@row)
    {
        $data{$rownum}{$colnum++} = $val;
    }
    $rownum++;
    $maxcol = $colnum if $colnum > $maxcol;
}

my $maxrow = $rownum;
for (my $col = 0; $col < $maxcol; $col++)
{
    for (my $row = 0; $row < $maxrow; $row++)
    {
        printf OUT "%s%s", ($row == 0) ? "" : "\t",
                defined $data{$row}{$col} ? $data{$row}{$col} : "";
    }
    print OUT "\n";
}

=comment
Awk for transpose:

awk '
{ 
    for (i=1; i<=NF; i++)  {
        a[NR,i] = $i
    }
}
NF>p { p = NF }
END {    
    for(j=1; j<=p; j++) {
        str=a[1,j]
        for(i=2; i<=NR; i++){
            str=str" "a[i,j];
        }
        print str
    }
}'


