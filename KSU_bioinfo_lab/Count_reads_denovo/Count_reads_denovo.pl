#!/usr/bin/perl
##################################################################################
#   
#	USAGE: perl Count_reads_denovo.pl [options]
#
#  Created by Jennifer Shelton
#
##################################################################################
use strict;
use warnings;
# use List::Util qw(max);
# use List::Util qw(sum);
use Getopt::Long;
use Pod::Usage;
use IO::File;
##################################################################################
##############         Print informative message                ##################
##################################################################################
print "###########################################################\n";
print "#  Count_reads_denovo.pl                                  #\n";
print "#                                                         #\n";
print "#  Created by Jennifer Shelton 09/15/13                   #\n";
print "#                                                         #\n";
print "#  perl script.pl -help # for usage/options               #\n";
print "#  perl script.pl -man # for more details                 #\n";
print "###########################################################\n";
print "https://github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison/blob/master/KSU_bioinfo_lab/Count_reads_denovo/Count_reads_denovo.pl\n\n";

##################################################################################
##############                get arguments                     ##################
##################################################################################

# sample1,sample2,sample3/; #replace with your sample ids in the order that you list your sam files

################################ Set filters ###############################
my $mapq=10;
my $outfile="counts.txt"; # the name of the output file can be changed here
my $man = 0;
my $help = 0;
my $label = 0;
my $sam = 0;
GetOptions (
			  'help|?' => \$help, 
			  'man' => \$man,
			  'o|out:s' => \$outfile,    
              'm|mapq:i' => \$mapq,
              'l|labels:s' => \$label,
              's|sams:s' => \$sam
  
              )  
or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;

