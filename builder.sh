source $stdenv/setup

set -xe

# copy M2 source to working dir
cp --no-preserve=mode -r $src src

# link downloaded tar files
eval $link_downloads

# link required programs that aren't found otherwise
eval $link_programs

cd src/M2
patch -p0 < $patch

export CPPFLAGS=$cppflags

make
./configure --prefix=$out $configureArgs
make
make install
