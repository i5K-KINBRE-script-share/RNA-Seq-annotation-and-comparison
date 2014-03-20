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
print "#  Created by Jennifer Shelton 3/15/14                    #\n";
print "#  github.com/i5K-KINBRE-script-share                     #\n";
print "#  perl RNA-Seq_align.pl -help # for usage/options        #\n";
print "#  perl RNA-Seq_align.pl -man # for more details          #\n";
print "###########################################################\n";
###############################################################################
##############                get arguments                  ##################
###############################################################################
my ($r_list,$project_name,$transcriptome,$clean_read_file1,$clean_read_file2,@clean_r1,@clean_r2,$labels,$sams,$clean_read_singletons,$out_dir);
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
mkdir "${home}/${project_name}_scripts";
mkdir "${home}/${project_name}_qsubs";
mkdir "${home}/${project_name}_prinseq";
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
#######################################################################
#########     Index the de novo transcriptome for Bowtie2    ##########
#######################################################################
close (SCRIPT);
open (SCRIPT, '>', "${home}/${project_name}_scripts/${project_name}_index.sh") or die "Can't open ${home}/${project_name}_scripts/${project_name}_index.sh!\n"; # create a shell script for each read-pair set
open (QSUBS_INDEX, '>', "${home}/${project_name}_qsubs/${project_name}_qsubs_index.sh") or die "Can't open ${home}/${project_name}_qsubs/${project_name}_qsubs_index.sh!\n";
print QSUBS_INDEX '#!/bin/bash';
print QSUBS_INDEX "\n";
print SCRIPT '#!/bin/bash';
print SCRIPT "\n";
print SCRIPT "#######################################################################\n#########     Index the de novo transcriptome for Bowtie2    ##########\n#######################################################################\n";
$dirname =~ /(.*)\/RNA-Seq-annotation-and-comparison\/KSU_bioinfo_lab/;
my $git_dir = $1;
print "GITDIR: $git_dir\n";
print SCRIPT "perl ${git_dir}/read-cleaning-format-conversion/KSU_bioinfo_lab/filter_by_length.pl $transcriptome
# remove sequences shorer than 200bp from the reference transcriptome\n";
my (${trans_filename}, ${trans_directories}, ${trans_suffix}) = fileparse($transcriptome,'\..*'); # break appart filenames
print SCRIPT "/homes/bioinfo/bioinfo_software/bowtie2-2.1.0/bowtie2-build ${trans_directories}${trans_filename}_gt_200.fasta ${trans_directories}${trans_filename}_gt_200\n";
my $index="${trans_directories}${trans_filename}_gt_200";
print QSUBS_INDEX "qsub -l mem=10G,h_rt=10:00:00 ${home}/${project_name}_scripts/${project_name}_index.sh\n";
close (SCRIPT);
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
    open (QSUBS_CLEAN, '>', "${home}/${project_name}_qsubs/${project_name}_qsubs_clean.sh") or die "Can't open ${home}/${project_name}_qsubs/${project_name}_qsubs_clean.sh!\n";
    print QSUBS_CLEAN '#!/bin/bash';
    print QSUBS_CLEAN "\n";
    open (QSUBS_MAP, '>', "${home}/${project_name}_qsubs/${project_name}_qsubs_map.sh") or die "Can't open ${home}/${project_name}_qsubs/${project_name}_qsubs_map.sh!\n";
    print QSUBS_MAP '#!/bin/bash';
    print QSUBS_MAP "\n";
    for my $file (0..$#r1)
    {
        my (${filename}, ${directories}, ${suffix}) = fileparse($r1[$file],'\..*'); # break appart filenames
        my (${filename2}, ${directories2}, ${suffix2}) = fileparse($r2[$file],'\..*'); # break appart filenames
        $out_dir = ${directories};
        open (SCRIPT, '>', "${home}/${project_name}_scripts/${filename}_clean.sh") or die "Can't open ${home}/${project_name}_scripts/${filename}_clean.sh!\n"; # create a shell script for each read-pair set
        print SCRIPT '#!/bin/bash';
        print SCRIPT "\n";
        if ($convert_header)
        {
            print SCRIPT "#######################################################################\n############ Convert headers of illumina paired-end data ##############\n#######################################################################\n";
                print SCRIPT "cat $r1[$file] | awk \'{if (NR % 4 == 1) {split(\$1, arr, \":\"); printf \"%s_%s:%s:%s:%s:%s#0/%s\\n\", arr[1], arr[3], arr[4], arr[5], arr[6], arr[7], substr(\$2, 1, 1), \$0} else if (NR % 4 == 3){print \"+\"} else {print \$0} }\' > ${directories}${filename}_header.fastq\n";
                $r1[$file] = "${directories}${filename}_header.fastq";
                print SCRIPT "cat $r2[$file] | awk \'{if (NR % 4 == 1) {split(\$1, arr, \":\"); printf \"%s_%s:%s:%s:%s:%s#0/%s\\n\", arr[1], arr[3], arr[4], arr[5], arr[6], arr[7], substr(\$2, 1, 1), \$0} else if (NR % 4 == 3){print \"+\"} else {print \$0} }\' > ${directories}${filename2}_header.fastq\n";
                $r2[$file] = "${directories}${filename2}_header.fastq";
            
        }
        #######################################################################
        ######### Clean reads for low quality without de-duplicating ##########
        #######################################################################
        print SCRIPT "#######################################################################\n######### Clean reads for low quality without de-duplicating ##########\n#######################################################################\n";
        print QSUBS_CLEAN "qsub -l h_rt=48:00:00,mem=10G ${home}/${project_name}_scripts/${filename}_clean.sh\n";
        print SCRIPT "perl /homes/sheltonj/abjc/prinseq-lite-0.20.3/prinseq-lite.pl -verbose -fastq $r1[$file] -fastq2 $r2[$file] -min_len 90 -min_qual_mean 25 -trim_qual_type mean -trim_qual_rule lt -trim_qual_window 2 -trim_qual_step 1 -trim_qual_left 20 -trim_qual_right 20 -ns_max_p 1 -trim_ns_left 5 -trim_ns_right 5 -lc_method entropy -lc_threshold 70 -out_format 3 -no_qual_header -log ${home}/${project_name}_prinseq/${filename}_paired.log\ -graph_data ${home}/${project_name}_prinseq/${filename}_raw.gd -out_good ${directories}${filename}_good -out_bad ${directories}${filename}_bad\n";
        print SCRIPT "perl /homes/sheltonj/abjc/prinseq-lite-0.20.3/prinseq-lite.pl -verbose -fastq ${directories}${filename}_good_1.fastq -fastq2 ${directories}${filename}_good_2.fastq -out_good null -graph_data ${home}/${project_name}_prinseq/${filename}_cleaned.gd -out_bad null\n";
        print SCRIPT "perl /homes/sheltonj/abjc/prinseq-lite-0.20.3/prinseq-lite.pl -verbose -fastq ${directories}${filename}_good_1_singletons.fastq -out_good null -graph_data ${home}/${project_name}_prinseq/${filename}_cleaned_1_singletons.gd -out_bad null\n";
        print SCRIPT "perl /homes/sheltonj/abjc/prinseq-lite-0.20.3/prinseq-lite.pl -verbose -fastq ${directories}${filename}_good_2_singletons.fastq -out_good null -graph_data ${home}/${project_name}_prinseq/${filename}_cleaned_2_singletons.gd -out_bad null\n";
        if ($clean_read_file1)
        {
            $clean_read_file1 = "$clean_read_file1"." ${directories}${filename}_good_1.fastq";
            $clean_read_file2 = "$clean_read_file2"." ${directories}${filename}_good_2.fastq";
            $clean_read_singletons = "$clean_read_singletons". " ${directories}${filename}_good_1_singletons.fastq ${directories}${filename}_good_2_singletons.fastq";
        }
        else
        {
            $clean_read_file1 = " ${directories}${filename}_good_1.fastq";
            $clean_read_file2 = " ${directories}${filename}_good_2.fastq";
            $clean_read_singletons = " ${directories}${filename}_good_1_singletons.fastq ${directories}${filename}_good_2_singletons.fastq";
        }
    }
    #######################################################################
    ######### Map reads to de novo transcriptome using Bowtie2   ##########
    #######################################################################
    close (SCRIPT);
    open (SCRIPT, '>', "${home}/${project_name}_scripts/$samples->[0]_map.sh") or die "Can't open ${home}/${project_name}_scripts/$samples->[0]_map.sh!\n"; # create a shell script for each read-pair set
    open (QSUBS_MAP, '>', "${home}/${project_name}_qsubs/${project_name}_qsubs_map.sh") or die "Can't open ${home}/${project_name}_qsubs/${project_name}_qsubs_map.sh!\n";
    print QSUBS_MAP '#!/bin/bash';
    print QSUBS_MAP "\n";
    print SCRIPT '#!/bin/bash';
    print SCRIPT "\n";
    print SCRIPT "#######################################################################\n######### Map reads to de novo transcriptome using Bowtie2   ##########\n#######################################################################\n";
    print SCRIPT "cat$clean_read_file1 > ${out_dir}$samples->[0]_good_1.fastq # concatenate single fasta\n";
    print SCRIPT "cat$clean_read_file2 > ${out_dir}$samples->[0]_good_2.fastq # concatenate single fasta\n";
    print SCRIPT "cat$clean_read_singletons > ${out_dir}$samples->[0]_good_singletons.fastq # concatenate single fasta\n";
    print SCRIPT "/homes/bioinfo/bioinfo_software/bowtie2-2.1.0/bowtie2 -p 20 --fr -q -x $index -1 ${out_dir}$samples->[0]_good_1.fastq -2 ${out_dir}$samples->[0]_good_2.fastq -U ${out_dir}$samples->[0]_good_singletons.fastq -S ${out_dir}$samples->[0]_200.sam\n";
    if ($labels)
    {
        $sams = "$sams".",${out_dir}$samples->[0]_200.sam";
        $labels  = "$labels".",$samples->[0]";
    }
    else
    {
        $sams = "${out_dir}$samples->[0]_200.sam";
        $labels  = "$samples->[0]";
    }
    print QSUBS_MAP "qsub -l h_rt=48:00:00,mem=2G -pe single 20 ${home}/${project_name}_scripts/$samples->[0]_map.sh\n";
    
}
#######################################################################
#########                Summarize read counts               ##########
#######################################################################
close (SCRIPT);
open (SCRIPT, '>', "${home}/${project_name}_scripts/${project_name}_count.sh") or die "Can't open ${home}/${project_name}_scripts/${project_name}_count.sh!\n"; # create a shell script
open (QSUBS_COUNT, '>', "${home}/${project_name}_qsubs/${project_name}_qsubs_count.sh") or die "Can't open ${home}/${project_name}_qsubs/${project_name}_qsubs_count.sh!\n";
print QSUBS_COUNT '#!/bin/bash';
print QSUBS_COUNT "\n";
print SCRIPT '#!/bin/bash';
print SCRIPT "\n";
print SCRIPT "#######################################################################\n#########                Summarize read counts               ##########\n#######################################################################\n";
print SCRIPT "perl ${dirname}/Count_reads_denovo/Count_reads_denovo.pl -s $sams -l $labels -m $mapq -o ${out_dir}${project_name}_read_counts.txt\n";
print QSUBS_COUNT "qsub -l h_rt=8:00:00 ${home}/${project_name}_scripts/${project_name}_count.sh\n";   
print "done\n";
###############################################################################
##############                  Documentation                ##################
###############################################################################
## style adapted from http://www.perlmonks.org/?node_id=489861 
__END__

