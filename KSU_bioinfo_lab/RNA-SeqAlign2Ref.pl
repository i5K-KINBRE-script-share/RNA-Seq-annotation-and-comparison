#!/bin/perl
###############################################################################
#
#	USAGE: perl RNA-SeqAlign2Ref.pl [options]
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
print "#  RNA-SeqAlign2Ref.pl                                    #\n";
print "#                                                         #\n";
print "#  Created by Jennifer Shelton 3/15/14                    #\n";
print "#  github.com/i5K-KINBRE-script-share                     #\n";
print "#  perl RNA-SeqAlign2Ref.pl -help # for usage/options     #\n";
print "#  perl RNA-SeqAlign2Ref.pl -man # for more details       #\n";
print "###########################################################\n";
###############################################################################
##############                get arguments                  ##################
###############################################################################
my ($r_list,$project_name,$genome,$clean_read_file1,$clean_read_file2,@clean_r1,@clean_r2,$clean_read_singletons,$out_dir,$gtf);
my $pe='paired'; # paired for paired, single for single, default paired
my %bams;
my $convert_header = 0;
my $min_len=40;
my $man = 0;
my $help = 0;
GetOptions (
'help|?' => \$help,
'man' => \$man,
'r|r_list:s' => \$r_list,
'f|genome_fasta:s' => \$genome,
'p|project_name:s' => \$project_name,
'c|convert_header' => \$convert_header,
'g|GTF_GFF:s' => \$gtf,
'l|min_len:s' => \$min_len,
'pe' => \$paired_or_single
)
or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;
my $dirname = dirname(__FILE__); # github directories (all github directories must be in the same directory)
my $home = getcwd; # working directory (this is where output files will be printed)
print "HOME = $home\n";
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
    
    #If they are paired, use split, if not, do not
    if ($paired_or_single eq 'paired'){
    	push @reads , [split];
    }
    elsif ($paired_or_single eq 'single'){
    	push @reads;
    }
}
#######################################################################
#########             Build Bowtie2 genome index             ##########
#######################################################################
close (SCRIPT);
open (SCRIPT, '>', "${home}/${project_name}_scripts/${project_name}_index.sh") or die "Can't open ${home}/${project_name}_scripts/${project_name}_index.sh!\n"; # create a shell script for each read-pair set
open (QSUBS_INDEX, '>', "${home}/${project_name}_qsubs/${project_name}_qsubs_index.sh") or die "Can't open ${home}/${project_name}_qsubs/${project_name}_qsubs_index.sh!\n";
print QSUBS_INDEX '#!/bin/bash';
print QSUBS_INDEX "\n";
print SCRIPT '#!/bin/bash';
print SCRIPT "\n";
print SCRIPT "#######################################################################\n#########             Build Bowtie2 genome index             ##########\n#######################################################################\n";
$dirname =~ /(.*)\/RNA-Seq-annotation-and-comparison\/KSU_bioinfo_lab/;
my $git_dir = $1;
print "GITDIR: $git_dir\n";
my (${genome_filename}, ${genome_directories}, ${genome_suffix}) = fileparse($genome,'\..*'); # break appart filenames
print SCRIPT "/homes/bioinfo/bioinfo_software/bowtie2-2.1.0/bowtie2-build ${genome_directories}${genome_filename}.fasta ${genome_directories}${genome_filename}\n";
my $index="${genome_directories}${genome_filename}";
print QSUBS_INDEX "qsub -l mem=10G,h_rt=10:00:00 ${home}/${project_name}_scripts/${project_name}_index.sh\n";
close (SCRIPT);
###############################################################################
##############     Write scripts for each sample             ##################
###############################################################################
my $old_count = 0;
my $new_count = 0;
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
    open (QSUBS_CLEAN, '>>', "${home}/${project_name}_qsubs/${project_name}_qsubs_clean.sh") or die "Can't open ${home}/${project_name}_qsubs/${project_name}_qsubs_clean.sh!\n";
    print QSUBS_CLEAN '#!/bin/bash';
    print QSUBS_CLEAN "\n";
    open (QSUBS_MAP, '>>', "${home}/${project_name}_qsubs/${project_name}_qsubs_map.sh") or die "Can't open ${home}/${project_name}_qsubs/${project_name}_qsubs_map.sh!\n";
    print QSUBS_MAP '#!/bin/bash';
    print QSUBS_MAP "\n";
    for my $file (0..$#r1)
    {
        my (${filename}, ${directories}, ${suffix}) = fileparse($r1[$file],'\..*'); # break appart filenames
        my (${filename2}, ${directories2}, ${suffix2}) = fileparse($r2[$file],'\..*'); # break appart filenames
        $out_dir = ${directories};
        print "OUT_DIR = $out_dir\n";
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
        print SCRIPT "perl /homes/sheltonj/abjc/prinseq-lite-0.20.3/prinseq-lite.pl -verbose -fastq $r1[$file] -fastq2 $r2[$file] -min_len $min_len -min_qual_mean 25 -trim_qual_type mean -trim_qual_rule lt -trim_qual_window 2 -trim_qual_step 1 -trim_qual_left 20 -trim_qual_right 20 -ns_max_p 1 -trim_ns_left 5 -trim_ns_right 5 -lc_method entropy -lc_threshold 70 -out_format 3 -no_qual_header -log ${home}/${project_name}_prinseq/${filename}_paired.log\ -graph_data ${home}/${project_name}_prinseq/${filename}_raw.gd -out_good ${home}/${filename}_good -out_bad ${home}/${filename}_bad\n";
        print SCRIPT "perl /homes/sheltonj/abjc/prinseq-lite-0.20.3/prinseq-lite.pl -verbose -fastq ${home}/${filename}_good_1.fastq -fastq2 ${home}/${filename}_good_2.fastq -out_good null -graph_data ${home}/${project_name}_prinseq/${filename}_cleaned.gd -out_bad null\n";
        print SCRIPT "perl /homes/sheltonj/abjc/prinseq-lite-0.20.3/prinseq-lite.pl -verbose -fastq ${home}/${filename}_good_1_singletons.fastq -out_good null -graph_data ${home}/${project_name}_prinseq/${filename}_cleaned_1_singletons.gd -out_bad null\n";
        print SCRIPT "perl /homes/sheltonj/abjc/prinseq-lite-0.20.3/prinseq-lite.pl -verbose -fastq ${home}/${filename}_good_2_singletons.fastq -out_good null -graph_data ${home}/${project_name}_prinseq/${filename}_cleaned_2_singletons.gd -out_bad null\n";
        if ($old_count != $new_count)
        {
            $clean_read_file1 = '';
            $clean_read_file2 = '';
            $clean_read_singletons = '';
        }
        if ($clean_read_file1)
        {
            $clean_read_file1 = "$clean_read_file1"." ${home}/${filename}_good_1.fastq";
            $clean_read_file2 = "$clean_read_file2"." ${home}/${filename}_good_2.fastq";
            $clean_read_singletons = "$clean_read_singletons". " ${home}/${filename}_good_1_singletons.fastq ${home}/${filename}_good_2_singletons.fastq";
        }
        else
        {
            $clean_read_file1 = " ${home}/${filename}_good_1.fastq";
            $clean_read_file2 = " ${home}/${filename}_good_2.fastq";
            $clean_read_singletons = " ${home}/${filename}_good_1_singletons.fastq ${home}/${filename}_good_2_singletons.fastq";
        }
    }
    $old_count=$new_count;
    ++$new_count;
    #######################################################################
    ######### Align the RNA-seq reads to the genome with Tophat2 ##########
    #####  Assemble expressed genes and transcripts with Cufflinks2 #######
    #######################################################################
    close (SCRIPT);
    open (SCRIPT, '>', "${home}/${project_name}_scripts/$samples->[0]_map.sh") or die "Can't open ${home}/${project_name}_scripts/$samples->[0]_map.sh!\n"; # create a shell script for each read-pair set
    open (QSUBS_MAP, '>>', "${home}/${project_name}_qsubs/${project_name}_qsubs_map.sh") or die "Can't open ${home}/${project_name}_qsubs/${project_name}_qsubs_map.sh!\n";
    print QSUBS_MAP '#!/bin/bash';
    print QSUBS_MAP "\n";
    print SCRIPT "#!/bin/bash\n";
    print SCRIPT "export PATH=\$PATH:/homes/bjsco/bin\n";
    print SCRIPT "#######################################################################\n######### Align the RNA-seq reads to the genome with Tophat2 ##########\n#######################################################################\n";
    print SCRIPT "cat$clean_read_file1 > ${home}/$samples->[0]_good_1.fastq # concatenate single fasta\n"; # this and the next two lines merge forwards reads, reverse reads, and singletons respectively into three fastq files
    print SCRIPT "cat$clean_read_file2 > ${home}/$samples->[0]_good_2.fastq # concatenate single fasta\n";
    print SCRIPT "cat$clean_read_singletons > ${home}/$samples->[0]_good_singletons.fastq # concatenate single fasta\n";
    print SCRIPT "mkdir ${home}/$samples->[0]_tophat2_out\n";
    print SCRIPT "/homes/bjsco/bin/tophat2 -p 20 -g 20 -o ${home}/$samples->[0]_tophat2_out -G $gtf $index ${home}/$samples->[0]_good_1.fastq ${home}/$samples->[0]_good_2.fastq,${home}/$samples->[0]_good_singletons.fastq\n"; # map reads with tophat
    print SCRIPT "#######################################################################\n#####  Assemble expressed genes and transcripts with Cufflinks2 #######\n#######################################################################\n";
    print SCRIPT "/homes/bjsco/bin/cufflinks -o ${home}/$samples->[0]_tophat2_out -G $gtf -N  ${home}/$samples->[0]_tophat2_out/accepted_hits.bam\n"; #run cufflinks to assemble each transcript
    open (ASSEMBLED_TRANSCRIPTS, '>>', "${home}/assemblies.txt") or die "can't open ${home}/assemblies.txt: $!"; #create cufflinks assembled transcript gtf list file
    print ASSEMBLED_TRANSCRIPTS "${home}/$samples->[0]_tophat2_out/transcripts.gtf\n";
    
    if ($bams{$samples->[3]})
    {
        $bams{$samples->[3]} = "$bams{$samples->[3]}".",${home}/$samples->[0]_tophat2_out/accepted_hits.bam";
    }
    else
    {
        $bams{$samples->[3]} = "${home}/$samples->[0]_tophat2_out/accepted_hits.bam";
    }
    print QSUBS_MAP "qsub -l h_rt=48:00:00,mem=2G -pe single 20 ${home}/${project_name}_scripts/$samples->[0]_map.sh\n";
    
}
#######################################################################
#####          Merge these assemblies with Cuffmerge            #######
#####  Estimate differential expression with Cuffdiff2          #######
#######################################################################
close (SCRIPT);
open (SCRIPT, '>', "${home}/${project_name}_scripts/${project_name}_merge.sh") or die "Can't open ${home}/${project_name}_scripts/${project_name}_merge.sh!\n"; # create a shell script for the project
open (QSUBS_MERGE, '>', "${home}/${project_name}_qsubs/${project_name}_qsubs_merge.sh") or die "Can't open ${home}/${project_name}_qsubs/${project_name}_qsubs_merge.sh!\n";
print QSUBS_MERGE "#!/bin/bash\n";
print SCRIPT "#!/bin/bash\n";
print SCRIPT "export PATH=\$PATH:/homes/bjsco/cufflinks-2.1.1.Linux_x86_64/cuffmerge\n";
print SCRIPT "export PATH=\$PATH:/homes/bjsco/bin\n";
print SCRIPT "#######################################################################\n#####          Merge these assemblies with Cuffmerge            #######\n#######################################################################\n";
print SCRIPT "mkdir ${home}/merge\n";
print SCRIPT "mkdir ${home}/diff\n";
print SCRIPT "/homes/bjsco/cufflinks-2.1.1.Linux_x86_64/cuffmerge -o ${home}/merge -g $gtf ${home}/assemblies.txt\n";
print SCRIPT "#######################################################################\n#####  Estimate differential expression with Cuffdiff2          #######\n#######################################################################\n";
print SCRIPT "/homes/bjsco/bin/cuffdiff -o ${home}/diff $gtf -L ";
my ($L_final,$bam_final);
for my $treatment_name (keys %bams)
{
    if ($L_final)
    {
        $L_final = "$L_final".",$treatment_name";
        $bam_final = "$bam_final"." $bams{$treatment_name}";
    }
    else
    {
        $L_final = "$treatment_name";
        $bam_final = "$bams{$treatment_name}";
        
    }
}
print SCRIPT "$L_final $bam_final\n";
print QSUBS_MERGE "qsub -l h_rt=24:00:00,mem=4G ${home}/${project_name}_scripts/${project_name}_merge.sh\n";

