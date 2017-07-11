#!/usr/bin/perl

##v0.1.0 Robert R Butler III on 5/23/2017
##takes Clean table from new_clinvar_parse.pl, adds a summed score column for the Submission_Details field
##scores are Benign(-5);Likely benign(-3);Uncertain significance(0);Likely pathogenic(4);Pathogenic(5)

use strict;
use warnings;

my $usage = qq(USAGE = perl conflicting_inter_score.pl "Clean_variant_info_oneline.txt"); #gimme the right inputs

open(my $OUT, '>', "Variants_with_invitae_scores.txt");
my $file = shift@ARGV or die $usage;
my ($hash_ref, $names_ref) = tablehash($file, sub { my ($row) = @_; "$row->{VariationID}|$row->{rsID}|$row->{Ref}|$row->{Alt}" }, "VariationID", '\d+');
my @outnames = (@$names_ref, "conflict_score");
print $OUT join ("\t", @outnames), "\n";
for my $keys (keys %{ $hash_ref }){
	my ($B, $LB, $LP, $P) = (0, 0, 0, 0);
	my $confscore = 0;
#	print "$hash_ref->{$keys}{VariationID} $confscore $B $LB $LP $P\n";
	if ($hash_ref->{$keys}{Submission_Details} =~ /Benign\((\d+)\)/ ){
		$B += $1;
	}
	if ($hash_ref->{$keys}{Submission_Details} =~ /benign\((\d+)\)/ ){
		$LB += $1;
	}
	if ($hash_ref->{$keys}{Submission_Details} =~ /pathogenic\((\d+)\)/ ){
		$LP += $1;
	}
	if ($hash_ref->{$keys}{Submission_Details} =~ /Pathogenic\((\d+)\)/ ){
		$P += $1;
	}
	$confscore += (($B * -5) + ($LB * -3) + ($LP * 4) + ($P * 5));
#	print "$hash_ref->{$keys}{VariationID} $confscore $B $LB $LP $P\n";
	for (@$names_ref){
		print $OUT "$hash_ref->{$keys}{$_}\t";
	}
	print $OUT "$confscore\n";
}

###############subroutines########################
##sub to generate table hash from file w/ headers
sub tablehash	{ # input values are file, uid, header starter, row starter, column number to keep; returns hash reference (deref it)
	my ($file, $mkuid, $headstart, $rowstart, $colnum) = @_;
	$colnum //= 0; # takes care of a unknown number of columns
	open(my $IN, '<', $file) or die "$0: can't open $file: $!\n";
	my %table; # permanent table 
	my @names; # column headers
	while (my $line = readline $IN){ # reading lines for lof info
		chomp $line;
		my %row; # hash of column values for each line/row
		my @values; # line/row values
		if ($line =~ /^$headstart/){
			@names = split(/\t/, $line, $colnum); # column names, limited by max num
			for (@names){s/ /_/g}; # replacing " " with "_"
			for (@names){s/"//g}; # getting rid of "
			for (@names){s/,/;/g}; #"," => ";"
		} elsif ($line =~ /^$rowstart/){ # splitting lof info columns into variables
			@values = split(/\t/, $line, $colnum); # column values, limited by max num
			for (@values){s/ /_/g}; # replacing " " with "_"
			for (@values){s/"//g}; # getting rid of "
			for (@values){s/,/;/g}; # "," => ";"
			@row{@names} = @values;
			my $uid = $mkuid->(\%row);
			$table{$uid} = { %row }; # putting row hash into permanent hash (with uid key)
		}
	}
	close $IN;
	return (\%table, \@names);
}
