{ neovim-nightly }:

final: _previous: {
  neovim-head = final.callPackage ./neovim-head {
    inherit neovim-nightly;
  };

  rayfish = final.callPackage ./rayfish.nix { };
}
