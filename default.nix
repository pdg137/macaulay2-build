let
  pkgs = import <nixpkgs> {};

  # Include downloads of additional source from the Macaulay 2 website
  # that are required for the build.
  #
  # Note that several of these packages are only available at
  # macaulay2.com, or the format of the downloads is slightly
  # different there from the official release.
  #
  # TODO: build and install these as separate packages, to make the
  # build more modular.
  #
  # TODO: build documentation separately, since it takes a long time
  # (maybe half of the total build time?) and isn't necessary.

  m2download = args: pkgs.fetchurl {
    url = "http://macaulay2.com/Downloads/OtherSourceCode/${builtins.elemAt args 0}";
    hash = builtins.elemAt args 1;
  };

  downloads = map m2download [
    # unavailable?
    ["cohomCalg-0.32.tar.gz" "sha256-NnxSuZwLCkeUshUYFDm/VKvkmYhy0+8l15O8E8TUDkI="]
    ["factory-4.2.1.tar.gz" "sha256-OjE12Nnom8pRKyLIhY8+A/RLFWKd9vAwnOT33e3QmhU="]
    ["factory.4.0.1-gftables.tar.gz" "sha256-nNFYzrHCscR73KLAsAS7qSyw4Kqg6mpDynhOvc4Q7r0="]
    ["frobby_v0.9.0.tar.gz" "sha256-rwkjg+bchJyG9OeXR64OXNMJppB0cjDhCqONYGQAYt8="]
    ["lrslib-071a.tar.gz" "sha256-kmY26mjeRmJfFB9uAl3OlnzH5oz0v0pZc3XAY/XBFnM="]
    ["normaliz-3.9.2.tar.gz" "sha256-Q0JlKB1KwaTgxEBANlmk/5KDRQi7T5LA0mI4e0ShjuA="]
    ["TOPCOM-0.17.8.tar.gz" "sha256-P4O5j1HuhZ7DIbrKv3sXLCWITxSEirbGKDJrmHvYqqs="]
  ];

in
  pkgs.stdenv.mkDerivation rec {
    name = "M2";
    builder = "${pkgs.bash}/bin/bash";
    args = [ ./builder.sh ];

    buildInputs = with pkgs; [
      autoconf
      automake
      bison # not checked by M2 autoconf but required late in the build
      boost
      eigen
      gcc
      gfortran
      libffi
      libtool
      libxml2
      libz
      lsb-release
      lzma
      ncurses
      perl # not checked by M2 autoconf but required to build ntl
      pkg-config
      tbb
      texinfoInteractive # surprise requirement at the very last step of the build!

      # packages normally downloaded during the build
      gmp
      gtest
      gtest.dev
      gtest.src
      readline
      lapack
      boehmgc
      gdbm
      _4ti2
      cddlib
      csdp
      flint
      gfan
      glpk
      libatomic_ops
      mpfi
      mpfr
      mpsolve
      nauty
      ntl

      # surprise requirement for _4ti2 (markov script will not run without it)
      # see https://github.com/NixOS/nixpkgs/issues/309745
      which

      # submodules normally built
      givaro
      fflas-ffpack
      blas
    ];

    link_downloads =
      map
        (file: "ln -s ${file.outPath} src/M2/BUILD/tarfiles/${file.name};")
        downloads;

    configureArgs = [
      # Autoconf does not seem to be able to identify the Boost version
      # without these explicit arguments.
      "--with-boost=${pkgs.boost.dev}"
      "--with-boost-libdir=${pkgs.boost}/lib"
      "--with-system-gc"

      # Disable the documentation since this takes forever and currently fails.
      "--disable-documentation"

      # Point to gtest source (why does it need this?)
      "--with-gtest-source-path=${pkgs.gtest.src}/googletest"
    ];

    # configure looks for
    # - cddlib in /usr/local, etc.
    # - <gtest/gtest.h>
    cppflags = "-I${pkgs.cddlib}/include/cddlib -I${pkgs.gtest.dev}/include";

    # This fixes several issues with the make process that should
    # probably be submitted as pull requests to M2.
    #
    # * two problems with building submodules: removing one gratuitous
    #   call to git and adding "sh" in one place where the makefile
    #  assumed a shell script would be executable.
    #
    # * removing use of the "time" program (not shell builtin) in a
    #   single place, an unnecessary dependency that broke the build
    #   on the very last step.
    #
    # * remove double-quotes in output from NixOS (and other versions)
    #   of lsb_release, which break quoting in include files.
    patch = ./macaulay2.patch;

    src = pkgs.fetchFromGitHub {
      owner = "Macaulay2";
      repo = "M2";
      # 1.23 release
      rev = "ec65028f1527076b663279b1311188caa9e22b67";
      hash = "sha256-uD1fpz9Awa+4W55C5BRPxIIxrLXffQx4b3JvpJ+QMc0=";
      fetchSubmodules = true;
    };
  }