print "done\n";
###############################################################################
##############                  Documentation                ##################
###############################################################################
## style adapted from http://www.perlmonks.org/?node_id=489861
__END__

=head1 SYNOPSIS
 
RNA-SeqAlign2Ref.pl - The script writes scripts and qsubs to generate count summaries for illumina paired end reads after mapping against a reference genome. The script 1) converts illumina headers if the "-c" parameter is used, 2) cleans raw reads using Prinseq http://prinseq.sourceforge.net/manual.html, 3) index the reference genome for mapping, 4) reads are aligned to the genome with Tophat2 (read more about Tophat2 at http://tophat.cbcb.umd.edu/manual.html) and expressed genes and transcripts are assembled with Cufflinks2, 5) these assemblies are merged with Cuffmerge and differential expression is estimated with Cuffdiff2.
 
 For examples parameter details run "perl RNA-SeqAlign2Ref.pl -man".
 
=head1 USAGE
 
 perl RNA-SeqAlign2Ref.pl [options]
 
 Documentation options:
 -help    brief help message
 -man	    full documentation
 Required options:
 -r	     filename for file with tab separated list of sample labels, fastq files, and treatment labels
 -f	     filename of the reference genome fasta
 -p	     project name (no spaces)
 -g	     filename of the gtf or gff genome annotation
 Filtering options:
 -l	     minimum read length
 Fastq format options:
 -c	     convert fastq headers
 
 
