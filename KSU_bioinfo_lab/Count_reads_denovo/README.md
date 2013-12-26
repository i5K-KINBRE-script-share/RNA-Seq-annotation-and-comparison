SCRIPT

**Count_reads_denovo_test.pl -**
This script takes sam files from Bowtie2
(one per biological replicate) and outputs tab separated list where the
first column is the name of the contig and the values are the read
counts per sample (in the same order as you listed your sam files). 
The script will print out sample ids only if the users provides them.

The script filters results based on pair relationships reported by
Bowtie2 (Concordant pairs (CP), discordant pairs (DP), unpaired mates
(UP), and mateless reads (UU)). These classes are used to ensure that
no fragment is counted twice (e.g. for each mate separately) and that
no fragment is counted as aligning to more than one contig. The pair
relationships are defined in Bowtie2 documentation
http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml#sam-output.

Below are diagrams of acceptable or unacceptable alignments.

![Alt text](https://raw.github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison/master/KSU_bioinfo_lab/accepted_alignments.png)
![Alt text](https://raw.github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison/master/KSU_bioinfo_lab/rejected_alignments.png)

The user can filter alignments further by adjusting the minimum MAPQ.
MAPQ, as reported by Bowtie2, indicates the ambiguity of an alignment
by comparing the alignment score of the current alignment to the score
of the next best alignment. A score of 0 indicates that the next best
alignment has the same score as the current alignment (e.g. we have no
evidence that this alignment is more correct than another alignment).
The default MAPQ filter for this script is 10 indicating the mate has a
1 in 10 chance of actually aligning elsewhere. If the MAPQ filter is
set to 20 then, to be counted, all mates must align with at least a 1
in 100 chance of actually aligning to the reported position.

Below is a decision diagram for Count_reads_denovo_test.pl

![Alt text](https://raw.github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison/master/KSU_bioinfo_lab/count_diagram.png)

       

USAGE

       perl script.pl [options]
        Documentation options:
          --help    brief help message
          --man     full documentation
        Required options:
          -s        sam files produced by Bowtie2
        Filtering options:
          -m        minimum MAPQ
        Output options:
          -l        labels for samples
          -o        output filename

OPTIONS

       --help, -h
               Print a brief help message and exits.

       --man   Prints the more detailed manual page with output details and
               examples and exits.

       --sams, -s
               A comma separated list of sam files produced with Bowtie2 (one
               per biological replicate).

       --mapq, -m
               The minimum MAPQ. Alignments with less than a 1 in 10 chance of
               actually being the correct alignment are filtered out by
               default. This is a minimum MAPQ of 10.

       --labels, -l
               A comma separated list of labels for samples (one per sam
               file). These will be printed as headers on the top of the
               output counts file.

       --out, -o
               The filename for the output counts file. The default filename
               is counts.txt.

DESCRIPTION

       DEPENDENCIES:

       git - see http://git-scm.com/book/ch1-4.html for instructions (git is
       used in the example workflow below but the script and example sam files
       can also be manually copied from github

**Test with sample datasets:**
       
```
git clone  https://github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison

cd RNA-Seq-annotation-and-comparison/KSU_bioinfo_lab/Count_reads_denovo

mkdir results

perl Count_reads_denovo.pl --sams samples/sample1.sam,samples/sample2.sam,samples/sample3.sam --labels sample1,sample2,sample3 --mapq 15 --out results/test
```
       
