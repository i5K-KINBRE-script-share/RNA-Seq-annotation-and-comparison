#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use IO::File;
#  count_reads_aligned_to_de_novo_transcriptome.pl
#  USAGE: perl count_reads_aligned_to_de_novo_transcriptome.pl [filename/s]
# This script takes sam files (one per biological or technical replicate) and outputs tab separated list where the first column is the name of the contig and the values are the read counts per sample (in the same order as you listed your sam files)
# The script will print out sample ids. replace the example sample ids in line 17 with yourown before running. This step is optional. Uncomment line 16 to 17 and lines 47 to 57 if you want these printed.
#
#  Created by jennifer shelton on 6/23/13.
##################  define variables #################################################
my $outfile="counts.txt"; # the name of the output file can be changed here
my (@temp,@default);
my (%hash);
#my $j;
#my (@samples)=qw/sample1 sample2 sample3/; #replace with your sample ids in the order that you list your sam files
my ($contig,$k);
my $i=0;
for (0..$#ARGV) ## populate default values for each contig
{
    push(@default,'0');
}

open (COUNT_FILES, ">$outfile"); 
foreach my $f (@ARGV) ## make a hash of raw counts
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


# foreach $j (0 .. $#samples) ## optional printing a samplids, comment out lines 45 to 55 if you do not want these
# {
# 	if ($j < $#samples)
# 	{
# 		print COUNT_FILES "$samples[$j]\t";
# 	}
# 	else
# 	{
# 		print COUNT_FILES "$samples[$j]\n";
# 	}
# }
foreach $contig ( keys %hash ) ## print out table of raw counts
{
    print COUNT_FILES "$contig\t";
    foreach $k ( 0 .. $#{ $hash{$contig} } )
    {
    	if ($k < $#{ $hash{$contig} })
    	{
        	print COUNT_FILES "$hash{$contig}[$k]\t";
    	}
        else
        {
        	print COUNT_FILES "$hash{$contig}[$k]\n";
        }
	}
}

	