=head1 SYNOPSIS

RNA-Seq_align.pl - The script writes scripts and qsubs to generate count summaries for illumina paired end reads after mapping against a de novo transcriptome. The script 1) converts illumina headers if the "-c" parameter is used, 2) cleans raw reads using Prinseq http://prinseq.sourceforge.net/manual.html, 3) creates a filtered transcriptome fasta file with putative transcripts less than 200 bp long removed and then indexes this transcriptome for mapping, 4) reads are then mapped to the length filtered de novo transcriptome using Bowtie2 in the best mapping default mode, read more about Bowtie2 at http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml, 5) count summaries are generated as a tab separated list where the first row is the sample ids and the first column is the name of the contig and the other values are the read counts per sample, see https://github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison/tree/master/KSU_bioinfo_lab/Count_reads_denovo for details on how reads are summarized.
 
For examples parameter details run "perl RNA-Seq_align.pl -man". 

=head1 USAGE

perl RNA-Seq_align.pl [options]

 Documentation options:
   -help    brief help message
   -man	    full documentation
 Required options:
   -r	     filename for file with tab separated list of sample labels and fastq files
   -t	     filename of the de novo transcriptome
   -p	     project name (no spaces)
 Filtering options:
   -m	     minimum mapq
 Fastq format options:
   -c	     convert fastq headers
    

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits. 

