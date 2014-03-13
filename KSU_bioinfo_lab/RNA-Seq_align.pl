#!/bin/perl
###############################################################################
#   
#	USAGE: perl RNA-Seq_align.pl [options]
#
#  Created by jennifer shelton
#
###############################################################################
use strict;
use warnings;
use File::Basename; # enable manipulating of the full path
use Cwd;
# use List::Util qw(max);
# use List::Util qw(sum);
# use Bio::SeqIO;
# use Bio::Seq;
# use Bio::DB::Fasta;
use Getopt::Long;
use Pod::Usage;
###############################################################################
##############         Print informative message             ##################
###############################################################################
print "###########################################################\n";
print "#  RNA-Seq_align.pl                                       #\n";
print "#                                                         #\n";
print "#  Created by Jennifer Shelton 12/  /14                   #\n";
print "#  github.com/i5K-KINBRE-script-share                     #\n";
print "#  perl RNA-Seq_align.pl -help # for usage/options        #\n";
print "#  perl RNA-Seq_align.pl -man # for more details          #\n";
print "###########################################################\n";
###############################################################################
##############                get arguments                  ##################
###############################################################################
my ($r_list,$project_name,$transcriptome);
my $convert_header = 0;
my $mapq = 10;
my $man = 0;
my $help = 0;
GetOptions (
			  'help|?' => \$help, 
			  'man' => \$man,
			  'r|r_list:s' => \$r_list,
			  't|transcriptome:s' => \$transcriptome,
              'p|project_name:s' => \$project_name,
			  'c|convert_header' => \$convert_header,
			  'm|mapq:i' => \$mapq

              )  
