

#conda-build .
#update path and version!
#conda convert --platform all /home/mmasera_local/anaconda3/conda-bld/linux-64/bawk-1.0-pl5262_0.tar.bz2 -o outdir/
anaconda upload --user molinerislab outdir/linux-32/bawk-1.0-pl5262_0.tar.bz2
anaconda upload --user molinerislab outdir/linux-32/bawk-1.0-pl5262_0.tar.bz2
anaconda upload --user molinerislab outdir/linux-aarch64/bawk-1.0-pl5262_0.tar.bz2
anaconda upload --user molinerislab outdir/linux-armv6l/bawk-1.0-pl5262_0.tar.bz2
anaconda upload --user molinerislab outdir/linux-armv7l/bawk-1.0-pl5262_0.tar.bz2
anaconda upload --user molinerislab outdir/linux-ppc64/bawk-1.0-pl5262_0.tar.bz2
anaconda upload --user molinerislab outdir/linux-ppc64le/bawk-1.0-pl5262_0.tar.bz2
anaconda upload --user molinerislab outdir/linux-s390x/bawk-1.0-pl5262_0.tar.bz2
anaconda upload --user molinerislab outdir/osx-64/bawk-1.0-pl5262_0.tar.bz2
anaconda upload --user molinerislab outdir/osx-arm64/bawk-1.0-pl5262_0.tar.bz2