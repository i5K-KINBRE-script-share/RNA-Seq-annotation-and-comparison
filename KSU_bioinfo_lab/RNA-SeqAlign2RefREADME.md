###Step 1: Clone the Git repository

    git clone https://github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison
    
###Step 2: Create project directory and add your input data to it

make a working directoy

    mkdir test_git
    cd test_git
create symbolic links to raw reads from the brain and adrenal glands and the hg19 annotation gtf file

    ln -s ~/RNA-Seq-annotation-and-comparison/sample_datasets/* ~/test_git/
    
create symbolic links to hg19 fasta file

    ln -s /homes/bioinfo/hg19/hg19.fasta ~/test_git/
    
###Step 3: write tuxedo scripts

    perl ~/RNA-Seq-annotation-and-comparison/KSU_bioinfo_lab/RNA-SeqAlign2Ref.pl -r ~/test_git/sample_read_list.txt -f ~/test_git/hg19.fasta -g ~/test_git/Galaxy1-iGenomes_UCSC_hg19_chr19_gene_annotation.gtf -p human19
    
###Step 4: run tuxedo scripts

clean reads

    bash ~/test_git/human19_qsubs/human19_qsubs_clean.sh

 
