#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use IO::File;
#  count_reads_aligned_to_de_novo_transcriptome.pl
#  USAGE: perl count_reads_aligned_to_de_novo_transcriptome.pl [filename/s]
# This script takes sam files (one per biological or technical replicate) and outputs a hash where the keys are the name of the contig and the values are an array with one element per sample (in the same order as you listed your sam files)
#
#  Created by jennifer shelton on 6/23/13.
##################  define variables #################################################
my $outfile="counts.txt";
my (@temp);
my (%hash);
my $i=0;
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
	        	$hash{$temp[2]} =[];
	        }
	       	$hash{$temp[2]}->[$i]++;
	    }
    }
    $i++;
	$file->close;
}

print COUNT_FILES Dumper( \%hash );	        
	