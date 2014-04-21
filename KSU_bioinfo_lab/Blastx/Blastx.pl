#!/usr/bin/perl
##################################################################################
#
# USAGE: perl Blastx.pl [FASTA filename]
# Script output fasta records split into files  of 100 or less sequences in a directory called split. It also creates blastx bash scripts and qsub commands.
#  Created by jennifer shelton 12/30/13
#
##################################################################################
use strict;
use warnings;
use IO::File;
use File::Basename; # enable maipulating of the full path
use lib '/homes/bioinfo/bioinfo_software/perl_modules/File-Slurp-9999.19/lib';
use File::Slurp;
# use List::Util qw(max);
# use List::Util qw(sum);
use Getopt::Long;
use Pod::Usage;
###############################################################################
##############         Print informative message             ##################
###############################################################################
print "###########################################################\n";
print "#  Blastx.pl Version 1.1                                  #\n";
print "#                                                         #\n";
print "#  Created by Jennifer Shelton 12/30/13                   #\n";
print "#  github.com/i5K-KINBRE-script-share                     #\n";
print "#  perl Blastx.pl -help # for usage/options               #\n";
print "#  perl Blastx.pl -man # for more details                 #\n";
print "###########################################################\n";
###############################################################################
##############                get arguments                  ##################
###############################################################################
my $input_fasta;
my $file_count = 1;
my $seq_count = 0;
my $split_fasta = 100;
my $one_hundred_fastas;
my $max_target_seqs = 1;
my $evalue = 1e-05;
my $h_rt = '4:00:00';
my $man = 0;
my $help = 0;
GetOptions (
        'help|?' => \$help,
        'man' => \$man,
        'f|input_fasta:s' => \$input_fasta,
        'm|max_target_seqs:i' => \$max_target_seqs,
        'e|evalue:s' => \$evalue,
        'h_rt:s' => \$h_rt,
)
or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;
sub quote { qq!"$_[0]"! } ## interpolate slurped text
my $dirname = dirname(__FILE__); # github directories (all github directories must be in the same directory)
##################################################################################
##############              open fasta get fullpath             ##################
##################################################################################

$/ = ">"; ### each input will equal an entire fasta record
open OLD_FASTA,'<', $input_fasta or die "Couldn't open $input_fasta !\n"; 	# you need to request a warning because we are opening with "open" not BioPerl
my (${filename}, ${directories}, ${suffix}) = fileparse($input_fasta,'\..*');
my $subs="${directories}/${filename}_qsubs.sh";
open QSUBS, '>', $subs or die "Couldn't open $subs !\n";
##################################################################################
##############                create split files                ##################
##################################################################################

`mkdir ${directories}split`;
`mkdir ${directories}jobs`;
`mkdir ${directories}blasts`;
`mkdir ${directories}logs`;
while(<OLD_FASTA>)
{
	unless (${seq_count} == 0) ## skip first record (it is a blank line)
	{
        ##################################################################################
        ##############    open new file create jobs and qsub commands   ##################
        ##################################################################################
		if ($seq_count==1)
		{
			$one_hundred_fastas="${directories}split/${filename}_${file_count}.fasta";
			open OUTFILE, '>', $one_hundred_fastas  or die "Couldn't open $one_hundred_fastas !\n";
			my $bashs="${directories}jobs/${filename}_${file_count}.sh";
			open SH, '>', $bashs  or die "Couldn't open $bashs !\n";
            my $text_out = read_file("${dirname}/Blastx_template.txt"); ## read shell template with slurp
            $one_hundred_fastas="${directories}split/${filename}_${file_count}.fasta";
            my $blast_xml = "${directories}blasts/${filename}_${file_count}.xml";
            
            print SH eval quote($text_out);
            print SH "\n";
			print QSUBS "qsub -l mem=1G,h_rt=${h_rt} -e ${directories}logs/ -o ${directories}logs/ -pe single 16 ${bashs}\n";
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
		if ($seq_count==$split_fasta)
		{
			$seq_count=0; ## reset counter
			close (OUTFILE);
		}
        
    }
    ++$seq_count;
}
close (OLD_FASTA);
##################################################################################
##############                  Documentation                   ##################
##################################################################################
## style adapted from http://www.perlmonks.org/?node_id=489861
__END__

=head1 NAME

Blastx.pl - Script outputs fasta records split into files of 100 or less sequences in a directory called split. It also creates blastx bash scripts and qsub commands to annotate a de novo transcriptome with hits to the nr protein database.

=head1 USAGE
 
 perl Blastx.pl [options]
 
 Documentation options:
    -help    brief help message
    -man	    full documentation
 Required parameters:
    -f	    fasta to annotate with blastx
 Optional parameters:
    -m	     maximum sequences to report alignments for
    -e	     e-value
    --h_rt	 hours runtime in hh:mm:ss
 
=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the more detailed manual page with output details and examples and exits.
 
=item B<-f, --input_fasta>
 
The fullpath for the fasta file of assembled transcripts. These will be split into smaller files with no more than 100 sequences per file and blasted against the "nr" database.

=item B<-m, --max_target_seqs>

Maximum number of aligned sequences to keep. Default = '1'

=item B<-e, --evalue>

Expectation value (E) threshold for saving hits. Default = '1e-05'
 
=item B<--h_rt>
 
Per job hours runtime in hh:mm:ss. Default = '4:00:00'

=back

=head1 DESCRIPTION

B<OUTPUT DETAILS:>

Script requires write permissions in the directory your original fasta is. For more detailed tutorial see: https://github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison/blob/master/KSU_bioinfo_lab/Blastx/Blastx_LAB.md

B<Test with sample datasets:>
 
git clone https://github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison

mkdir test_blastx
 
cd test_blastx
 
ln -s /homes/bioinfo/pipeline_datasets/Blastx/* ~/test_blastx/

perl ~/RNA-Seq-annotation-and-comparison/KSU_bioinfo_lab/Blastx/Blastx.pl -m 10 -f ~/test_blastx/CDH_clustermergedAssembly_cell_line_33.fa
 

=cut

