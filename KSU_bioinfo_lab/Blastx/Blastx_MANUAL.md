NAME

Blastx.pl - Script outputs fasta records split into files of 100 or
       less sequences in a directory called split. It also creates blastx bash
       scripts and qsub commands to annotate a de novo transcriptome with hits
       to the nr protein database.
       
UPDATES

####Blastx.pl Version 1.1
       
Blastx.pl Version 1.1 added a “-f” parameter for the input fasta file.
       This replaces the last text in the command being the path to the fasta.

USAGE

        perl Blastx.pl [options]

        Documentation options:
           -help    brief help message
           -man            full documentation
        Required parameters:
           -f      fasta to annotate with blastx
        Optional parameters:
           -m       maximum sequences to report alignments for
           -e       e-value
           --h_rt       hours runtime in hh:mm:ss

OPTIONS

       -help   Print a brief help message and exits.

       -man    Prints the more detailed manual page with output details and
               examples and exits.

       -f, --input_fasta
               The fullpath for the fasta file of assembled transcripts. These
               will be split into smaller files with no more than 100
               sequences per file and blasted against the "nr" database.

       -m, --max_target_seqs
               Maximum number of aligned sequences to keep. Default = '1'

       -e, --evalue
               Expectation value (E) threshold for saving hits. Default =
               '1e-05'

       --h_rt  Per job hours runtime in hh:mm:ss. Default = '4:00:00'

DESCRIPTION

       OUTPUT DETAILS:

       Script requires write permissions in the directory your original fasta
       is. For more detailed tutorial see:
       https://github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison/blob/master/KSU_bioinfo_lab/Blastx/Blastx_LAB.md

       Test with sample datasets:

       git clone
       https://github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison

       mkdir test_blastx

       cd test_blastx

       ln -s /homes/bioinfo/pipeline_datasets/Blastx/* ~/test_blastx/
       
       perl
       ~/RNA-Seq-annotation-and-comparison/KSU_bioinfo_lab/Blastx/Blastx.pl -m
       10 -f ~/test_blastx/CDH_clustermergedAssembly_cell_line_33.fa
