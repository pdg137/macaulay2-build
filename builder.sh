source $stdenv/setup

set -xe

# copy M2 source to working dir
cp --no-preserve=mode -r $src src

# link downloaded tar files
eval $link_downloads

cd src/M2
patch -p0 < $patch

make
./configure --help
echo $CPPFLAGS
export CPPFLAGS='-I${frobby}/include'
./configure --prefix=$out $configureArgs
make
make install
