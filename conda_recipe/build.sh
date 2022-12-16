#!/bin/bash

echo $PREFIX
mkdir -p $PREFIX/bin/
cp bawk_ext.pl $PREFIX/bin/
cp bawk.sh $PREFIX/bin/
cp MakefileParser.pm $PREFIX/bin/
chmod +x $PREFIX/bin/