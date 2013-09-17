foreach my $f (@ARGV)
{
	my $concordant_pair_mapped_read=0;
	my $discordant_pair_mapped_read=0;
	my $unpaired_mate_mapped_reads=0; # only one end maps relatively unambiguously (above MAPQ cutoff) 
	my $single_end_mapped_reads=0;
	my %read_hash;
	my $file = IO::File->new($f);
	while (<$file>)
	{
		unless (/^\@/)
 	   {
	        @temp=split(/\t/);
	        unless ($count_hash{$temp[2]}) ## if we haven't seen the contig before add it to contig count_hash
	        {
	        	$count_hash{$temp[2]} =[@default];
	        }
################################ require pairs map to same contig ################################
	        if ($temp[6] eq '=')
	        {
################################ count concordant pairs ################################
	        	if ($_ =~ /YT:Z:CP/)
	        	{
	        		unless ($read_hash{$temp[0]})
	        		{
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
################################ count discordant pairs ################################	        		
	        	if ($_ =~ /YT:Z:DP/)
	        	{
	        		unless ($read_hash{$temp[0]})
	        		{
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
################# if one pair fails and one passes count broken pairs (UP) ################################	        		
	        if ($_ =~ /YT:Z:UP/)
	        	{
	        		unless ($read_hash{$temp[0]})
	        		{
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
################################# count single end reads (UU) ##################################	        		
	        if ($_ =~ /YT:Z:UU/)
	        	{
	        		if (($temp[4]>$mapq)&&($temp[4]!=255))
	        		{
	  	        		$count_hash{$temp[2]}->[$i]++; ## count one for a single end read read maps relatively unambiguously (above MAPQ cutoff)
	        			$single_end_mapped_reads++;
	        		}
	        	}
		}
	    print "$f concordant_pair_mapped_reads=$concordant_pair_mapped_read\n";
		print "$f discordant_pair_mapped_reads=$discordant_pair_mapped_read\n";
		print "$f unpaired_mate_mapped_reads=$unpaired_mate_mapped_reads\n";
		print "$f single_end_mapped_reads=$single_end_mapped_reads\n";
    }
    $i++;
	$file->close;
}
# foreach $j (0 .. $#samples) ## optional printing of sample ids, uncomment out lines 42 to 43 and lines 168 to 178 if you want a sample id row
# {
# 	if ($j < $#samples)
# 	{
# 		print COUNT_FILES "$samples[$j]\t";
# 	}
# 	else
# 	{
# 		print COUNT_FILES "$samples[$j]\n";
# 	}
# }
foreach $contig ( keys %count_hash ) ## print out table of raw counts
{
    print COUNT_FILES "$contig\t";
    foreach $k ( 0 .. $#{ $count_hash{$contig} } )
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

	
