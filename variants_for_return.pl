#!/usr/bin/perl
 
#v0.1.1 Robert R Butler III on 3/6/2017
#Return variants specified by input *ID.txt list from affy tab delimited txt file for review 
#Input IDs not in affy table will be called out, can accept VarID or rsID
#Affy table must not have "," in field values, change all to something else first
#Reads each line and defines variable for Header field (replaces " " with "_"; and '"' with '')

use strict;
use warnings;
use Data::Dumper qw(Dumper); #for debug
use Getopt::Std;

##options and usage
my %options;
getopts("v:r:h", \%options);
my $usage = 'USAGE = perl variants_for_return.pl [-v *VarID.txt | -r *rsID.txt] *affy.tab-delimited.txt'; #gimme the right inputs
if ($options{h}){ die $usage; }

my $keyterm;
my %VarIDs;
if($options{v}) {
	load($options{v});
	$keyterm = "VariationID";
} elsif($options{r}) {
	load($options{r});
	$keyterm = "dbSNP.RS.ID";
} else { die $usage; }

##loading Affy chip hash (%table)
my $file = $ARGV[0] or die $usage; #going through text file and making outfile
open(IN,"$file");
open(OUT,">vfr.temp");
my %row; # hash of column values for each line/row
my %table; #hash of row hashes
my @names = (); #column headers
my @values = (); #line/row values
my $affyID; #Probe.Set.ID is unique key for table hash
while (my $line = <IN>){ #reading lines for variant info
	chomp $line;
	if ($line =~ /^VariationID/){
		@names = split(/\t/, $line); #column names
		for (@names){s/ /_/g}; #replacing " " with "_"
		for (@names){s/"//g}; #getting rid of "
	} elsif ($line =~ /\S+/){ #splitting variant info columns into variables
		@values = split(/\t/, $line);
		for (@values){s/"//g}; #getting rid of "
		@row{@names} = @values;
		$affyID = $values[1]; #defining subhash by Probe.Set.ID
		for my $name (keys %row){
			$table{$affyID}{$name} = $row{$name}; #putting values into hash
		}
	} else {next;}
}
close IN;
##end loading Affy chip hash (%table)

##sub load query list
sub load{
	my $inputfile = $_[0] or die $usage; #opening VarID input list
	open(IN2,"$inputfile");
	while (my $line = <IN2>){ #filling hash keys with list
		chomp $line;
		$VarIDs{$line} = ();
	} 
	close IN2;
	return %VarIDs;
}
##end sub load query list

##print desired list to file
my @headers = ("VariationID", "dbSNP.RS.ID", "GeneName", "OmimDisease", "FullCADD", "ClinVar_Significance", "Number_of_Submissions", "Submission_Details", "Invitae_Sig", "GeneDx_Sig", "Ambry_Sig"); #new columns
print OUT join("\t", @headers), "\n";#printing header
shift@headers; #remove VID from array for printing on line 63
for my $key (sort { $table{$a}{VariationID} <=> $table{$b}{VariationID} || $table{$a}{"Probe.Set.ID"} cmp $table{$b}{"Probe.Set.ID"} } keys %table){
	for my $VarID (keys %VarIDs){ #above sort by VariationID then Probe.Set.ID
		if ($table{$key}{$keyterm} eq $VarID){ #search for matching VarIDs
			print OUT "$table{$key}{VariationID}"; #no tab in front of first column
			for my $header (@headers){ #print tab separated row for each "Probe.Set.ID" key found in VarIDs
				print OUT "\t$table{$key}{$header}";
			}
			print OUT "\n"; #line return
		} else {next;}
	}
}
close OUT;
#end print desired list to file

##Finding VarIDs not in Affy table
for my $VarID (keys %VarIDs){ #search through list of VIDs
	my $VIDcount = 0;
	for my $key (keys %table){
		if ($VarID eq $table{$key}{$keyterm}){ #count number of VID matches in Affy table
			$VIDcount++;
		} else {next;}
	}
	if ($VIDcount == 0){ #if VID from list not found in Affy table, report
		print "UID $VarID was not found in Affy Table\n";
	} else {next;}
}
##end Finding VarIDs not in Affy table

##ditch duplicates
system 'sort -u vfr.temp | sort -k 1,1n > variants_for_return.txt';
system 'rm vfr.temp';

#print Dumper \%clinsubs; #for debug
#print Dumper \%clinobs; #for debug

