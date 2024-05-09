{pkgs ? import <nixpkgs> {}}:
  pkgs.stdenv.mkDerivation rec {
    name = "frobby";
    builder = "${pkgs.bash}/bin/bash";
    args = [ build-script ];

    src = pkgs.fetchFromGitHub {
      owner = "Macaulay2";
      repo = "frobby";
      rev = "ae88a0bd93af2d7819db719e51b74eae713d7739"; # latest 2024-04-06
      hash = "sha256-F8WmqdhUtU/Sa7Zz+gRE61PuoIATEv/JIkHkqHdzzac=";
    };

    build-script = pkgs.writeScript "builder.sh" ''
      source $stdenv/setup
      set -xe
      cp --no-preserve=mode -r $src src
      mkdir -p $out/include
      cp --no-preserve=mode $src/src/*.h $out/include/
      cd src
      make
      make library MODE=shared
      export PREFIX=$out
      export BIN_INSTALL_DIR=$out/bin
      make install
      '';

    buildInputs = with pkgs; [
      gmp
    ];

    }
