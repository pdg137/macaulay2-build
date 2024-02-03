let
  pkgs = import <nixpkgs> {};
in
  pkgs.stdenv.mkDerivation {
    name = "M2";
    builder = "${pkgs.bash}/bin/bash";
    args = [ ./builder.sh ];

    buildInputs = with pkgs; [
      gcc
      autoconf
      automake
      libtool
      lsb-release
      pkg-config
      tbb
      eigen
      ncurses
      boost
      gfortran
      libz
      lzma
      libxml2
      libffi
    ];

    link_downloads =
      map
        (file: "ln -s ${file.outPath} src/M2/BUILD/tarfiles/${file.name};")
        [
          (pkgs.fetchurl {
            url = "https://www.hboehm.info/gc/gc_source/libatomic_ops-7.6.2.tar.gz";
            hash = "sha256-IZck7a09WA1NN7IuHXy1LwAG0oLSapuGgbVgpiUULuY=";
          })
          (pkgs.fetchurl {
            url = "https://www.hboehm.info/gc/gc_source/gc-8.0.4.tar.gz";
            hash = "sha256-Q2oN3GexrAsEBbYalnW8qeB1yBVvTevR0G86VsfNKJ0=";
          })
        ];

    configureArgs = [
      "--with-boost=${pkgs.boost.dev}"
      "--with-boost-libdir=${pkgs.boost}/lib"
    ];

    src = pkgs.fetchFromGitHub {
      owner = "Macaulay2";
      repo = "M2";
      rev = "b471161db89aa8665362c8b04067a38b39c00932";
      hash = "sha256-jsueoBtM83wfp+YXSS9xY8MRhYxFp4+Ja6lcFcbR5SQ=";
      fetchSubmodules = true;
    };
  }
