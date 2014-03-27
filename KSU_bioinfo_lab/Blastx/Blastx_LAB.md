All of the scripts you will need to complete this lab as well as the sample dataset will be copied to your Beocat directory as you follow the instructions below. You should type or paste the text in the beige code block into your terminal as you follow along with the instructions below. If you are not used to commandline, practice with real data is one of the best ways to learn.

If you would like a quick primer on basic linux commands try these 10 minute lessons from Software Carpentry http://software-carpentry.org/v4/shell/index.html. For Beocat basics see http://support.cis.ksu.edu/BeocatDocs/GettingStarted.

The ncbi “blastx” search tool translates a nucleotide query into all six frames and compares these six translations to a protein database. We will be using the script "Blastx.pl" to organize our working directory and write scripts to blast putative transcripts from our de novo transcriptome against the nr protein database.

You can read more about blast commandline tools by going to their manual http://www.ncbi.nlm.nih.gov/books/NBK1763/ or typing `/homes/bioinfo/bioinfo_software/ncbi-blast-2.2.28+/bin/blastx -help`. 

###Step 1: Clone the Git repositories

    git clone https://github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison

###Step 2: Create project directory and add your input data to it

Make a working directory.

    mkdir test_blastx
 
    cd test_blastx
 
Create symbolic links to putative transcripts from the de novo transcriptome created from human breast cancer cell line RNA. Creating a symbolic link rather than copying avoids wasting disk space and protects your raw data from being altered. Our sample dataset was assembled from cell line RNA from the Galaxy data libraries https://usegalaxy.org/library/index. 

    ln -s /homes/bioinfo/pipeline_datasets/Blastx/* ~/test_blastx/

###Step 3: Write blast scripts

    perl ~/RNA-Seq-annotation-and-comparison/KSU_bioinfo_lab/Blastx/Blastx.pl -m 10 ~/test_blastx/CDH_clustermergedAssembly_cell_line_33.fa
    
### Step 4: Run Blast scripts

When these jobs are complete go to next step. Test completion by typing "status" in a Beocat session.

    bash ~/test_blastx/CDH_clustermergedAssembly_cell_line_33_qsubs.sh
    
Check for blasts that timed out

    perl ~/RNA-Seq-annotation-and-comparison/KSU_bioinfo_lab/Blastx/FindFailed.pl -x ~/test_blastx/blasts
    
If`~/test_blastx/blasts/unfinished.fasta` is an empty file annotation is complete. If fasta sequences have been added to it you will need to run Blastx.pl on `~/test_blastx/blasts/unfinished.fasta`. You should increase the hours of runtime allowed for each job because these remaining sequences timed out before the job finished.

    perl ~/RNA-Seq-annotation-and-comparison/KSU_bioinfo_lab/Blastx/Blastx.pl --h_rt 8:00:00 -m 10 ~/test_blastx/blasts/unfinished.fasta
    
Next check to make sure that the file  `~/test_blastx/blasts/blasts/unfinished.fasta` is empty. If it is not empty repeat the running Blastx.pl on the most recent output followed by FindFailed.pl until FindFailed.pl produces an empty fasta file.





