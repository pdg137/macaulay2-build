{pkgs ? import <nixpkgs> {}}:
  pkgs.stdenv.mkDerivation rec {
    version = "4-2-1";
    name = "singular-factory-${version}";
    builder = "${pkgs.bash}/bin/bash";
    args = [ build-script ];

    src = pkgs.fetchFromGitHub {
      owner = "Singular";
      repo = "Singular";
      rev = "Release-${version}";
      hash = "sha256-gOzukCj9ucCcs3Rsw3/xKW1NshSxiJp25LP74jKxqcQ=";
    };

    build-script = pkgs.writeScript "builder.sh" ''
      source $stdenv/setup
      set -xe
      cp -r $src src
      chmod -R u+w src
      cd src/factory
      autoreconf -vif
      ./configure --prefix=$out $configureArgs --without-Singular
      make
      make install
      '';

    buildInputs = with pkgs; [
      autoconf
      automake
      gmp
      boost
      libtool
      ntl
    ];

    }
