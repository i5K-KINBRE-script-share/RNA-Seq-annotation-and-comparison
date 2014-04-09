SYNOPSIS

 RNA-SeqAlign2Ref.pl - The script writes scripts and qsubs to generate
       count summaries for illumina paired or single end reads after mapping against a
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
        -s          single end reads (default is paired)

OPTIONS

       -help
                Print a brief help message and exits.

       -man
                Prints the more detailed manual page with output details and examples and exits.

       -r, --r_list
                The filename of the user provided list of replicate labels, read files,
               and treatment labels.

               For paired end reads: each line should be tab separated with the
               replicate label (no spaces), then the first read file or files, then
               the second read file or files, then the treatment label (no spaces).

               For single end reads: each line should be tab separated with the
               replicate label (no spaces), then the read file or files, then the
               treatment label (no spaces).
               
               Example:
                brain_rep_1    ~/test_git/Galaxy4-brain_rep_1_1.fastq  ~/test_git/Galaxy5-brain_rep_1_2.fastq  treatment_brain
                adrenal_rep_1  ~/test_git/Galaxy2-adrenal_rep_1_1.fastq        ~/test_git/Galaxy3-adrenal_rep_1_2.fastq        treatment_adrenal
                brain_rep_2    ~/test_git/Galaxy4-brain_rep_2_1.fastq  ~/test_git/Galaxy5-brain_rep_2_2.fastq  treatment_brain
                adrenal_rep_2  ~/test_git/Galaxy2-adrenal_rep_2_1.fastq        ~/test_git/Galaxy3-adrenal_rep_2_2.fastq        treatment_adrenal

                If a replicate has more than one set of fastq files (For paired end:
               multiple forward and reverse fastq files; For single end: multiple
               fastq files) list the forward fastq files separated by commas (no
               spaces) in the same order as the reverse also separated by commas. Each
               replicate should have all its files listed on the same line of the read
               file.

               Example (the first brain and adrenal replicates have two sets of fastq
               files):
               
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
                If the illumina headers do not end in /1 or /2 use this parameter to
               indicat that headers need to be converted. Check your headers by typing
               "head [fasta filename]" and read more about illumina headers at
               http://en.wikipedia.org/wiki/Fastq#Illumina_sequence_identifiers.

       -l, --min_len
               The minimum read length. Reads shorter than this after cleaning will be
               discarded. Default minimum length is 40bp.

       -s, --single
               If your reads are single end use this flag without it the script
               assumes reads are paired end. Also skip the third column (the second
               fastq file when making your read list).

DESCRIPTION

RUN DETAILS:

The script writes scripts and qsubs to generate count summaries for illumina
       paired end reads after mapping against a de novo transcriptome. The script

1) converts illumina headers if the "-c" parameter is used

2) cleans raw reads using Prinseq http://prinseq.sourceforge.net/manual.html.
       Prinseq parameters can be customized by editing ~/RNA-Seq-annotation-and-comparison/KSU_bioinfo_lab/RNA-SeqAlign2Ref/Prinseq_template.txt. For details on how to relaxe cleaning stringency see http://prinseq.sourceforge.net/Preprocessing_454_SFF_chart.pdf. 
       
Prinseq parameters in detail:

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

4) reads are aligned to the genome with Tophat2 (read more about Tophat2 at
       http://tophat.cbcb.umd.edu/manual.html) and expressed genes and transcripts are
       assembled with Cufflinks2 (read more about the Cuffdiff2 alogoritm in their
       publication
       http://bioinformaticsk-state.blogspot.com/2013/04/cuffdiff-2-and-isoform-abundance.html)

5) these assemblies are merged with Cuffmerge and differential expression is
       estimated with Cuffdiff2

# Test with sample datasets:

See: https://github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison/blob/master/KSU_bioinfo_lab/RNA-SeqAlign2Ref/RNA-SeqAlign2Ref_LAB.md


