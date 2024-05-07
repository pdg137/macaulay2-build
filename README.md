Script for building and installing Macaulay2 under Nix. Not everything
is working yet, but I have disabled documentation which at least
allows the build to complete.

Instructions:

1. Install nix.
2. Run `nix-build` in this directory.

Currently it takes about 26 minutes to build on a fast computer under
WSL Ubuntu. See `default.nix` or the issues here for various things
that need to be improved.
