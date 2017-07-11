#!/usr/bin/perl

##v0.1.0 Robert R Butler III on 4/25/2017
##grabbing a set of columns from a tab separated text file(s)
##columns defined by text file with list of column headers
##assumes first uncommented row is headers, and asks for first header

use strict;
use warnings;
use Array::Utils qw(:all);

my $usage = 'USAGE = perl listed_columns.pl column.list *.txt'; #gimme the right inputs

my $listfile = shift@ARGV or die "$usage";
open(LIST, "<$listfile") or die "Couldn't open $listfile\n$usage";
my @list;
while (my $line = <LIST>){
	chomp $line;
	push @list, $line;
}
close LIST;
my $firstcol = $list[0] or die "Unable to read first column";
while (my $file = shift@ARGV){
	open(IN, "<$file");
	$file =~ s/.txt$//;
	open(OUT, ">$file.filtered.txt");
	my @headers;
	my @row;
	my @sublist;
	my %probeset;
	while (my $line = <IN>){
		chomp $line;
		if ($line =~ /^#/){
			print OUT "$line\n";
		} elsif ($line =~ /^$firstcol/){
			@headers = split(/\t/, $line); #defining column names
			for (@headers){s/ /_/g}; #changing " " to "_"
			for (@headers){s/"//g}; #changing " to nothing
			@sublist = intersect(@headers, @list);
			print OUT join("\t", @sublist), "\n"; #print header to file
		} else { 
			@row = split(/\t/, $line); # breaking up columns in row
			for (@row){s/ /_/g}; #changing " " to "_"
			for (@row){s/"//g}; #changing " to nothing
			@probeset{@headers} = @row; #assigning keys to row values
			print OUT join("\t", @probeset{@sublist}), "\n";
		}
	}
	close IN;
	close OUT;
}