or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;
my $dirname = dirname(__FILE__); # github directories (all github directories must be in the same directory)
my $home = getcwd; # working directory (this is where output files will be printed)
###############################################################################
############## Create array of the sample names and read files    #############
###############################################################################
my @reads;
open (READ_LIST, '<', $r_list) or die "Can't open $r_list!\n";
while (<READ_LIST>)
{
    chomp;
    push @reads , [split];
}
###############################################################################
##############     Write scripts for each sample             ##################
###############################################################################
for my $samples (@reads)
{
    my @r1 = split(',',$samples->[1]); # get list of forward reads
    my @r2 = split(',',$samples->[2]); # get list of reverse reads
    if (scalar(@r1) != scalar(@r2))
    {
        print "Error the number of forward and reverse read files does not match for sample $samples->[0]!\n"; # each forward file must have a corresponding reverse file
        exit;
    }
    #######################################################################
    ############ Convert headers of illumina paired-end data ##############
    #######################################################################
    mkdir "${home}${project_name}_scripts";
    mkdir "${home}${project_name}_qsubs";
    mkdir "${home}${project_name}_prinseq";
    open (QSUBS_CLEAN, '>', "${home}${project_name}_qsubs/${project_name}_qsubs_clean.txt") or die "Can't open ${home}${project_name}_qsubs/${project_name}_qsubs_clean.txt!\n";
    open (QSUBS_MAP, '>', "${home}${project_name}_qsubs/${project_name}_qsubs_map.txt") or die "Can't open ${home}${project_name}_qsubs/${project_name}_qsubs_map.txt!\n";
    for my $file (0..$#r1)
    {
        my (${filename}, ${directories}, ${suffix}) = fileparse($r1[$file],'\..*'); # break appart filenames
        my (${filename2}, ${directories2}, ${suffix2}) = fileparse($r2[$file],'\..*'); # break appart filenames
        open (SCRIPT, '>', "${home}${project_name}_scripts/${filename}_clean.sh") or die "Can't open ${home}${project_name}_scripts/${filename}_clean.sh!\n"; # create a shell script for each read-pair set
        print SCRIPT '#!/bin/bash';
        print SCRIPT "\n";
        if ($convert_header)
        {
            print SCRIPT "#######################################################################\n############ Convert headers of illumina paired-end data ##############\n#######################################################################\n";
                print SCRIPT "cat $r1[$file] | awk \'{if (NR % 4 == 1) {split(\$1, arr, \":\"); printf \"%s_%s:%s:%s:%s:%s#0/%s\\n\", arr[1], arr[3], arr[4], arr[5], arr[6], arr[7], substr(\$2, 1, 1), \$0} else if (NR % 4 == 3){print \"+\"} else {print \$0} }\' ${directories}${filename}_h.fastq\n";
                $r1[$file] = "${directories}${filename}_header.fastq";
                print SCRIPT "Convert headers of illumina paired-end data\n";
                print SCRIPT "cat $r2[$file] | awk \'{if (NR % 4 == 1) {split(\$1, arr, \":\"); printf \"%s_%s:%s:%s:%s:%s#0/%s\\n\", arr[1], arr[3], arr[4], arr[5], arr[6], arr[7], substr(\$2, 1, 1), \$0} else if (NR % 4 == 3){print \"+\"} else {print \$0} }\' ${directories}${filename}_h.fastq\n";
                $r2[$file] = "${directories}${filename}_header.fastq";
            
        }
        #######################################################################
        ######### Clean reads for low quality without de-duplicating ##########
        #######################################################################
        print SCRIPT "#######################################################################\n ######### Clean reads for low quality without de-duplicating ##########\n#######################################################################\n";
        print QSUBS_CLEAN "qsub -l h_rt=48:00:00,mem=40G ${home}${project_name}_scripts/${filename}_clean.sh\n";
        print SCRIPT "perl /homes/sheltonj/abjc/prinseq-lite-0.20.3/prinseq-lite.pl -verbose -fastq  $r1[$file] -fastq2  $r2[$file]-out_good null -graph_data ${home}${project_name}_prinseq/${filename}_raw.gd -out_bad null\n";
        print SCRIPT "perl /homes/sheltonj/abjc/prinseq-lite-0.20.3/prinseq-lite.pl -verbose -fastq  $r1[$file] -fastq2  $r2[$file] -min_len 90 -min_qual_mean 25 -trim_qual_type mean -trim_qual_rule lt -trim_qual_window 2 -trim_qual_step 1 -trim_qual_left 20 -trim_qual_right 20 -ns_max_p 1 -trim_ns_left 5 -trim_ns_right 5 -lc_method entropy -lc_threshold 70 -out_format 3  -no_qual_header -log ${filename}_paired.log\ -graph_data ${home}${project_name}_prinseq/${filename}_cleaned.gd\n";

        
        #######################################################################
        ######### Map reads to de novo transcriptome using Bowtie2   ##########
        #######################################################################
        print SCRIPT "#######################################################################\n ######### Map reads to de novo transcriptome using Bowtie2   ##########\n#######################################################################\n";
#        my $insert size =160;
#        print QSUBS_MAP "qsub -l h_rt=48:00:00,mem=2G -pe single 20 ${home}${project_name}_scripts/${filename}_map.sh\n";
    }
}

#            print ARRAY_CONTENTS join("\t", @cols_for_row), "\n";

print "done\n";
###############################################################################
##############                  Documentation                ##################
###############################################################################
## style adapted from http://www.perlmonks.org/?node_id=489861 
__END__

=head1 NAME

RNA-Seq_align.pl - a package of scripts that ...

=head1 USAGE

perl RNA-Seq_align.pl [options]

 Documentation options:
   -help    brief help message
   -man	    full documentation
 Required options:
   -r	     reference CMAP
 Filtering options:
   --s_algn	 second minimum % of possible alignment   
   
=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the more detailed manual page with output details and examples and exits.

=item B<-r, --r_list>

The filename of the user provided list of read files and labels. Each line should be tab separated with the sample label (no spaces), then the first read file, then the second read file.

=item B<-t, --transcriptome>
 
The filename of the user provided de novo transcriptome assembly.

=item B<-p, --project_name>

The name of the project (no spaces). This will be used in filenaming.
 
=item B<-c, --convert_header>
 
If the illumina headers do not end in /1 or /2 use this parameter to indicat that headers need to be converted.
 
=item B<-m, --mapq>
 
The minimum MAPQ. Alignments with less than a 1 in 10 chance of
 actually being the correct alignment are filtered out by
 default. This is a minimum MAPQ of 10.

=back

=head1 DESCRIPTION

B<OUTPUT DETAILS:>

This appears when the manual is viewed!!!!

B<Test with sample datasets:>


perl RNA-Seq_align.pl -r sample_data/sample.r.cmap --s_algn .9

=cut