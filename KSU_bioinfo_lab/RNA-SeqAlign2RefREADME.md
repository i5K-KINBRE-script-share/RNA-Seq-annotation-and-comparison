To begin this lab your should read about the software we will be using. Prinseq will be used to clean raw reads. Priseq cleaning is highly customizable. You can see a detailed parameter list by typing "perl /homes/sheltonj/abjc/prinseq-lite-0.20.3/prinseq-lite.pl -h" or by visiting their manual at http://prinseq.sourceforge.net/manual.html. You can read a detailed list of parameter options for Tophat2 by typing "/homes/bjsco/bin/tophat2 -h" or visit the Tophat manual at http://tophat.cbcb.umd.edu/manual.html. Cufflink parameters are listed by running "/homes/bjsco/bin/cufflinks". Cuffdiff2 parameters are listed by running "/homes/bjsco/bin/cuffdiff". If you use the software for research you should read the article describing the Cuffdiff2 algorithm and performance http://bioinformaticsk-state.blogspot.com/2013/04/cuffdiff-2-and-isoform-abundance.html. 

We will be using the script "RNA-SeqAlign2Ref.pl" to organize our working directory and write scripts to index our reference genome (hg19), clean out reads, map our cleaned reads using Tophat2, 

To find out more about the parameters for "RNA-SeqAlign2Ref.pl" run  "perl ~/RNA-Seq-annotation-and-comparison/KSU_bioinfo_lab/RNA-SeqAlign2Ref.pl -man" or visit its manual at https://github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison/tree/master/KSU_bioinfo_lab

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

```
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
```

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

 
