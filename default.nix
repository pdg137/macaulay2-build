let
  pkgs = import <nixpkgs> {};

  tarfile_libatomic = pkgs.fetchurl {
    url = "https://www.hboehm.info/gc/gc_source/libatomic_ops-7.6.2.tar.gz";
    hash = "sha256-IZck7a09WA1NN7IuHXy1LwAG0oLSapuGgbVgpiUULuY=";
  };

  tarfile_gc = pkgs.fetchurl {
    url = "https://www.hboehm.info/gc/gc_source/gc-8.0.4.tar.gz";
    hash = "sha256-Q2oN3GexrAsEBbYalnW8qeB1yBVvTevR0G86VsfNKJ0=";
  };

  tarfile_gdbm = pkgs.fetchurl {
    url = "ftp://prep.ai.mit.edu/gnu/gdbm/gdbm-1.9.1.tar.gz";
    hash = "sha256-YCWFJjd3KwaZ8ilLXxT9SghLyjyBYdKdZNHzDW0amu0=";
  };

  tarfile_gmp = pkgs.fetchurl {
    url = "ftp://ftp.gnu.org/gnu/gmp/gmp-6.1.0.tar.bz2";
    hash = "sha256-SYRJqZTv66UniFwQQFmTQnmV0/hrh2jYzfjZ3Xxrc+g=";
  };

  tarfile_mpfr = pkgs.fetchurl {
    # updated versions available at http://www.mpfr.org/
    url = "http://macaulay2.com/Downloads/OtherSourceCode/mpfr-4.0.2.tar.xz";
    hash = "sha256-HTvnCGBOrg5C1Xi6k7OQwqFF8XdDp0TY8/jCrVhVo4o=";
  };

  tarfile_mpfi = pkgs.fetchurl {
    # original seems a little different:
    # https://gitlab.inria.fr/mpfi/mpfi/-/archive/1.5.4/mpfi-1.5.4.tar.gz
    url = "http://macaulay2.com/Downloads/OtherSourceCode/mpfi-1.5.4.tar.gz";
    hash = "sha256-MuatUpyXqlzgPijQHJIdG84aRk+0xX+8JI174h5lJ4I=";
  };

  tarfile_readline = pkgs.fetchurl {
    url = "ftp://ftp.gnu.org/gnu/readline/readline-8.2.tar.gz";
    hash = "sha256-P+txcfFqhO6CyhijbXub4QmlLAT0kqBTMx19EJUAfDU=";
  };

  tarfile_ntl = pkgs.fetchurl {
    # note: later releases available on https://github.com/libntl/ntl
    url = "https://libntl.org/ntl-10.5.0.tar.gz";
    hash = "sha256-uQs2yd2JVMm8VEELHVfAC+lWrh21oGKUWCK716hqtNI=";
  };

  tarfile_flint = pkgs.fetchurl {
    url = "https://flintlib.org/flint-2.8.4.tar.gz";
    hash = "sha256-Yd+S6oyOncaS1Gxx1/UKqgmjPUugjQKheEcwpEXl5L4=";
  };

  link_tarfile =
    file: "ln -s ${file.outPath} src/M2/BUILD/tarfiles/${file.name};";

in
  pkgs.stdenv.mkDerivation rec {
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
        link_tarfile
        [
          tarfile_libatomic
          tarfile_gc
          tarfile_gdbm
          tarfile_gmp
          tarfile_mpfr
          tarfile_mpfi
          tarfile_ntl
          tarfile_readline
          tarfile_flint
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
