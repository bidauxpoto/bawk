#!/bin/bash
#
# Copyright 2008,2010 Ivan Molineris <ivan.molineris@gmail.com>; 2008,2010 Gabriele Sales <gbrsales@gmail.com>

#This scirpt detect if the special extension made available in the perl script bawk_ext are required, if are not required then use the standard and quicker gawk directly



full_version="no"
if [[ $@ =~ \.gz$ ]] || [[ $@ =~ \.xz$ ]]; then
    full_version="yes"
fi


for i in "$@"; do
	if [[ $i == "-M" ]] || [[ ${i:0:1} == '-' ]] || [[ $i =~ \$[0-9]*_?[a-zA-Z] ]] || [[ $i =~ \$[0-9]+~[0-9]+ ]]; then
		full_version="yes"
		break
	fi
done


if [[ $full_version == "yes" ]]; then
    bawk_ext.pl -v OFMT='%.17g' -v CONVFMT='%.17g' "$@"
else
    export LC_ALL=POSIX
    exec gawk -F'\t' -v OFS='\t' -v OFMT='%.17g' -v CONVFMT='%.17g' --re-interval "$@"
fi
