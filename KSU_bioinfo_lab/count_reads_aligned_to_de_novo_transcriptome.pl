#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;
use IO::File;
#  count_reads_aligned_to_de_novo_transcriptome.pl
#  USAGE: perl count_reads_aligned_to_de_novo_transcriptome.pl [filename/s]
# This script takes sam files from Bowtie2 (one per biological or technical replicate) and outputs tab separated list where the first column is the name of the contig and the values are the read counts per sample (in the same order as you listed your sam files)
# Added filters based on MAPQ and pair relationships for Bowtie2 sam files 
# Change the default MAPping Quality in line 23.
# The script will print out sample ids. Replace the example sample ids in line 19 with your own before running. This step is optional. Uncomment line 18 to 19 and lines 144 to 154 if you want these printed.
#
#  Created by jennifer shelton on 9/15/13.
##################  define variables #################################################
my $outfile="counts.txt"; # the name of the output file can be changed here
my (@temp,@default);
my (%count_hash);
# my $j;
# my (@samples)=qw/sample1 sample2 sample3/; #replace with your sample ids in the order that you list your sam files
my ($contig,$k);
my $i=0;
################################ Set filters ###############################
my $mapq=10;
################################ create default hash entry ############################
for (0..$#ARGV) ## populate default values for each contig
{
    push(@default,'0');
}
open (COUNT_FILES, ">", "$outfile") or die "cannot open $outfile: $!";
################################ make a count_hash of raw counts ################################
print "Summary of fragments counted by this script:\n"; # header for output summary
foreach my $f (@ARGV)
{
	my $concordant_pair_mapped_read=0;
	my $discordant_pair_mapped_read=0;
	my $unpaired_mate_mapped_reads=0; # only one end maps relatively unambiguously (above MAPQ cutoff) 
	my $single_end_mapped_reads=0;
	my $fragment=0; # counts one for each pair or singleton (UU in Bowtie2 syntax) regardless of whether or not they map
	my %read_hash;
	my $file = IO::File->new();
    	if ($file->open("< $f")) {print "$f opened\n";}
    	else {print "could not open $f\n";}
	while (<$file>)
	{
		unless (/^\@/)
 	   {
	        @temp=split(/\t/);
	        unless ($count_hash{$temp[2]}) ## if we haven't seen the contig before add it to contig count_hash
	        {
	        	$count_hash{$temp[2]} =[@default];
	        }
################################ require pairs map to same contig ################################
	        if ($temp[6] eq '=')
	        {
################################ count concordant pairs ################################
	        	if ($_ =~ /YT:Z:CP/)
	        	{
	        		unless ($read_hash{$temp[0]})
	        		{
	        			$fragment++;
	        			if (($temp[4]>$mapq)&&($temp[4]!=255))
	        			{
	        				$read_hash{$temp[0]}=1;
	        			}
	        			else
	        			{
	        				$read_hash{$temp[0]}=0;
	        			}
	        		}
	        		else
	        		{ 
	        			if ((($temp[4]>$mapq)&&($temp[4]!=255)) || ($read_hash{$temp[0]}==1))
	        			{
	        				$count_hash{$temp[2]}->[$i]++; ## count one for a paired read where one or both ends map relatively unambiguously (above MAPQ cutoff)
	        				$concordant_pair_mapped_read++;
	        			}
	        		}
	        	}	        				        		
################################ count discordant pairs ################################	        		
	        	if ($_ =~ /YT:Z:DP/)
	        	{
	        		unless ($read_hash{$temp[0]})
	        		{
	        			$fragment++;
	        			if (($temp[4]>$mapq)&&($temp[4]!=255))
	        			{
	        				$read_hash{$temp[0]}=1;
	        			}
	        			else
	        			{
	        				$read_hash{$temp[0]}=0;
	        			}
	        		}
	        		else
	        		{ 
	        			if ((($temp[4]>$mapq)&&($temp[4]!=255)) || ($read_hash{$temp[0]}==1))
	        			{
	        				$count_hash{$temp[2]}->[$i]++; ## count one for a paired read where one or both ends map relatively unambiguously (above MAPQ cutoff)
	        				$discordant_pair_mapped_read++;
	        			}
	        		}
	        	}
	        }
	        elsif (($read_hash{$temp[0]}) && ($temp[6] ne '=') && (($_ =~ /YT:Z:CP/) || ($_ =~ /YT:Z:DP/)))
	        {
	        	$fragment++;
	        	$read_hash{$temp[0]}=0;
	        }
################# if one pair fails and one passes count broken pairs (UP) ################################	        		
	        if ($_ =~ /YT:Z:UP/)
	        	{
	        		unless ($read_hash{$temp[0]})
	        		{
	        			$fragment++;
	        			if (($temp[4]>$mapq)&&($temp[4]!=255))
	        			{
	        				$read_hash{$temp[0]}=1;
	        			}
	        			else
	        			{
	        				$read_hash{$temp[0]}=0;
	        			}
	        		}
	        		else
	        		{ 
	        			if ((($temp[4]>$mapq)&&($temp[4]!=255)) && ($read_hash{$temp[0]}==0))
	        			{
	        				$count_hash{$temp[2]}->[$i]++; ## count one for a paired read where only one end maps relatively unambiguously (above MAPQ cutoff)
	        				$unpaired_mate_mapped_reads++;
	        			}
	        			elsif ((($temp[4]<=$mapq)||($temp[4]==255)) && ($read_hash{$temp[0]}==1))
	        			{
	        				$count_hash{$temp[2]}->[$i]++; ## count one for a paired read where only one end maps relatively unambiguously (above MAPQ cutoff)
	        				$unpaired_mate_mapped_reads++;
	        			}	        			
	        		}
	        	}	
################################# count single end reads (UU) ##################################	        		
	        if ($_ =~ /YT:Z:UU/)
	        	{
	        		$fragment++;
	        		if (($temp[4]>$mapq)&&($temp[4]!=255))
	        		{
	  	        		$count_hash{$temp[2]}->[$i]++; ## count one for a single end read read maps relatively unambiguously (above MAPQ cutoff)
	        			$single_end_mapped_reads++;
	        		}
	        	}
		}
	    
    	}
    	print "$f concordant_pairs that were added to count summary=$concordant_pair_mapped_read\n";
	print "$f discordant_pairs that were added to count summary=$discordant_pair_mapped_read\n";
	print "$f unpaired_mates that were added to count summary=$unpaired_mate_mapped_reads\n";
	print "$f single_end_reads that were added to count summary=$single_end_mapped_reads\n";
	print "$f fragments (counted and uncounted)=$fragments\n";
    	$i++;
	$file->close;
}
# foreach $j (0 .. $#samples) ## optional printing of sample ids, uncomment out lines 42 to 43 and lines 168 to 178 if you want a sample id row
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
foreach $contig ( keys %count_hash ) ## print out table of raw counts
{
    print COUNT_FILES "$contig\t";
    foreach $k ( 0 .. $#{ $count_hash{$contig} } )
    {
    	if ($k < $#{ $count_hash{$contig} })
    	{
        	print COUNT_FILES "$count_hash{$contig}[$k]\t";
    	}
        else
        {
        	print COUNT_FILES "$count_hash{$contig}[$k]\n";
        }
	}
}
