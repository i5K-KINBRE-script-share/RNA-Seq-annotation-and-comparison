#!/usr/bin/perl
##################################################################################
#
# USAGE: perl tBlastx.pl [FASTA filename]
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
print "#  tBlastx.pl Version 1.0                                 #\n";
print "#                                                         #\n";
print "#  Created by Jennifer Shelton 08/19/14                   #\n";
print "#  github.com/i5K-KINBRE-script-share                     #\n";
print "#  perl tBlastx.pl -help # for usage/options              #\n";
print "#  perl tBlastx.pl -man # for more details                #\n";
print "###########################################################\n";
###############################################################################
##############                get arguments                  ##################
###############################################################################

my $email;
my $max_target_seqs = 100;
my $evalue = 10;
my $h_rt = '6:00:00';
my ($input_fasta_list,$input_fasta);
my $man = 0;
my $help = 0;
GetOptions (
        'help|?' => \$help,
        'man' => \$man,
        'f|input_fasta_list:s' => \$input_fasta_list,
        't|max_target_seqs:i' => \$max_target_seqs,
        'e|evalue:s' => \$evalue,
        'h_rt:s' => \$h_rt,
        'm|email:s' => \$email,
)
or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;
sub quote { qq!"$_[0]"! } ## interpolate slurped text
my $dirname = dirname(__FILE__); # github directories (all github directories must be in the same directory)
##################################################################################
##############               get fullpath fasta                 ##################
##################################################################################
open (LIST, "<", $input_fasta) or die "can't open $input_fasta: $!";
while (<LIST>)
{
    chomp;
    my (${filename}, ${directories}, ${suffix}) = fileparse($_,'\..*');
    my $script_file = "${directories}${filename}_tblastx.sh";
    my $tab_out = "${directories}${filename}_tblastx.txt";
    open (SCRIPT, ">", $script_file) or die "Can't open $script_file: $!";
    my $text_out = read_file("${dirname}/tBlastx_template.txt"); ## read shell template with slurp

    print SCRIPT eval quote($text_out);
    print SCRIPT "\n";
    close (SCRIPT);

    my $qsub =`qsub -l mem=1G,h_rt=${h_rt} -pe single 16 -m abe -M ${email} ${script_file}`;
    #print "qsub -l mem=1G,h_rt=${h_rt} -pe single 16 -m abe -M ${email} ${script_file}\n";
    print "$qsub\n";
}
print "Done\n";
##################################################################################
##############                  Documentation                   ##################
##################################################################################
## style adapted from http://www.perlmonks.org/?node_id=489861
__END__

=head1 NAME

tBlastx.pl - Script outputs fasta records split into files of 100 or less sequences in a directory called split. It also creates blastx bash scripts and qsub commands to annotate a de novo transcriptome with hits to the nr protein database.
 
File names should not include spaces.

=head1 USAGE

perl tBlastx.pl [options]

Documentation options:
    -help    brief help message
    -man	    full documentation
Required parameters:
    -f	    list of fastas to annotate with blastx
    -e	    email address 
Optional parameters:
    -t	     maximum sequences to report alignments for
    -e	     e-value
    --h_rt	 hours runtime in hh:mm:ss
 
=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the more detailed manual page with output details and examples and exits.
 
=item B<-f, --input_fasta>
 
The full path to a plain text file (e.g. created in a text editor like notepad++ or textwrangler etc rather than Word, notepad, etc.). Each line of the file sould be the fullpath for the fasta file of assembled transcripts. These will be blasted against the "nt" database.

=item B<-e, --evalue>
 
The expect value for tblastx (default = 10)

=item B<-t, --max_target_seqs>
 
The max target sequences for tblastx (default = 100)

=item B<-h, --h_rt>
 
The hours of runtime allowed for tblastx on Beocat (default = 6:00)


=back

=head1 DESCRIPTION

B<OUTPUT DETAILS:>

Script requires writes code to run tblastx on Beocat then submits the job.  

=cut
