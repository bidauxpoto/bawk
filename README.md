# bawk

### Installation using conda:
```conda install -c molinerislab bawk```

### Description:
A wrapper on ```gawk``` implementing the ability to name the columns of the input file according to the header.

### Usage and options:
```
bawk [--debug] [-f makefile] [-e|extended] [-v|assing var=val] [-M|meta] '{awk program}' INPUT_FILE

  -e|extend       change the regexp used to identify named fields: a named field like $$NF (with a double $)
                  is passed to awk as $NF ad do not trigger the logic of named fields.
                  Be careful with the -e option: do not confuse $NF with NF. It is useful only if you want
                  to use a variabile to indicate a field number or if you want to pass shell variables to awk.

  -M              print the .META for the given file and exit

  -v|assign var=val
                  assign the val to the variable var inside the bawk program

```

__________________________________
### Example:

