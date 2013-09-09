#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use IO::File;
#  count_reads_aligned_to_de_novo_transcriptome.pl
#  USAGE: perl count_reads_aligned_to_de_novo_transcriptome.pl [filename/s]
# This script takes sam files (one per biological or technical replicate) and outputs tab separated list where the first column is the name of the contig and the values are the read counts per sample (in the same order as you listed your sam files)
#
#  Created by jennifer shelton on 6/23/13.
##################  define variables #################################################
my $outfile="counts.txt";
my (@temp,@default);
my (%hash);
my $contig;
my $i=0;
for (0..$#ARGV)
{
    push(@default,'0');
}

open (COUNT_FILES, ">$outfile");
foreach my $f (@ARGV)
{
	my $file = IO::File->new($f);
	while (<$file>)
	{
	    unless (/^\@/)
	    {
	        @temp=split(/\t/);
	        print "($temp[2])\n";
	        if (! $hash{$temp[2]})
	        {
	        	$hash{$temp[2]} =[@default];
	        }
	       	$hash{$temp[2]}->[$i]++;
	    }
    }
    $i++;
	$file->close;
}

print COUNT_FILES Dumper( \%hash );
foreach $contig ( keys %hash )
{
    print COUNT_FILES "$contig\t";
    foreach $i ( 0 .. $#{ $hash{$contig} } )
    {
        print COUNT_FILES "$hash{$contig}[$i]\t";
    }
    print COUNT_FILES "\n";
}

	