=item B<-man>

Prints the more detailed manual page with output details and examples and exits.
 
=item B<-r, --r_list>

The filename of the user provided list of read files and labels. Each line should be tab separated with the sample label (no spaces), then the first read file, then the second read file. Example:
sample_1   sample_data/sample_1_R1.fastq   sample_data/sample_1_R2.fastq
sample_2   sample_data/sample_2_R1.fastq   sample_data/sample_2_R2.fastq

=item B<-t, --transcriptome>
 
The filename of the user provided de novo transcriptome assembly.

=item B<-p, --project_name>

The name of the project (no spaces). This will be used in filenaming.
 
=item B<-c, --convert_header>
 
If the illumina headers do not end in /1 or /2 use this parameter to indicat that headers need to be converted. Check your headers by typing "head [fasta filename]" and read more about illumina headers at http://en.wikipedia.org/wiki/Fastq#Illumina_sequence_identifiers.
 
=item B<-m, --mapq>
 
The minimum MAPQ. Alignments with less than a 1 in 10 chance of
 actually being the correct alignment are filtered out by
 default. This is a minimum MAPQ of 10.

=back

=head1 DESCRIPTION

B<RUN DETAILS:>

 The script writes scripts and qsubs to generate count summaries for illumina paired end reads after mapping against a de novo transcriptome. The script 
 
 1) converts illumina headers if the "-c" parameter is used
 2) cleans raw reads using Prinseq http://prinseq.sourceforge.net/manual.html. Prinseq parameters can be customized by editing line 126. Prinseq parameters in detail: 
    -min_len 90
    -min_qual_mean 25
    -trim_qual_type mean
    -trim_qual_rule lt
    -trim_qual_window 2
    -trim_qual_step 1
    -trim_qual_left 20
    -trim_qual_right 20
    -ns_max_p 1
    -trim_ns_left 5
    -trim_ns_right 5
    -lc_method entropy
    -lc_threshold 70

 3) creates a filtered transcriptome fasta file with putative transcripts less than 200 bp long removed and then indexes this transcriptome for mapping
 4) reads are then mapped to the length filtered de novo transcriptome using Bowtie2 in the best mapping default mode, read more about Bowtie2 at http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml
 5) count summaries are generated as a tab separated list where the first row is the sample ids and the first column is the name of the contig and the other values are the read counts per sample, see https://github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison/tree/master/KSU_bioinfo_lab/Count_reads_denovo for details on how reads are summarized. This file can be used as input for DeSeq or EdgeR.

B<Test with sample datasets:>
 
 # log into Beocat

 git clone https://github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison
 
 git clone https://github.com/i5K-KINBRE-script-share/read-cleaning-format-conversion

 perl RNA-Seq_align.pl -r sample_data/sample.txt -t sample_data/sample_transcriptome.fasta -p test -c
 bash test_qsubs_clean.sh
 ## When these jobs are complete go to next step. Test completion by typing "status" in a Beocat session.
 ## download the ".gd" files in the Project_name_prinseq directory and upload them to http://edwards.sdsu.edu/cgi-bin/prinseq/prinseq.cgi?report=1 to evaluate read quality pre and post cleaning
 bash test_qsubs_index.sh
 ## When these jobs are complete go to next step. Test completion by typing "status" in a Beocat session.
 bash test_qsubs_map.sh
 ## When these jobs are complete go to next step. Test completion by typing "status" in a Beocat session.
 bash test_qsubs_count.sh
 
 

=cut