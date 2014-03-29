![alttext](https://raw.githubusercontent.com/i5K-KINBRE-script-share/transcriptome-and-genome-assembly/master/images/ngs_pipelines_on_beocat.png)
##RNA-Seq with Cuffdiff2 for projects with reference genomes
All of the scripts you will need to complete this lab as well as the sample dataset will be copied to your Beocat directory as you follow the instructions below. You should type or paste the text in the beige code block into your terminal as you follow along with the instructions below. If you are not used to commandline, practice with real data is one of the best ways to learn.

If you would like a quick primer on basic linux commands try these 10 minute lessons from Software Carpentry http://software-carpentry.org/v4/shell/index.html. For Beocat basics see http://support.cis.ksu.edu/BeocatDocs/GettingStarted.

To begin this lab your should read about the software we will be using. Prinseq will be used to clean raw reads. Priseq cleaning is highly customizable. You can see a detailed parameter list by typing "perl /homes/sheltonj/abjc/prinseq-lite-0.20.3/prinseq-lite.pl -h" or by visiting their manual at http://prinseq.sourceforge.net/manual.html. You can read a detailed list of parameter options for Tophat2 by typing "/homes/bjsco/bin/tophat2 -h" or visit the Tophat manual at http://tophat.cbcb.umd.edu/manual.html. Cufflink parameters are listed by running "/homes/bjsco/bin/cufflinks". Cuffdiff2 parameters are listed by running "/homes/bjsco/bin/cuffdiff". If you use the software for research you should read the article describing the Cuffdiff2 algorithm and performance http://bioinformaticsk-state.blogspot.com/2013/04/cuffdiff-2-and-isoform-abundance.html. 

We will be using the script "RNA-SeqAlign2Ref.pl" to organize our working directory and write scripts to index our reference genome (hg19), clean out reads, map our cleaned reads using Tophat2, 

To find out more about the parameters for "RNA-SeqAlign2Ref.pl" run  "perl ~/RNA-Seq-annotation-and-comparison/KSU_bioinfo_lab/RNA-SeqAlign2Ref.pl -man" or visit its manual at https://github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison/blob/master/KSU_bioinfo_lab/RNA-SeqAlign2Ref/RNA-SeqAlign2RefMANUAL.md

###Step 1: Clone the Git repository

    git clone https://github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison
    
###Step 2: Create project directory and add your input data to it

Make a working directory.

    mkdir test_git
    cd test_git
    
Create symbolic links to hg19 fasta file and to raw reads from the brain and adrenal glands and the hg19 annotation gtf file. Creating a symbolic link rather than copying avoids wasting disk space and protects your raw data from being altered.

        ln -s /homes/bioinfo/pipeline_datasets/RNA-SeqAlign2Ref/* ~/test_git/

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

    perl ~/RNA-Seq-annotation-and-comparison/KSU_bioinfo_lab/RNA-SeqAlign2Ref/RNA-SeqAlign2RefRNA-SeqAlign2Ref.pl -r ~/test_git/sample_read_list.txt -f ~/test_git/hg19.fasta -g ~/test_git/Galaxy1-iGenomes_UCSC_hg19_chr19_gene_annotation.gtf -p human19
    
###Step 4: Run prinseq and the tuxedo scripts

Index the hg19 genome. When these jobs are complete go to next step. Test completion by typing "status" in a Beocat session.

    bash ~/test_git/human19_qsubs/human19_qsubs_index.sh

Clean raw reads. When these jobs are complete go to next step. Test completion by typing "status" in a Beocat session.
Download the ".gd" files in the "~/test_git/human19_prinseq" directory and upload them to http://edwards.sdsu.edu/cgi-bin/prinseq/prinseq.cgi?report=1 to evaluate read quality pre and post cleaning.

    bash ~/test_git/human19_qsubs/human19_qsubs_clean.sh

Map cleaned reads to hg19. When these jobs are complete go to next step. Test completion by typing "status" in a Beocat session.

    bash ~/test_git/human19_qsubs/human19_qsubs_map.sh
 
Merge the assembled transcripts with Cuffmerge and estimate differential expression with Cuffdiff2.

    bash ~/test_git/human19_qsubs/human19_qsubs_merge.sh
    
### Output details:

**Attribute definitions from the manual:**	

**tss_id**	The ID of this transcript's inferred start site. Determines which primary transcript this processed transcript is believed to come from. Cuffcompare appends this attribute to every transcript reported in the .combined.gtf file.

**p_id**	The ID of the coding sequence this transcript contains. This attribute is attached by Cuffcompare to the .combined.gtf records only when it is run with a reference annotation that include CDS records. Further, differential CDS analysis is only performed when all isoforms of a gene have p_id attributes, because neither Cufflinks nor Cuffcompare attempt to assign an open reading frame to transcripts.

**Cuffdiff Output:**

Cuffdiff produces results for many subsets of the data. Files beginning with “isoform” are transcript level, “gene” indicates the sum of all transcripts with the same gene_id, “cds” indicates the sum of all transcripts with shared coding sequence (according to the gtf annotation), and “tss”indicates the sum of transcripts that share an inferred start site (tss_id).

**FPKM tracking files** = shows abundance in terms of Fragments Per Kilobase of exon model per Million mapped fragments (FPKM) for each sample (0..n). Each row represents the values for the object in the first column.

**read group tracking files** = show unscaled estimate of fragments originating from the object in the first column as well as FPKM.

**count tracking files** = show externally scaled estimate of fragments originating from the object in the first column. These values can not be used as input for count based differential expression packages like DeSeq and EdgeR because they are not raw counts.

**differential expression test files** = show the results of testing for differential expression between FPKM values for the object in the first column.

###Explore your output:

1) Open your "~/test_git/human19_prinseq" directory. View your the "raw" and "cleaned" .gd file by uploading these to http://edwards.sdsu.edu/cgi-bin/prinseq/prinseq.cgi?report=1. Learn how to download files from Beocat at https://github.com/i5K-KINBRE-script-share/FAQ/blob/master/BeocatEditingTransferingFiles.md. Evaluate read quality pre and post cleaning metrics. Which graphs changed after cleaning? Why would we want these values to change?

2) Open your "~/test_git/diff" directory. Take a moment to explore a differential expression file. Find an object that is estimated to be differetially expressed and report each columns' value for that object and interpret the result. 

3) Customize your "RNA-SeqAlign2Ref.pl" script to change a parameter when you either clean with prinseq or use the tuxedo scripts. You have now run the following programs on Beocat: prinseq-lite.pl, tophat2, cufflinks, cuffdiff. You can find a full list of possible parameters for any of these by typing one of the following:

        perl /homes/sheltonj/abjc/prinseq-lite-0.20.3/prinseq-lite.pl -h
        /homes/bjsco/bin/tophat2 -h
        /homes/bjsco/bin/cufflinks
        /homes/bjsco/bin/cuffdiff
        
Pick a new parameter from one of these lists and customize your own pipeline by finding a filename that starts with the name of the program you choose and ends with `_template.txt`. Look in the `~/RNA-Seq-annotation-and-comparison/KSU_bioinfo_lab/RNA-SeqAlign2Ref/` directory to find the template script.

Open this in a text editor using Cyberduck https://github.com/i5K-KINBRE-script-share/FAQ/blob/master/BeocatEditingTransferingFiles.md. Find the line with that command (e.g. searching for /homes/sheltonj/abjc/prinseq-lite-0.20.3/prinseq-lite.pl), and edit this line by adding your new parameter or changing the current value.

For example, I find `Prinseq_template.txt` and I can change the maximum number of N's allowed in a read by changing this:

perl /homes/sheltonj/abjc/prinseq-lite-0.20.3/prinseq-lite.pl -verbose -fastq $r1[$file] -fastq2 $r2[$file] -min_len $min_len -min_qual_mean 25 -trim_qual_type mean -trim_qual_rule lt -trim_qual_window 2 -trim_qual_step 1 -trim_qual_left 20 -trim_qual_right 20 **-ns_max_p 1** -trim_ns_left 5 -trim_ns_right 5 -lc_method entropy -lc_threshold 70 -out_format 3 -no_qual_header -log ${home}/${project_name}_prinseq/${filename}_paired.log\ -graph_data ${home}/${project_name}_prinseq/${filename}_raw.gd -out_good ${home}/${filename}_good -out_bad ${home}/${filename}_bad
        
To this:

perl /homes/sheltonj/abjc/prinseq-lite-0.20.3/prinseq-lite.pl -verbose -fastq $r1[$file] -fastq2 $r2[$file] -min_len $min_len -min_qual_mean 25 -trim_qual_type mean -trim_qual_rule lt -trim_qual_window 2 -trim_qual_step 1 -trim_qual_left 20 -trim_qual_right 20 **-ns_max_p 10** -trim_ns_left 5 -trim_ns_right 5 -lc_method entropy -lc_threshold 70 -out_format 3 -no_qual_header -log ${home}/${project_name}_prinseq/${filename}_paired.log\ -graph_data ${home}/${project_name}_prinseq/${filename}_raw.gd -out_good ${home}/${filename}_good -out_bad ${home}/${filename}_bad

If my total number of N's allowed increases I do increase the risk of counting an incorrect alignment but I also increase the sensitivity of my experiment by including more reads.

Describe the pros and cons of the parameter change that you made when customizing you script.




