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
      wget # TODO replace with our own downloader
    ];

    configureArgs = [
      "--with-boost=${pkgs.boost.dev}"
      "--with-boost-libdir=${pkgs.boost}/lib"
      "--enable-download" # TODO replace with our own downloader
    ];

    src = pkgs.fetchFromGitHub {
      owner = "Macaulay2";
      repo = "M2";
      rev = "b471161db89aa8665362c8b04067a38b39c00932";
      hash = "sha256-jsueoBtM83wfp+YXSS9xY8MRhYxFp4+Ja6lcFcbR5SQ=";
      fetchSubmodules = true;
    };
  }
