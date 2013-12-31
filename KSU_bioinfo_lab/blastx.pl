#!/bin/perl
##################################################################################
#
# USAGE: perl blastx.pl [FASTA filename]
# Script output fasta records split into files  of 100 or less sequences in a directory called split. It also creates blastx bash scripts and qsub commands.
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
my $file_count=1;
my $seq_count=0;
my $max_seqs=100;
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
`mkdir ${directories}blasts`;
while(<OLD_FASTA>)
{
	unless (${seq_count} == 0) ## skip first record (it is a blank line)
	{
        ##################################################################################
        ##############    open new file create jobs and qsub commands   ##################
        ##################################################################################
		if ($seq_count==1)
		{
			$outfilename="${directories}split/${filename}_${file_count}.fasta";
			open OUTFILE, '>', $outfilename  or die "Couldn't open $outfilename !\n";
			my $bashs="${directories}jobs/${filename}_${file_count}.sh";
			open SH, '>', $bashs  or die "Couldn't open $bashs !\n";
			print SH '#!/bin/bash';
			print SH "\n/homes/bioinfo/bioinfo_software/ncbi-blast-2.2.28+/bin/blastx -query ${outfilename} -db  /homes/bioinfo/bioinfo_software/blastdb/nr -evalue 1e-05 -out ${directories}blasts/${filename}_${file_count}.xml -outfmt 5 -max_target_seqs 1 -num_threads 16\n";
			print QSUBS "qsub -l mem=1G,h_rt=4:00:00 -pe single 16 -m abe -M jennifer.shelton\@gmail.com ${bashs}\n";
			++$file_count;
		}
        ##################################################################################
        ##############            populate fasta file                   ##################
        ##################################################################################
		print OUTFILE '>';
		s/>//g;
		print OUTFILE "$_";
        ##################################################################################
        ##############                 reset counter                    ##################
        ##################################################################################
		if ($seq_count==$max_seqs)
		{
			$seq_count=0; ## reset counter
			close (OUTFILE);
		}
        
    }
    ++$seq_count;
}
close (OLD_FASTA);
