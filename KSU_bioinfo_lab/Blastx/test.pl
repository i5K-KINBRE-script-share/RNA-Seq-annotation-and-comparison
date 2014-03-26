#!/usr/bin/perl

use strict;
use warnings;
use File::Slurp;

my $text = read_file('test_template_shell.txt');

my $out = "$text";

my $read1 = 'blag';
my $read2 = 'adsfaaf';

print eval quote($text);
print "\n";

sub quote { qq!"$_[0]"! }