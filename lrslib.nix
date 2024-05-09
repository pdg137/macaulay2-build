# This package is not on GitHub.
# See https://www-cgrl.cs.mcgill.ca/~avis/C/lrs.html

{pkgs ? import <nixpkgs> {}}:
  pkgs.stdenv.mkDerivation rec {
    version = "071a";
    name = "lrslib-${version}";
    builder = "${pkgs.bash}/bin/bash";
    args = [ build-script ];

    src = builtins.fetchTarball {
      url = "https://cgm.cs.mcgill.ca/~avis/C/lrslib/archive/lrslib-${version}.tar.gz";
      sha256 = "sha256:0a60pshqjcg2kpszj54qd9apmzgykcv865jm6bj4izkg1r4gsrq2";
    };

    build-script = pkgs.writeScript "builder.sh" ''
      source $stdenv/setup
      set -xe
      cp --no-preserve=mode -r $src src
      cd src
      make
      prefix=$out make install
      '';

    buildInputs = with pkgs; [
      gmp
    ];

    }
