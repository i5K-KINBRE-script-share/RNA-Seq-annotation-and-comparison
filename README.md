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
**Count_fastas.pl** - see assembly_quality_stats_for_multiple_assemblies.pl

**assembly_quality_stats_for_multiple_assemblies.pl** - This script runs a slightly modified version of Joseph Fass' Count_fasta.pl (original available at http://wiki.bioinformatics.ucdavis.edu/index.php/Count_fasta.pl ) on a fasta file from each assembly. It then creates comma separated file called assembly_metrics.csv listing the N25,N50,N75, cumulative contig length, and number of contigs for each assembly (also download Count_fastas.pl and change $path_to_Count_fastas on line 13 of assembly_quality_stats_for_multiple_assemblies.pl).

```
USAGE: perl assembly_quality_stats_for_multiple_assemblies.pl [FASTA filename or filenames]
```

**perl blastx.pl -** Script output fasta records split into files  of 100 or less sequences in a directory called split. It also creates blastx bash scripts and qsub commands.

```
USAGE: perl blastx.pl [FASTA filename]
```


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


