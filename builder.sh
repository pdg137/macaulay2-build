source $stdenv/setup

echo PATH=$PATH

# copy M2 source to working dir
cp --no-preserve=mode -r $src src
cd src/M2

make
./configure --prefix=$out
make
make install
