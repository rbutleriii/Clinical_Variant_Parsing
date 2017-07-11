#!/usr/bin/perl
##File::Compare quick usage script
##v0.1.0 Robert R Butler III on 4/25/2017

use strict;
use warnings;
use File::Compare;

my $usage = 'perl file_compare.pl file1 file2';

my $file1 = $ARGV[0] or die $usage;
my $file2 = $ARGV[1] or die $usage;
if (compare($file1, $file2) == 0) {
	print "They're the same\n";
} else {
	print "They're different\n";
}
