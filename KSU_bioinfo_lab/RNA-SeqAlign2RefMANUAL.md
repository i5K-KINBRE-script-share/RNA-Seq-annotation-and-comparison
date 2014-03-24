SYNOPSIS

 RNA-SeqAlign2Ref.pl - The script writes scripts and qsubs to generate
       count summaries for illumina paired end reads after mapping against a
       reference genome. The script 1) converts illumina headers if the "-c"
       parameter is used, 2) cleans raw reads using Prinseq
       http://prinseq.sourceforge.net/manual.html, 3) index the reference
       genome for mapping, 4) reads are aligned to the genome with Tophat2
       (read more about Tophat2 at http://tophat.cbcb.umd.edu/manual.html) and
       expressed genes and transcripts are assembled with Cufflinks2, 5) these
       assemblies are merged with Cuffmerge and differential expression is
       estimated with Cuffdiff2.

For examples parameter details run "perl RNA-SeqAlign2Ref.pl -man".

USAGE

        perl RNA-SeqAlign2Ref.pl [options]

        Documentation options:
        -help    brief help message
        -man       full documentation
        Required options:
        -r          filename for file with tab separated list of sample labels, fastq files, and treatment labels
        -f          filename of the reference genome fasta
        -p          project name (no spaces)
        -g          filename of the gtf or gff genome annotation
        Filtering options:
        -l          minimum read length
        Fastq format options:
        -c          convert fastq headers

OPTIONS

       -help
                Print a brief help message and exits.

       -man
                Prints the more detailed manual page with output details and examples and exits.

       -r, --r_list
                The filename of the user provided list of replicate labels, read files, and treatment labels. Each line should be tab separated with the replicate label (no spaces), then the first read file, then the second read file, then the treatment label (no spaces). Example:
                brain_rep_1    ~/test_git/Galaxy4-brain_rep_1_1.fastq  ~/test_git/Galaxy5-brain_rep_1_2.fastq  treatment_brain
                adrenal_rep_1  ~/test_git/Galaxy2-adrenal_rep_1_1.fastq        ~/test_git/Galaxy3-adrenal_rep_1_2.fastq        treatment_adrenal
                brain_rep_2    ~/test_git/Galaxy4-brain_rep_2_1.fastq  ~/test_git/Galaxy5-brain_rep_2_2.fastq  treatment_brain
                adrenal_rep_2  ~/test_git/Galaxy2-adrenal_rep_2_1.fastq        ~/test_git/Galaxy3-adrenal_rep_2_2.fastq        treatment_adrenal

                If a replicate has more than one set of fastq files (multiple forward and reverse fastq files) list the forward fastq files separated by commas (no spaces) in the same order as the reverse also separated by commas. Each replicate should have all its files listed on the same line of the read file. Example (the first brain and adrenal replicates have two sets of fastq files):
                brain_rep_1    ~/test_git/Galaxy4-brain_rep_1_a_1.fastq,~/test_git/Galaxy4-brain_rep_1_b_1.fastq       ~/test_git/Galaxy5-brain_rep_1_a_2.fastq,~/test_git/Galaxy5-brain_rep_1_b_2.fastq       treatment_brain
                adrenal_rep_1  ~/test_git/Galaxy2-adrenal_rep_1_a_1.fastq,~/test_git/Galaxy2-adrenal_rep_1_b_1.fastq   ~/test_git/Galaxy3-adrenal_rep_1_a_2.fastq,~/test_git/Galaxy3-adrenal_rep_1_b_2.fastq   treatment_adrenal
                brain_rep_2    ~/test_git/Galaxy4-brain_rep_2_1.fastq  ~/test_git/Galaxy5-brain_rep_2_2.fastq  treatment_brain
                adrenal_rep_2  ~/test_git/Galaxy2-adrenal_rep_2_1.fastq        ~/test_git/Galaxy3-adrenal_rep_2_2.fastq        treatment_adrenal

       -f, --genome_fasta
                The filename of the user provided reference genome fasta.

       -g, --GTF_GFF
                The filename of the user provided reference genome annotation gtf or gff file.

       -p, --project_name
                The name of the project (no spaces). This will be used in filenaming.

       -c, --convert_header
                If the illumina headers do not end in /1 or /2 use this parameter to indicat that headers need to be converted. Check your headers by typing "head [fasta filename]" and read more about illumina headers at http://en.wikipedia.org/wiki/Fastq#Illumina_sequence_identifiers.

       -l, --min_len
                The minimum read length. Reads shorter than this after cleaning will be discarded. Default minimum length is 40bp.

DESCRIPTION

RUN DETAILS:

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

# Test with sample datasets:

###Step 1: Clone the Git repository

Log into Beocat and clone the git repository for this pipeline.

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
        
Merge the assembled transcripts with Cuffmerge and estimate differential expression with Cuffdiff2.

        bash ~/test_git/human19_qsubs/human19_qsubs_merge.sh
        
See https://github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison/blob/master/KSU_bioinfo_lab/RNA-SeqAlign2RefREADME.md for Output details.
