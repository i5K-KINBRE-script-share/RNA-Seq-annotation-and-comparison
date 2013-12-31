#!/bin/perl
##################################################################################
#   
#	USAGE: perl script.pl [options]
#
#  Created by jennifer shelton
#
##################################################################################
use strict;
use warnings;
# use List::Util qw(max);
# use List::Util qw(sum);
use Getopt::Long;
use Pod::Usage;
##################################################################################
##############         Print informative message                ##################
##################################################################################
print "#######################################################################\n";
print "# perl find_failed.pl -x [XML directory]                              #\n";
print "#                                                                     #\n";
print "#  Created by Jennifer Shelton 12/31/13                               #\n";
print "#  github.com/                                                        #\n";
print "#  perl script.pl -help # for usage/options                           #\n";
print "#  perl script.pl -man # for more details                             #\n";
print "#######################################################################\n";

##################################################################################
##############                get arguments                     ##################
##################################################################################
my $man = 0;
my $help = 0;
my $xml = "blasts";
GetOptions (
			  'help|?' => \$help, 
			  'man' => \$man,   
              'x|xml:s' => \$xml  
              )  
or pod2usage(2);
pod2usage(1) if $help;
pod2usage(-exitstatus => 0, -verbose => 2) if $man;
open OUTPUT, '>', "$xml/unfinished";
##################################################################################
##############                        run                       ##################
##################################################################################
my $i=1;
my @xmlfiles = `ls ${xml}/*.xml`;
chomp @xmlfiles;
for my $xmlfile (@xmlfiles)
{
	my $passed=`grep -c '</BlastOutput_iterations>' $xmlfile`;
	if ($passed)
	{
		my $fasta;
		$xmlfile =~ /(.*)(blasts\/)(.*)(_[0-9]*)\.xml/;
		print "1: $1\n";
		{
			if ($1)
			{
				$fasta= "$1split/$3$4.fasta";
			}
			elsif (!$1)
			{
				$fasta= "split/$3$4.fasta";
			}
		}
		open FASTA, '<',$fasta or die "Can't open $fasta!\n";
		$/ = ">"; ### each input will equal an entire fasta record
		while (<FASTA>)
		{
			chomp;
			if ($_)
			{
				my ($header, @seqLines) = split /\n/;
				$header =~ s/>//g;
				my $blasted=`grep -c "<Iteration_query-def>${header}" $xmlfile`;
				if ($blasted == 0)
				{
					print OUTPUT "${header}\n";
					my $seqString = join '', @seqLines;
					print OUTPUT "$seqString\n";
				}
			}
		}
		
	}
}

##################################################################################
##############                  Documentation                   ##################
##################################################################################
## style adapted from http://www.perlmonks.org/?node_id=489861 
__END__

=head1 NAME

find_failed.pl - a package of scripts that find fasta sequences that have not been blasted (e.g. when a running blastx times out)

=head1 USAGE

perl find_failed.pl -x [XML directory]

 Documentation options:
   -help    brief help message
   -man	    full documentation
 Required options:
   -x	    XMAP directory
 
   
=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the more detailed manual page with output details and examples and exits.

=item B<-x, --xmap>

The directory that your XMLs are in they are assumed to have been produced by blastx.pl. Do not include a trailing slash.


=back


=cut
