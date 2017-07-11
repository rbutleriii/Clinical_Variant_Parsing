#!/usr/bin/perl

##v0.0.1 Robert R Butler III on 5/4/2017 
##takes a list of rsids, removes dulicates, fetches variation ids from ClinVar
##will drop rs prefix from rsID

use strict;
use warnings;
use Data::Dumper qw(Dumper); #for debug
use List::MoreUtils qw(uniq);
##proxy configuration, comment out if unnecessary
use LWP::UserAgent;
$ENV{https_proxy} = 'http://proxy.enh.org:8080';

my $usage = 'USAGE = perl rsidtovid.pl *.rsidlists.txt'; #gimme the right inputs

##dealing with lists
my @sumlist; # total of all rsIDs
while (my $file = shift@ARGV){
	print "Parsing $file...\n";
	open(IN,"$file");
   chomp(my @list = <IN>);
	for (@list){s/rs//g}; # dropping rs prefix
   push @sumlist, @list;
   close IN;
}
open(OUT, ">rsIDs.temp");
my @uniqs = uniq(@sumlist);
print OUT join("\n",@uniqs), "\n";
close OUT;
##fetching
print "Fetching VIDS from NCBI...\n";
system qq(epost -db snp -input rsIDs.temp | elink -target clinvar | efetch -format uid > newVIDs.txt);
system qq(rm rsIDs.temp);
