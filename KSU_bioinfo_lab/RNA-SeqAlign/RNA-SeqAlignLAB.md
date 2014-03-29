![alttext](https://raw.githubusercontent.com/i5K-KINBRE-script-share/transcriptome-and-genome-assembly/master/images/ngs_pipelines_on_beocat.png)
##RNA-Seq with Bowtie2 and Deseq for projects without reference genomes
All of the scripts you will need to complete this lab as well as the sample dataset will be copied to your Beocat directory as you follow the instructions below. You should type or paste the text in the beige code block into your terminal as you follow along with the instructions below. If you are not used to commandline, practice with real data is one of the best ways to learn.

If you would like a quick primer on basic linux commands try these 10 minute lessons from Software Carpentry http://software-carpentry.org/v4/shell/index.html. For Beocat basics see http://support.cis.ksu.edu/BeocatDocs/GettingStarted.

To begin this lab your should read about the software we will be using. Prinseq will be used to clean raw reads. Priseq cleaning is highly customizable. You can see a detailed parameter list by typing "perl /homes/sheltonj/abjc/prinseq-lite-0.20.3/prinseq-lite.pl -h" or by visiting their manual at http://prinseq.sourceforge.net/manual.html. You can read a detailed list of parameter options for Bowtie2 by typing `/homes/bioinfo/bioinfo_software/bowtie2-2.1.0/bowtie2 -h`or by visiting their manual http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml.

We will be using the script "RNA-SeqAlign.pl" to organize our working directory and write scripts to index our de novo cell line transcriptome using Bowtie2.

To find out more about the parameters for `RNA-SeqAlign.pl` run `perl ~/RNA-Seq-annotation-and-comparison/KSU_bioinfo_lab/RNA-SeqAlign/RNA-SeqAlign.pl -man` or visit its manual at https://github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison/blob/master/KSU_bioinfo_lab/RNA-SeqAlign/RNA-SeqAlignMANUAL.md

###Step 1: Clone the Git repository

1) Log into Beocat and retrieve your scripts and raw data using the following code.

Step 2: Create project directory and add your input data to it

Make a working directory.

    git clone https://github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison

    git clone https://github.com/i5K-KINBRE-script-share/read-cleaning-format-conversion

    mkdir test_de_novo_DE
    cd test_de_novo_DE

Create symbolic links to raw reads from the cell lines and the de novo transcriptome assembled from these reads. Creating a symbolic link rather than copying avoids wasting disk space and protects your raw data from being altered.

    ln -s /homes/bioinfo/pipeline_datasets/RNA-SeqAlign/* ~/test_de_novo_DE/
 
###Step 3: Write assembly scripts

Check to see if your fastq headers end in "/1" or "/2" (if they do not you must add the parameter `-c` when you run `RNA-SeqAlign.pl`

    head ~/test_de_novo_DE/*_1.fastq
    
Your output will look similar to the output below for the sample data. Because these headers end in "/1" or "/2" we will not add `-c` when we call `RNA-SeqAlign.pl`.

    ==> /homes/bioinfo/test_de_novo_DE/BT20_paired-end_RNA-seq_subsampled_1.fastq <==
    @HWUSI-EAS1794_0001_FC61KOJ:4:30:19389:13787#0/1
    GCGGCCCGGCCCCGGCCCCCTGCTCGTTGGCTGTGGCAGGGCCGCCGTGG
    +
    HHHHHHHGEHHHHDHDHHHHBDGBBC@CAC?8C><AAAACD>DDB?####
    @HWUSI-EAS1794_0001_FC61KOJ:4:57:10821:2162#0/1
    CAGATATCGAAGATGAAGACTTAAAGTTAGAGCTGCGACGACTACGAGAT
    +
    IIHIIIIIIHHIHIIIIIEIIIIIIIIIIIHHII@IHIIIIHHEIIHIID
    @HWUSI-EAS1794_0001_FC61KOJ:4:75:5014:13576#0/1
    CTCAGCCACCAGCAGCGGCACCCCCATCTGCAGTTGGCTCTTCTGCTGCT

Call `RNA-SeqAlign.pl`. Our reads are only ~50 bp long so we are setting our minimum read length to 40 bp. Generally you want to keep this length ~10 bp shorter than our read length.

    perl ~/RNA-Seq-annotation-and-comparison/KSU_bioinfo_lab/RNA-SeqAlign/RNA-SeqAlign.pl -r ~/test_de_novo_DE/cell_line_reads_DE.txt -t ~/test_de_novo_DE/CDH_clustermergedAssembly_cell_line_33.fa -p cell_lines -l 40

###Step 4: Run prinseq and the mapping scripts

Index the de novo transcriptome. When this job is complete go to next step. Test completion by typing "status" in a Beocat session.

    bash ~/test_de_novo_DE/cell_lines_qsubs/cell_lines_qsubs_index.sh

When these jobs are complete view the ".gd" files and then go to next step. Test completion by typing "status" in a Beocat session. Download the ".gd" files in the Project_name_prinseq directory and upload them to http://edwards.sdsu.edu/cgi-bin/prinseq/prinseq.cgi?report=1 to evaluate read quality pre and post cleaning

    bash ~/test_de_novo_DE/cell_lines_qsubs/cell_lines_qsubs_clean.sh

Map your reads to the de novo transcriptome. When these jobs are complete go to next step. Test completion by typing "status" in a Beocat session.

    bash ~/test_de_novo_DE/cell_lines_qsubs/cell_lines_qsubs_map.sh

Summarize you read counts. The script `Count_reads_denovo.pl` filters results based on pair relationships reported by Bowtie2 (Concordant pairs (CP), discordant pairs (DP), unpaired mates (UP), and mateless reads (UU)). These classes are used to ensure that no fragment is counted twice (e.g. for each mate separately) and that no fragment is counted as aligning to more than one contig. See https://github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison/tree/master/KSU_bioinfo_lab/Count_reads_denovo for more details.

    bash ~/test_de_novo_DE/cell_lines_qsubs/cell_lines_qsubs_count.sh