=head1 OPTIONS
 
=over 8
 
=item B<-help>
 
 Print a brief help message and exits.
 
=item B<-man>
 
 Prints the more detailed manual page with output details and examples and exits.
 
=item B<-r, --r_list>
 
 The filename of the user provided list of replicate labels, read files, and treatment labels. Each line should be tab separated with the replicate label (no spaces), then the first read file, then the second read file, then the treatment label (no spaces). Example:
 brain_rep_1	~/test_git/Galaxy4-brain_rep_1_1.fastq	~/test_git/Galaxy5-brain_rep_1_2.fastq	treatment_brain
 adrenal_rep_1	~/test_git/Galaxy2-adrenal_rep_1_1.fastq	~/test_git/Galaxy3-adrenal_rep_1_2.fastq	treatment_adrenal
 brain_rep_2	~/test_git/Galaxy4-brain_rep_2_1.fastq	~/test_git/Galaxy5-brain_rep_2_2.fastq	treatment_brain
 adrenal_rep_2	~/test_git/Galaxy2-adrenal_rep_2_1.fastq	~/test_git/Galaxy3-adrenal_rep_2_2.fastq	treatment_adrenal
 
 If a replicate has more than one set of fastq files (multiple forward and reverse fastq files) list the forward fastq files separated by commas (no spaces) in the same order as the reverse also separated by commas. Each replicate should have all its files listed on the same line of the read file. Example (the first brain and adrenal replicates have two sets of fastq files):
 brain_rep_1	~/test_git/Galaxy4-brain_rep_1_a_1.fastq,~/test_git/Galaxy4-brain_rep_1_b_1.fastq	~/test_git/Galaxy5-brain_rep_1_a_2.fastq,~/test_git/Galaxy5-brain_rep_1_b_2.fastq	treatment_brain
 adrenal_rep_1	~/test_git/Galaxy2-adrenal_rep_1_a_1.fastq,~/test_git/Galaxy2-adrenal_rep_1_b_1.fastq	~/test_git/Galaxy3-adrenal_rep_1_a_2.fastq,~/test_git/Galaxy3-adrenal_rep_1_b_2.fastq	treatment_adrenal
 brain_rep_2	~/test_git/Galaxy4-brain_rep_2_1.fastq	~/test_git/Galaxy5-brain_rep_2_2.fastq	treatment_brain
 adrenal_rep_2	~/test_git/Galaxy2-adrenal_rep_2_1.fastq	~/test_git/Galaxy3-adrenal_rep_2_2.fastq	treatment_adrenal
 
