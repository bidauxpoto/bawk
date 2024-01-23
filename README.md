# bawk

### Installation using conda:
```conda install -c molinerislab bawk```

### Description:
A wrapper on ```gawk``` implementing the ability to name the columns of the input file according to the header.

### Usage and options:
```
bawk [--debug] [-f makefile] [-e|extended] [-v|assing var=val] [-M|meta] '{awk program}' INPUT_FILE

  -e|extend            change the regexp used to identify named fields: a named field like $$NF (with a double $)
                       is passed to awk as $NF and doesn't trigger the logic of named fields.
                       Be careful with the -e option: do not confuse $NF with NF. It is useful only if you want
                       to use a variabile to indicate a field number or if you want to pass shell variables to awk.
  -M|meta              print the .META for the given file and exit
  -v|assign var=val    assign the val to the variable var inside the bawk program
  -f makefile          ...
  --debug              ...

```

__________________________________
### Example:
protein_coding_genes.bed
```
#chromosome     start               end	          gene_id                 strand	gene_type	  gene_name
chr1	        13341892	    13347134	  ENSG00000204481	  -	        protein_coding	  PRAMEF14
chr1	        19882395	    19912945	  ENSG00000169914	  +	        protein_coding	  OTUD3
chr3	        128879596	    128924003	  ENSG00000177646	  +	        protein_coding	  ACAD9
chr5	        181193924	    181205293	  ENSG00000146054	  -	        protein_coding	  TRIM7
chr9	        108854588	    108855986	  ENSG00000148156	  -	        protein_coding	  ACTL7B
chr10	        100735396	    100829944	  ENSG00000075891	  +	        protein_coding	  PAX2
chr11	        65892049	    65900573	  ENSG00000175592	  -	        protein_coding	  FOSL1
chr13	        27977717	    27988693	  ENSG00000183463	  -	        protein_coding	  URAD
chr14	        74019349	    74082863	  ENSG00000119636	  +	        protein_coding	  BBOF1
chr18	        78979818	    79002677	  ENSG00000256463	  +	        protein_coding	  SALL3
chr18	        79970813	    80033949	  ENSG00000141759	  -	        protein_coding	  TXNL4A
chr21	        34418715	    34423951	  ENSG00000243627	  -	        protein_coding	  SMIM34
chr22	        19714503	    19724224	  ENSG00000184702	  +	        protein_coding	  SEPTIN5
chrX	        68829021	    68842160	  ENSG00000090776	  +	        protein_coding	  EFNB1
```

The command ```bawk '{print $gene_id"\t"$gene_name}' protein_coding_genes.bed``` returns:
```
gene_id          gene_name
ENSG00000204481  PRAMEF14
ENSG00000169914  OTUD3
ENSG00000177646  ACAD9
ENSG00000146054  TRIM7
ENSG00000148156  ACTL7B
ENSG00000075891  PAX2
ENSG00000175592  FOSL1
ENSG00000183463  URAD
ENSG00000119636  BBOF1
ENSG00000256463  SALL3
ENSG00000141759  TXNL4A
ENSG00000243627  SMIM34
ENSG00000184702  SEPTIN5
ENSG00000090776  EFNB1
```
