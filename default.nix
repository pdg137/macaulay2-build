let
  pkgs = import <nixpkgs> {};

  m2download = args: pkgs.fetchurl {
    url = "http://macaulay2.com/Downloads/OtherSourceCode/${builtins.elemAt args 0}";
    hash = builtins.elemAt args 1;
  };

  downloads = map m2download [
    ["cddlib-0.94m.tar.gz" "sha256-cN/9szabhwTcdUKKGzxCq5BHuBzgOfEvQn4usrGw3uI="]
    ["factory-4.2.1.tar.gz" "sha256-OjE12Nnom8pRKyLIhY8+A/RLFWKd9vAwnOT33e3QmhU="]
    ["flint-2.8.4.tar.gz" "sha256-Yd+S6oyOncaS1Gxx1/UKqgmjPUugjQKheEcwpEXl5L4="]
    ["frobby_v0.9.0.tar.gz" "sha256-rwkjg+bchJyG9OeXR64OXNMJppB0cjDhCqONYGQAYt8="]
    ["gc-8.0.4.tar.gz" "sha256-Q2oN3GexrAsEBbYalnW8qeB1yBVvTevR0G86VsfNKJ0="]
    ["gdbm-1.9.1.tar.gz" "sha256-YCWFJjd3KwaZ8ilLXxT9SghLyjyBYdKdZNHzDW0amu0="]
    ["glpk-4.59.tar.gz" "sha256-45i+Lny4qYWEMlJocEcphyVYpKiFVbyKVBOdAX65664="]
    ["gmp-6.1.0.tar.bz2" "sha256-SYRJqZTv66UniFwQQFmTQnmV0/hrh2jYzfjZ3Xxrc+g="]
    ["libatomic_ops-7.6.2.tar.gz" "sha256-IZck7a09WA1NN7IuHXy1LwAG0oLSapuGgbVgpiUULuY="]
    ["mpfi-1.5.4.tar.gz" "sha256-MuatUpyXqlzgPijQHJIdG84aRk+0xX+8JI174h5lJ4I="]
    ["mpfr-4.0.2.tar.xz" "sha256-HTvnCGBOrg5C1Xi6k7OQwqFF8XdDp0TY8/jCrVhVo4o="]
    ["mpsolve-3.2.1.tar.gz" "sha256-PRFCiumrLgIPJMq/vNnk2bIuxXLPcK8NRP6Nrh1R544="]
    ["lapack-3.9.0.tgz" "sha256-EGCH8btfRq/fun9WnQy+I9rLmgfNJHM3ZaDonb4a1XM="]
    ["ntl-10.5.0.tar.gz" "sha256-uQs2yd2JVMm8VEELHVfAC+lWrh21oGKUWCK716hqtNI="]
    ["readline-8.2.tar.gz" "sha256-P+txcfFqhO6CyhijbXub4QmlLAT0kqBTMx19EJUAfDU="]
  ];

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
      map link_tarfile downloads;

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
