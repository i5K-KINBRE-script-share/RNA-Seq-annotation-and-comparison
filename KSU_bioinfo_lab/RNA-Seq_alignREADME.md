SYNOPSIS
       RNA-Seq_align.pl - The script writes scripts and qsubs to generate
       count summaries for illumina paired end reads after mapping against a
       de novo transcriptome. The script 1) converts illumina headers if the
       "-c" parameter is used, 2) cleans raw reads using Prinseq
       http://prinseq.sourceforge.net/manual.html, 3) creates a filtered
       transcriptome fasta file with putative transcripts less than 200 bp
       long removed and then indexes this transcriptome for mapping, 4) reads
       are then mapped to the length filtered de novo transcriptome using
       Bowtie2 in the best mapping default mode, read more about Bowtie2 at
       http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml, 5) count
       summaries are generated as a tab separated list where the first row is
       the sample ids and the first column is the name of the contig and the
       other values are the read counts per sample, see
       https://github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison/tree/master/KSU_bioinfo_lab/Count_reads_denovo
       for details on how reads are summarized.

       For examples parameter details run "perl RNA-Seq_align.pl -man".

USAGE
       perl RNA-Seq_align.pl [options]
       
       Documentation options:
          -help    brief help message
          -man     full documentation
        Required options:
          -r        filename for file with tab separated list of sample labels and fastq files
          -t        filename of the de novo transcriptome
          -p        project name (no spaces)
        Filtering options:
          -m        minimum mapq
        Fastq format options:
          -c        convert fastq headers

OPTIONS
       -help   Print a brief help message and exits.

       -man    Prints the more detailed manual page with output details and
               examples and exits.

       -r, --r_list
               The filename of the user provided list of read files and
               labels. Each line should be tab separated with the sample label
               (no spaces), then the first read file, then the second read
               file. Example: sample_1   sample_data/sample_1_R1.fastq
               sample_data/sample_1_R2.fastq sample_2
               sample_data/sample_2_R1.fastq   sample_data/sample_2_R2.fastq

       -t, --transcriptome
               The filename of the user provided de novo transcriptome
               assembly.

       -p, --project_name
               The name of the project (no spaces). This will be used in
               filenaming.
               
       -c, --convert_header
               If the illumina headers do not end in /1 or /2 use this
               parameter to indicat that headers need to be converted. Check
               your headers by typing "head [fasta filename]" and read more
               about illumina headers at
               http://en.wikipedia.org/wiki/Fastq#Illumina_sequence_identifiers.

       -m, --mapq
               The minimum MAPQ. Alignments with less than a 1 in 10 chance of
                actually being the correct alignment are filtered out by
                default. This is a minimum MAPQ of 10.

DESCRIPTION
       RUN DETAILS:

        This appears when the manual is viewed!!!!The script writes scripts and qsubs to generate count summaries for illumina paired end reads after mapping against a de novo transcriptome. The script

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

       Test with sample datasets:

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
