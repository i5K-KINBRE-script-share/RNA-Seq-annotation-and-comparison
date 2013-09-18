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

**count_reads_aligned_to_de_novo_transcriptome.pl** - This script takes sam files from Bowtie2 (one per biological or technical replicate) and outputs tab separated list where the first column is the name of the contig and the values are the read counts per sample (in the same order as you listed your sam files).

Reads are filtered based on MAPQ and pair relationships from Bowtie2 sam files. Reads passing these filters are counted as indicated below:
  ![Alt text](https://raw.github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison/master/KSU_bioinfo_lab/accepted_alignments.png)
  Reads diagramed below would not pass the filters and would not be counted for any contig:
  ![Alt text](https://raw.github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison/master/KSU_bioinfo_lab/rejected_alignments.png)
  Below is the decision diagram for the read counting script:
  ![Alt text](https://raw.github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison/master/KSU_bioinfo_lab/count_diagram.png)
  Change the default MAPping Quality in line 23. The script will print out sample ids. Replace the example sample ids in line 19 with your own before running. This step is optional. Uncomment line 18 to 19 and lines 144 to 154 if you want these printed.
