#!/usr/bin/perl
use warnings;
use strict;
use v5.16;

my $filename = $ARGV[0];

my $blank = `grep "^#CHROM" $filename | tr -s '\t'  '\n' | grep -ci "BLANK"`;

open IN, $filename or die "Cannot find file";
open OUT, ">transposed-$filename";

my(%data);       
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

# transpose file
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


print "Total blank samples: $blank";

close(IN);

close(OUT);
exit;