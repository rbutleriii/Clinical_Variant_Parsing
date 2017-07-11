#!/usr/bin/perl

##v0.1.0 Robert R Butler III on 5/17/2017
##use rsID list as input to generate annovar avinput file

use strict;
use warnings;

my $anno_avsnp_file = "/ghi/butlerr/opt/annovar/humandb/hg19_avsnp147.txt"; # full path to avsnp file
my $usage = qq(USAGE = perl convertrsid2annovar.pl *rsidlist.txt); # gimme the right inputs

@ARGV or die $usage;
open(IN2, "$anno_avsnp_file") or die "Can't open avsnp file: $!\n";
while (my $file = shift@ARGV){
	open(IN, "$file") or die "Can't open $file: $!\n$usage\n";
	$file =~ s/.txt$//; # rename out
	open(OUT, ">$file.avinput");
	chomp(my @rsID = <IN>); # rsIDs to array
	my %rsIDbatch = map { $_ => 1 } @rsID; # mapping rsIDs to keys of hash
	while (my $line = <IN2>){ # sifting through avsnp file to find matches
		chomp $line;
		$line =~ /((?:rs)?\d+)$/; #rsID in avsnp file
		if (exists $rsIDbatch{$1}){
			print OUT "$line\n";
		} else { next; }
	}
	close IN;
	close OUT;
}
close IN2;
