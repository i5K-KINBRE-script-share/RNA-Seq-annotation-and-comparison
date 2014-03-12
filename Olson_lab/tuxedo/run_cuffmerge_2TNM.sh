#!/bin/bash

export PATH=$PATH:/homes/bjsco/cufflinks-2.1.1.Linux_x86_64/cuffmerge

/homes/bjsco/cufflinks-2.1.1.Linux_x86_64/cuffmerge -o /homes/bjsco/2013-08-20_Gp_Cell_Cycle_Transcriptome/Olson\ Samples\ Run2/merged -g /homes/bjsco/2012-09-24_Gp_Cell_Cycle_Transcriptome/Augustus.gene.prediction.v1.1.TOPHAT_nodup.gff3 /homes/bjsco/2013-08-20_Gp_Cell_Cycle_Transcriptome/Olson\ Samples\ Run2/4Sept2013_assembly.txt

