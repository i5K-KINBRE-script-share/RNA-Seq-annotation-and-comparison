#!/bin/perl
##################################################################################
#   
# USAGE: perl blastx.pl [FASTA filename]
# Script output fasta records split into files  of 1000 or less sequences in a directory called split. It also creates blastx bash scripts and qsub commands.
#  Created by jennifer shelton 12/30/13
#
##################################################################################
use strict;
use warnings;
use IO::File;
use File::Basename; # enable maipulating of the full path
# use List::Util qw(max);
# use List::Util qw(sum);

##################################################################################
##############             Initialize variables                 ##################
##################################################################################
my $file_count=0;
my $seq_count=0;
my $max_seqs=1000;
my $outfilename;
##################################################################################
##############              open fasta get fullpath             ##################
##################################################################################

$/ = ">"; ### each input will equal an entire fasta record
my $f = $ARGV[0];
open OLD_FASTA,'<', $f or die "Couldn't open $f !\n"; 	# you need to request a warning because we are opening with "open" not BioPerl
my (${filename}, ${directories}, ${suffix}) = fileparse($f,'\..*');
my $subs="${directories}/${filename}_qsubs.sh";
open QSUBS, '>', $subs or die "Couldn't open $subs !\n";
##################################################################################
##############                create split files                ##################
##################################################################################

`mkdir ${directories}split`;
`mkdir ${directories}jobs`;
while(<OLD_FASTA>)
{
	unless (${file_count} == 0) ## skip first record (it is a blank line)
	{
##################################################################################
##############    open new file create jobs and qsub commands   ##################
##################################################################################
		if ($seq_count==0)
		{
			$outfilename="${directories}split/${filename}_${file_count}.fasta";
			open OUTFILE, '>', $outfilename  or die "Couldn't open $outfilename !\n";
			my $bashs="${directories}jobs/${filename}_${file_count}.sh";
			open SH, '>', $bashs  or die "Couldn't open $bashs !\n";
			print SH '#!/bin/bash';
			print SH "\n/homes/bioinfo/bioinfo_software/ncbi-blast-2.2.28+/bin/blastx -query ${outfilename} -db  /homes/bioinfo/bioinfo_software/blastdb/nr -evalue 1e-05 -out ${directories}split/${filename}_${file_count}.xml -outfmt 5 -max_target_seqs 1 -num_threads 16\n";
			print QSUBS "qsub -l mem=2G,h_rt=672 -pe single 16 ${bashs}\n";
			++$file_count;
		}
##################################################################################
##############            populate fasta file                   ##################
##################################################################################

		if ($seq_count!=0)
		{
            print OUTFILE '>';
    		print OUTFILE "$_";
    	}
##################################################################################
##############                 reset counter                    ##################
##################################################################################
		if ($seq_count==1000)
		{
			$seq_count=-1; ## reset counter
			close (OUTFILE);
		}	
	++$seq_count;
    }
    else 
    {
    	${file_count}=1; ## skip first record (it is a blank line)
    }
}
close (OLD_FASTA);
