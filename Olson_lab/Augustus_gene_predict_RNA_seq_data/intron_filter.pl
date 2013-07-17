#Tara Marriage
#Olson lab
#Kansas State University

#script that filters for introns only

#!/usr/bin/perl -w
use strict;

my $infile=$ARGV[0];

	
open (INFILE, "<$infile");

while (<INFILE>)
{

	my @line = split ("\t", $_);
	#Debug
	#print "@line\n";
	
	if ($line[2] eq "intron"){
		print "$line[0]\t";
		print "$line[1]\t";
		print "$line[2]\t";
		print "$line[3]\t";
		print "$line[4]\t";
		print "$line[5]\t";
		print "$line[6]\t";
		print "$line[7]\t";
		print "$line[8]\t";
		}
	}
	