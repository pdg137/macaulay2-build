{pkgs ? import <nixpkgs> {}}:
  pkgs.stdenv.mkDerivation rec {
    name = "normaliz";
    builder = "${pkgs.bash}/bin/bash";
    args = [ build-script ];

    src = pkgs.fetchFromGitHub {
      owner = "Normaliz";
      repo = "Normaliz";
      rev = "v3.10.2";
      hash = "sha256-Q4OktVvFobP25fYggIqBGtSJu2HsYz9Tm+QbEAz0fMg=";
    };

    build-script = pkgs.writeScript "builder.sh" ''
      source $stdenv/setup
      set -xe
      cp -r $src src
      chmod -R u+w src
      cd src
      mkdir -p local/bin # a random ls command in the build needs this
      export PREFIX=$out
      export NMZ_PREFIX=$out
      export NMZ_SHARED=1 # static did not work for me
      ./install_normaliz.sh
      '';

    buildInputs = with pkgs; [
      autoconf
      automake
      gmp
      boost
      libtool
    ];

    }
