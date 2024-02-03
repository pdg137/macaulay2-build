source $stdenv/setup

set -xe

echo PATH=$PATH

# copy M2 source to working dir
cp --no-preserve=mode -r $src src
cd src/M2

make
./configure --prefix=$out $configureArgs
make
make install
