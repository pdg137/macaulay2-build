let
  pkgs = import <nixpkgs> {};

  my-cohomCalg = import ./cohomCalg.nix { inherit pkgs; };
  my-frobby = import ./frobby.nix { inherit pkgs; };
  my-normaliz = import ./normaliz.nix { inherit pkgs; };
  my-lrslib = import ./lrslib.nix { inherit pkgs; };
  my-TOPCOM = import ./TOPCOM.nix { inherit pkgs; };
  my-singular-factory = import ./singular-factory.nix { inherit pkgs; };

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

      # Packages not available in nixpkgs, defined above
      my-cohomCalg
      my-normaliz
      my-frobby
      my-lrslib
      my-TOPCOM
      my-singular-factory
    ];

    # M2 expects to find a link to some programs here or on the path:
    link_programs = ''
      mkdir -p $out/libexec/Macaulay2/bin/ &&
      ln -s ${my-normaliz}/bin/normaliz $out/libexec/Macaulay2/bin/
    '';

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