=item B<-f, --genome_fasta>
 
 The filename of the user provided reference genome fasta.
 
=item B<-g, --GTF_GFF>
 
 The filename of the user provided reference genome annotation gtf or gff file.
 
=item B<-p, --project_name>
 
 The name of the project (no spaces). This will be used in filenaming.
 
=item B<-c, --convert_header>
 
 If the illumina headers do not end in /1 or /2 use this parameter to indicat that headers need to be converted. Check your headers by typing "head [fasta filename]" and read more about illumina headers at http://en.wikipedia.org/wiki/Fastq#Illumina_sequence_identifiers.
 
=item B<-l, --min_len>
 
 The minimum read length. Reads shorter than this after cleaning will be discarded. Default minimum length is 40bp.
 
=back
 
=head1 DESCRIPTION
 
B<RUN DETAILS:>
 
 The script writes scripts and qsubs to generate count summaries for illumina paired end reads after mapping against a de novo transcriptome. The script
 
 1) converts illumina headers if the "-c" parameter is used
 2) cleans raw reads using Prinseq http://prinseq.sourceforge.net/manual.html. Prinseq parameters can be customized by editing line 130. Prinseq parameters in detail:
 -min_len 40
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
 
 3) indexes the reference genome for mapping
 4) reads are aligned to the genome with Tophat2 (read more about Tophat2 at http://tophat.cbcb.umd.edu/manual.html) and expressed genes and transcripts are assembled with Cufflinks2 (read more about the Cuffdiff2 alogoritm in their publication http://bioinformaticsk-state.blogspot.com/2013/04/cuffdiff-2-and-isoform-abundance.html)
 5) these assemblies are merged with Cuffmerge and differential expression is estimated with Cuffdiff2
 
