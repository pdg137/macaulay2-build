let
  pkgs = import <nixpkgs> {};

  # Include downloads of additional source from the Macaulay 2 website
  # that are required for the build. We could have just used their
  # "fat" download but this way is more flexible and will allow
  # building alternative unreleased versions of M2.
  #
  # Note that several of these packages are only available at
  # macaulay2.com, or the format of the downloads is slightly
  # different there from the official release.

  m2download = args: pkgs.fetchurl {
    url = "http://macaulay2.com/Downloads/OtherSourceCode/${builtins.elemAt args 0}";
    hash = builtins.elemAt args 1;
  };

  downloads = map m2download [
    ["4ti2-1.6.9.tar.gz" "sha256-MFPnRntVha2FL2pW544oNSZTlD5ySa1eUXTUdE0XSWY="]
    ["cddlib-0.94m.tar.gz" "sha256-cN/9szabhwTcdUKKGzxCq5BHuBzgOfEvQn4usrGw3uI="]
    ["cohomCalg-0.32.tar.gz" "sha256-NnxSuZwLCkeUshUYFDm/VKvkmYhy0+8l15O8E8TUDkI="]
    ["Csdp-6.2.0.tgz" "sha256-fyAqFfM0g+4gXc+9BXP9vXSRFgS7c5oE+LqjX4oFXFs="]
    ["factory-4.2.1.tar.gz" "sha256-OjE12Nnom8pRKyLIhY8+A/RLFWKd9vAwnOT33e3QmhU="]
    ["factory.4.0.1-gftables.tar.gz" "sha256-nNFYzrHCscR73KLAsAS7qSyw4Kqg6mpDynhOvc4Q7r0="]
    ["flint-2.8.4.tar.gz" "sha256-Yd+S6oyOncaS1Gxx1/UKqgmjPUugjQKheEcwpEXl5L4="]
    ["frobby_v0.9.0.tar.gz" "sha256-rwkjg+bchJyG9OeXR64OXNMJppB0cjDhCqONYGQAYt8="]
    ["gc-8.0.4.tar.gz" "sha256-Q2oN3GexrAsEBbYalnW8qeB1yBVvTevR0G86VsfNKJ0="]
    ["gdbm-1.9.1.tar.gz" "sha256-YCWFJjd3KwaZ8ilLXxT9SghLyjyBYdKdZNHzDW0amu0="]
    ["gfan0.6.2.tar.gz" "sha256-pnTV5dxDY0OX3g1V3V2jwyvTWNBfcrc6UOYsGhaG8Qo="]
    ["glpk-4.59.tar.gz" "sha256-45i+Lny4qYWEMlJocEcphyVYpKiFVbyKVBOdAX65664="]
    ["gmp-6.1.0.tar.bz2" "sha256-SYRJqZTv66UniFwQQFmTQnmV0/hrh2jYzfjZ3Xxrc+g="]
    ["gtest-1.10.0.tar.gz" "sha256-nckVepoVUex6fkPa6pppSgu1+4vsgSNdih5u9kxxbcs="]
    ["lapack-3.9.0.tgz" "sha256-EGCH8btfRq/fun9WnQy+I9rLmgfNJHM3ZaDonb4a1XM="]
    ["libatomic_ops-7.6.2.tar.gz" "sha256-IZck7a09WA1NN7IuHXy1LwAG0oLSapuGgbVgpiUULuY="]
    ["lrslib-071a.tar.gz" "sha256-kmY26mjeRmJfFB9uAl3OlnzH5oz0v0pZc3XAY/XBFnM="]
    ["mpfi-1.5.4.tar.gz" "sha256-MuatUpyXqlzgPijQHJIdG84aRk+0xX+8JI174h5lJ4I="]
    ["mpfr-4.0.2.tar.xz" "sha256-HTvnCGBOrg5C1Xi6k7OQwqFF8XdDp0TY8/jCrVhVo4o="]
    ["mpsolve-3.2.1.tar.gz" "sha256-PRFCiumrLgIPJMq/vNnk2bIuxXLPcK8NRP6Nrh1R544="]
    ["nauty27b11.tar.gz" "sha256-XVIhHOx2fY2OQ0g9liAr4jX4VpbRNzwwcpEnNGPIEvo="]
    ["normaliz-3.9.2.tar.gz" "sha256-Q0JlKB1KwaTgxEBANlmk/5KDRQi7T5LA0mI4e0ShjuA="]
    ["ntl-10.5.0.tar.gz" "sha256-uQs2yd2JVMm8VEELHVfAC+lWrh21oGKUWCK716hqtNI="]
    ["readline-8.2.tar.gz" "sha256-P+txcfFqhO6CyhijbXub4QmlLAT0kqBTMx19EJUAfDU="]
    ["readline82-001" "sha256-u/l/HsQKkp7ataqBmYweLvQ1Q2xZd1SRbmpYaPJzr/c="]
    ["TOPCOM-0.17.8.tar.gz" "sha256-P4O5j1HuhZ7DIbrKv3sXLCWITxSEirbGKDJrmHvYqqs="]
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
