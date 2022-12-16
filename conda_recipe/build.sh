#!/bin/bash


mkdir -p $PREFIX/bin/
cp bawk_ext.pl $PREFIX/bin/
cp bawk.sh $PREFIX/bin/bawk
cp MakefileParser.pm $PREFIX/bin/
chmod +x $PREFIX/bin/