B<Test with sample datasets:>
 
 # log into Beocat
 
 ###Step 1: Clone the Git repository
 
 git clone https://github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison
 
 ###Step 2: Create project directory and add your input data to it
 
 Make a working directory.
 
 mkdir test_git
 cd test_git
 
 Create symbolic links to raw reads from the brain and adrenal glands and the hg19 annotation gtf file.
 
 ln -s ~/RNA-Seq-annotation-and-comparison/sample_datasets/* ~/test_git/
 
 Create symbolic links to hg19 fasta file.
 
 ln -s /homes/bioinfo/hg19/hg19.fasta ~/test_git/
 
 ###Step 3: Write tuxedo scripts
 
 Check to see if your fastq headers end in "/1" or "/2" (if they do not you must add the parameter "-c" when you run "RNA-SeqAlign2Ref.pl"
 
 head /homes/bioinfo/test_git/*_1.fastq
 
 Your output will look similar to the output below for the sample data. Because these reads end in "/1" or "/2" we will not add "-c" when we call "RNA-SeqAlign2Ref.pl".
 
 
 ==> /homes/bioinfo/test_git/Galaxy2-adrenal_1.fastq <==
 @ERR030881.107 HWI-BRUNOP16X_0001:2:1:13663:1096#0/1
 ATCTTTTGTGGCTACAGTAAGTTCAATCTGAAGTCAAAACCAACCAATTT
 +
 5.544,444344555CC?CAEF@EEFFFFFFFFFFFFFFFFFEFFFEFFF
 @ERR030881.311 HWI-BRUNOP16X_0001:2:1:18330:1130#0/1
 TCCATACATAGGCCTCGGGGTGGGGGAGTCAGAAGCCCCCAGACCCTGTG
 +
 GFFFGFFBFCHHHHHHHHHHIHEEE@@@=GHGHHHHHHHHHHHHHHHHHH
 @ERR030881.1487 HWI-BRUNOP16X_0001:2:1:4144:1420#0/1
 GTATAACGCTAGACACAGCGGAGCTCGGGATTGGCTAAACTCCCATAGTA
 
 ==> /homes/bioinfo/test_git/Galaxy2-adrenal_1_bad_1.fastq <==
 @ERR030881.107 HWI-BRUNOP16X_0001:2:1:13663:1096#0/1
 ATCTTTTGTGGCTACAGTAAGTTCAATCTGAAGTCAAAACCAACCAATTT
 +
 5.544,444344555CC?CAEF@EEFFFFFFFFFFFFFFFFFEFFFEFFF
 @ERR030881.1487 HWI-BRUNOP16X_0001:2:1:4144:1420#0/1
 GTATAACGCTAGACACAGCGGAGCTCGGGATTGGCTAAACTCCCATAGTA
 +
 55*'+&&5'55('''888:8FFFFFFFFFF4/1;/4./++FFFFF=5:E#
 @ERR030881.20718 HWI-BRUNOP16X_0001:2:1:12184:5115#0/1
 CCCGGCCTAACTTTCATTTAATTTCAATGAATTTTCTTTTTTTTTTTTTT
 
 
 Call "RNA-SeqAlign2Ref.pl".
 
 perl ~/RNA-Seq-annotation-and-comparison/KSU_bioinfo_lab/RNA-SeqAlign2Ref.pl -r ~/test_git/sample_read_list.txt -f ~/test_git/hg19.fasta -g ~/test_git/Galaxy1-iGenomes_UCSC_hg19_chr19_gene_annotation.gtf -p human19
 
 ###Step 4: Run tuxedo scripts
 
 Index the hg19 genome. When these jobs are complete go to next step. Test completion by typing "status" in a Beocat session.
 
 bash ~/test_git/human19_qsubs/human19_qsubs_index.sh
 
 Clean raw reads. When these jobs are complete go to next step. Test completion by typing "status" in a Beocat session.
 Download the ".gd" files in the "~/test_git/human19_prinseq" directory and upload them to http://edwards.sdsu.edu/cgi-bin/prinseq/prinseq.cgi?report=1 to evaluate read quality pre and post cleaning.
 
 bash ~/test_git/human19_qsubs/human19_qsubs_clean.sh
 
 Map cleaned reads to hg19. When these jobs are complete go to next step. Test completion by typing "status" in a Beocat session.
 
 bash ~/test_git/human19_qsubs/human19_qsubs_map.sh
 
 bash ~/test_git/human19_qsubs/human19_qsubs_merge.sh

 
 
=cut