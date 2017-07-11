# Clinical_Variant_Parsing
Utilities to mine clinical variant info


<b>variants_for_return.pl</b> - Return variants specified by input *ID.txt list from affy tab delimited txt file for review

<b>rsidtovid.pl</b> - takes a list of rsids, removes dulicates, fetches variation ids from ClinVar

<b>listed_columns.pl</b> - grabs a subset of columns from a tab separated text file(s)

<b>file_compare.pl</b> - File::Compare quick usage script

<b>convertrsid2annovar.pl</b> - use rsID list as input to generate Annovar (Wang, 2010) avinput file

<b>conflicting_inter_score.pl</b> - takes Clean table from new_clinvar_parse.pl, adds a summed conflicting interpretations score column for the Submission_Details field


Wang K, Li M, Hakonarson H. ANNOVAR: Functional annotation of genetic variants from next-generation sequencing data Nucleic Acids Research, 38:e164, 2010
