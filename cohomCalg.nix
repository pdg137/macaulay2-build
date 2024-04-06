{pkgs ? import <nixpkgs> {}}:
  pkgs.stdenv.mkDerivation rec {
    name = "cohomCalg";
    builder = "${pkgs.bash}/bin/bash";
    args = [ build-script ];

    src = pkgs.fetchFromGitHub {
      owner = "BenjaminJurke";
      repo = "cohomCalg";
      rev = "v0.32";
      hash = "sha256-9kKKfb8STiCjaHiWgYEQsERNTnOXlwN8axIBJHg43zk=";
    };

    build-script = pkgs.writeScript "builder.sh" ''
      source $stdenv/setup
      set -xe
      cp --no-preserve=mode -r $src src
      cd src
      make
      mkdir -p $out/bin
      cp bin/cohomcalg $out/bin
      '';

    buildInputs = with pkgs; [
    ];

    }
