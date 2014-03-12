#!/bin/bash

export PATH=$PATH:/homes/bjsco/bin

/homes/bjsco/bin/tophat2 -p 1 -o /homes/bjsco/2013-08-20_Gp_Cell_Cycle_Transcriptome/Olson\ Samples\ Run2/Sample_Xp1 -g 20 -G /homes/bjsco/2012-09-24_Gp_Cell_Cycle_Transcriptome/Augustus.gene.prediction.v1.1.TOPHAT_nodup.gff3 /homes/bjsco/2012-09-24_Gp_Cell_Cycle_Transcriptome/bowtie2index/GpInx2 /homes/bjsco/2013-08-20_Gp_Cell_Cycle_Transcriptome/Olson\ Samples\ Run2/Sample_Xp1/Xp1_CGATGT_L001_R1_001.fastq.gz /homes/bjsco/2013-08-20_Gp_Cell_Cycle_Transcriptome/Olson\ Samples\ Run2/Sample_Xp1/Xp1_CGATGT_L001_R2_001.fastq.gz