##################################################################################
##############                        run                       ##################
##################################################################################
my (@temp,@default);
my (%count_hash);
my $i=0;
open (COUNT_FILES, ">", "$outfile") or die "cannot open $outfile: $!";
##################################################################################
############################### create default hash entry ########################
##################################################################################
my @sams=split /,/,$sam;
my @samples;
print "Minimum MAPQ set to $mapq\n";
if ($label)
{
	print "Sample labels: $label\n";
	@samples=split(/,/,$label );
}
for (0..$#sams) ## populate default values for each contig
{
    push(@default,'0');
}
##################################################################################
########################## make a count_hash of raw counts #######################
##################################################################################
foreach my $f (@sams)
{
	my $concordant_pair_mapped_read=0;
	my $discordant_pair_mapped_read=0;
	my $unpaired_mate_mapped_reads=0; # only one end maps relatively unambiguously (above MAPQ cutoff) 
	my $single_end_mapped_reads=0;
	my $fragment=0; # counts one for each pair or singleton (UU in Bowtie2 syntax) regardless of whether or not they map
	my %read_hash;
	my $file = IO::File->new();
    	if ($file->open("< $f")) {print "\n$f opened...\n";}
    	else {print "could not open $f\n";}
	while (<$file>)
	{
		unless (/^\@/)
 	   {
	        @temp=split(/\t/);
	        unless ($count_hash{$temp[2]}) ## if we haven't seen the contig before add it to contig count_hash
	        {
	        	$count_hash{$temp[2]} =[@default];
	        }
##################################################################################
###################### require pairs map to same contig ##########################
##################################################################################
	        if ($temp[6] eq '=')
	        {
##################################################################################
################################ count concordant pairs ##########################
##################################################################################
	        	if ($_ =~ /YT:Z:CP/)
	        	{
	        		unless ($read_hash{$temp[0]})
	        		{
	        			$fragment++;
	        			if (($temp[4]>$mapq)&&($temp[4]!=255))
	        			{
	        				$read_hash{$temp[0]}=1;
	        			}
	        			else
	        			{
	        				$read_hash{$temp[0]}=0;
	        			}
	        		}
	        		else
	        		{ 
	        			if ((($temp[4]>$mapq)&&($temp[4]!=255)) || ($read_hash{$temp[0]}==1))
	        			{
	        				$count_hash{$temp[2]}->[$i]++; ## count one for a paired read where one or both ends map relatively unambiguously (above MAPQ cutoff)
	        				$concordant_pair_mapped_read++;
	        			}
	        		}
	        	}	
##################################################################################        				        		
################################ count discordant pairs ##########################
##################################################################################	        		
	        	if ($_ =~ /YT:Z:DP/)
	        	{
	        		unless ($read_hash{$temp[0]})
	        		{
	        			$fragment++;
	        			if (($temp[4]>$mapq)&&($temp[4]!=255))
	        			{
	        				$read_hash{$temp[0]}=1;
	        			}
	        			else
	        			{
	        				$read_hash{$temp[0]}=0;
	        			}
	        		}
	        		else
	        		{ 
	        			if ((($temp[4]>$mapq)&&($temp[4]!=255)) || ($read_hash{$temp[0]}==1))
	        			{
	        				$count_hash{$temp[2]}->[$i]++; ## count one for a paired read where one or both ends map relatively unambiguously (above MAPQ cutoff)
	        				$discordant_pair_mapped_read++;
	        			}
	        		}
	        	}
	        }
	        elsif (($read_hash{$temp[0]}) && ($temp[6] ne '=') && (($_ =~ /YT:Z:CP/) || ($_ =~ /YT:Z:DP/)))
	        {
	        	$fragment++;
	        	$read_hash{$temp[0]}=0;
	        }
##################################################################################
############ if one pair fails and one passes count broken pairs (UP) ############
##################################################################################	        		
	        if ($_ =~ /YT:Z:UP/)
	        	{
	        		unless ($read_hash{$temp[0]})
	        		{
	        			$fragment++;
	        			if (($temp[4]>$mapq)&&($temp[4]!=255))
	        			{
	        				$read_hash{$temp[0]}=1;
	        			}
	        			else
	        			{
	        				$read_hash{$temp[0]}=0;
	        			}
	        		}
	        		else
	        		{ 
	        			if ((($temp[4]>$mapq)&&($temp[4]!=255)) && ($read_hash{$temp[0]}==0))
	        			{
	        				$count_hash{$temp[2]}->[$i]++; ## count one for a paired read where only one end maps relatively unambiguously (above MAPQ cutoff)
	        				$unpaired_mate_mapped_reads++;
	        			}
	        			elsif ((($temp[4]<=$mapq)||($temp[4]==255)) && ($read_hash{$temp[0]}==1))
	        			{
	        				$count_hash{$temp[2]}->[$i]++; ## count one for a paired read where only one end maps relatively unambiguously (above MAPQ cutoff)
	        				$unpaired_mate_mapped_reads++;
	        			}	        			
	        		}
	        	}
##################################################################################	
####################### count single end reads (UU) ##############################
##################################################################################	        		
	        if ($_ =~ /YT:Z:UU/)
	        	{
	        		$fragment++;
	        		if (($temp[4]>$mapq)&&($temp[4]!=255))
	        		{
	  	        		$count_hash{$temp[2]}->[$i]++; ## count one for a single end read read maps relatively unambiguously (above MAPQ cutoff)
	        			$single_end_mapped_reads++;
	        		}
	        	}
		}
	    
    	}
    	print "Summary statistics for $f:\n";
    	print "Concordant_pairs that were added to count summary=$concordant_pair_mapped_read\n";
		print "Discordant_pairs that were added to count summary=$discordant_pair_mapped_read\n";
		print "Unpaired_mates that were added to count summary=$unpaired_mate_mapped_reads\n";
		print "Single_end_reads that were added to count summary=$single_end_mapped_reads\n";
		print "Fragments (counted and uncounted)=$fragment\n";
			$i++;
		$file->close;
}
##################################################################################
########## optional print of header with sample names ############################
##################################################################################
if ($label)
{
	for my  $j (0 .. $#samples) ## optional printing of sample ids, uncomment out lines 42 to 43 and lines 168 to 178 if you want a sample id row
	{
		if ($j < $#samples)
		{
			print COUNT_FILES "$samples[$j]\t";
		}
		else
		{
			print COUNT_FILES "$samples[$j]\n";
		}
	}
}
for my $contig ( keys %count_hash ) ## print out table of raw counts
{
    print COUNT_FILES "$contig\t";
    for my $k ( 0 .. $#{ $count_hash{$contig} } )
    {
    	if ($k < $#{ $count_hash{$contig} })
    	{
        	print COUNT_FILES "$count_hash{$contig}[$k]\t";
    	}
        else
        {
        	print COUNT_FILES "$count_hash{$contig}[$k]\n";
        }
	}
}

##################################################################################
##############                  Documentation                   ##################
##################################################################################
## style adapted from http://www.perlmonks.org/?node_id=489861 
__END__

=head1 NAME

Count_reads_denovo_test.pl - This script takes sam files from Bowtie2 (one per biological replicate) and outputs tab separated list where the first column is the name of the contig and the values are the read counts per sample (in the same order as you listed your sam files)

The script filters results based on pair relationships reported by Bowtie2 (Concordant pairs (CP), discordant pairs (DP), unpaired mates (UP), and mateless reads (UU)). These classes are used to ensure that no fragment is counted twice (e.g. for each mate separately) and that no fragment is counted as aligning to more than one contig. The pair relationships are defined in Bowtie2 documentation http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml#sam-output. Diagrams of acceptable or unacceptable alignments and a decision diagram for Count_reads_denovo_test.pl can be found at https://github.com/i5K-KINBRE-script-share/RNA-Seq-annotation-and-comparison.

The user can filter alignments further by adjusting the minimum MAPQ. MAPQ, as reported by Bowtie2, indicates the ambiguity of an alignment by comparing the alignment score of the current alignment to the score of the next best alignment. A score of 0 indicates that the next best alignment has the same score as the current alignment (e.g. we have no evidence that this alignment is more correct than another alignment). The default MAPQ filter for this script is 10 indicating the mate has a 1 in 10 chance of actually aligning elsewhere. If the MAPQ filter is set to 20 then, to be counted, all mates must align with at least a 1 in 100 chance of actually aligning to the reported position.

The script will print out sample ids only if the users provides them.

=head1 USAGE

perl script.pl [options]

 Documentation options:
   --help    brief help message
   --man     full documentation
 Required options:
   -s	     sam files produced by Bowtie2
 Filtering options:
   -m	     minimum MAPQ   
 Output options:
   -l	     labels for samples
   -o	     output filename
         
=head1 OPTIONS

=over 8

=item B<--help, -h>

Print a brief help message and exits.

=item B<--man>

Prints the more detailed manual page with output details and examples and exits.

=item B<--sams, -s>

A comma separated list of sam files produced with Bowtie2 (one per biological replicate).

=item B<--mapq, -m>

The minimum MAPQ. Alignments with less than a 1 in 10 chance of actually being the correct alignment are filtered out by default. This is a minimum MAPQ of 10.

=item B<--labels, -l>

A comma separated list of labels for samples (one per sam file). These will be printed as headers on the top of the output counts file.

=item B<--out, -o>

The filename for the output counts file. The default filename is counts.txt.

=back

=head1 DESCRIPTION

B<DEPENDENCIES:>

git - see http://git-scm.com/book/ch1-4.html for instructions (git is used in the example workflow below but the script and example sam files can also be manually copied from github 

B<Test with sample datasets:>

$ git clone  https://github.com/i5K-KINBRE-script-share/RNA-

Seq-annotation-and-comparison

$ cd RNA-Seq-annotation-and-comparison/KSU_bioinfo_lab/Count_reads_denovo

$ mkdir results

$ perl Count_reads_denovo.pl --sams samples/sample1.sam,samples/sample2.sam,samples/sample3.sam --labels sample1,sample2,sample3 --mapq 15 --out results/test.txt


=cut
