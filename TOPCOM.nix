# This package is not on GitHub.
# See https://www-cgrl.cs.mcgill.ca/~avis/C/lrs.html

{pkgs ? import <nixpkgs> {}}:
  pkgs.stdenv.mkDerivation rec {
    version = "0.17.8";
    name = "topcom-${version}";
    builder = "${pkgs.bash}/bin/bash";
    args = [ build-script ];

    src = builtins.fetchTarball {
      url = "https://www.wm.uni-bayreuth.de/de/team/rambau_joerg/TOPCOM-Downloads/TOPCOM-0_17_8.tgz";
      sha256 = "sha256:1qdsp5z3f7a4casc209wkbazg370n1hpligzdfb1ywd7jk11g86m";
    };

    build-script = pkgs.writeScript "builder.sh" ''
      source $stdenv/setup
      set -xe
      cp --no-preserve=mode -r $src src
      cd src
      sh ./configure --prefix=$out $configureArgs
      make
      make install
      '';

    buildInputs = with pkgs; [
      m4

      # not sure why these are needed since TOPCOM also builds its own...
      cddlib
      gmpxx
      gmp
    ];

    }
