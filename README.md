RNA-Seq-annotation-and-comparison
=================================

Olson_lab repository
--------------------

  Augustus_gene_predict_RNA_seq_data repository:
    augustus_beocat.txt -

    autoAugPred.pl -

    intron_filter.pl -

    shellForAug -
    
KSU_bioinfo_lab
---------------
###Count_fastas.pl
**Count_fastas.pl** - see assembly_quality_stats_for_multiple_assemblies.pl

###RNA-Seq_align.pl

SYNOPSIS

**RNA-Seq_align.pl -** The script writes scripts and qsubs to generate
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
          
Test with sample datasets:
```
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
```

**assembly_quality_stats_for_multiple_assemblies.pl** - This script runs a slightly modified version of Joseph Fass' Count_fasta.pl (original available at http://wiki.bioinformatics.ucdavis.edu/index.php/Count_fasta.pl ) on a fasta file from each assembly. It then creates comma separated file called assembly_metrics.csv listing the N25,N50,N75, cumulative contig length, and number of contigs for each assembly (also download Count_fastas.pl and change $path_to_Count_fastas on line 13 of assembly_quality_stats_for_multiple_assemblies.pl).

```
USAGE: perl assembly_quality_stats_for_multiple_assemblies.pl [FASTA filename or filenames]
```

###perl blastx.pl
**perl blastx.pl -** Script output fasta records split into files  of 100 or less sequences in a directory called split. It also creates blastx bash scripts and qsub commands.

```
USAGE: perl blastx.pl [FASTA filename]
```
###find_failed.pl
**find_failed.pl -** a package of scripts that find fasta sequences that have not been blasted (e.g. when a running blastx times out)

```
USAGE: perl find_failed.pl -x [XML directory]
```
###Count_reads_denovo.pl
**Count_reads_denovo.pl** - This script takes sam files from Bowtie2 (one per biological or technical replicate) and outputs tab separated list where the first column is the name of the contig and the values are the read counts per sample (in the same order as you listed your sam files).

**To use this script:**

Step 1: Align paired end reads to a clustered de novo transcriptome using the Bowtie2 "best mapping" (default) reporting mode.

Step 2: Run by passing your SAM file output as arguements when you run Count_reads_denovo.pl (one SAM file per sample) in the same order as you enter your sample ids (ids are optional). A more detailed README can be viewed at https://github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison/tree/master/KSU_bioinfo_lab/Count_reads_denovo. The manual can be viewed by running:

```
perl Count_reads_denovo.pl --man
```

Reads are filtered based on MAPQ and pair relationships from Bowtie2 sam files. Reads passing these filters are counted as indicated below:
  ![Alt text](https://raw.github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison/master/KSU_bioinfo_lab/accepted_alignments.png)
  Reads diagramed below would not pass the filters and would not be counted for any contig:
  ![Alt text](https://raw.github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison/master/KSU_bioinfo_lab/rejected_alignments.png)
  Below is the decision diagram for the read counting script. Concordant pairs (CP), discordant pairs (DP), unpaired mates (UP), and mateless reads (UU) are defined in Bowtie2 documentation http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml#sam-output
:
  ![Alt text](https://raw.github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison/master/KSU_bioinfo_lab/count_diagram.png)

Minimum MAPQ can be adjusted. The default minimum is 10.


