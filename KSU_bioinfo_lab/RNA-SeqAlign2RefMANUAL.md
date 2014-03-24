SYNOPSIS
        RNA-SeqAlign2Ref.pl - The script writes scripts and qsubs to generate count summaries for illumina paired end reads after mapping against a reference genome. The script 1) converts illumina headers if the "-c" parameter is used, 2) cleans raw reads using Prinseq http://prinseq.sourceforge.net/manual.html, 3) index the reference genome for mapping, 4) reads are aligned to the genome with Tophat2 (read more about Tophat2 at http://tophat.cbcb.umd.edu/manual.html) and expressed genes and transcripts are assembled with Cufflinks2, 5) these assemblies are merged with Cuffmerge and differential expression is estimated with Cuffdiff2.

        For examples parameter details run "perl RNA-SeqAlign2Ref.pl -man".

        =head1 USAGE

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
