{
  neovim-nightly,
  stdenv,
}:

neovim-nightly.packages.${stdenv.hostPlatform.system}.default
