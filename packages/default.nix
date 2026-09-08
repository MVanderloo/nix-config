{ neovim-nightly }:

final: previous: {
  codex =
    let
      version = "0.153.4";
      cargoHash = "sha256-GG6kOXmCdq+bZLU2ul0DIVL8lDuweayvZvXn6+bcUZw=";
      src = final.fetchFromGitHub {
        owner = "openai";
        repo = "codex";
        tag = "rust-v${version}";
        hash = "sha256-lHiDj5SodaM3mh8goMm6esfejeAT+Y3JJWrRnyj6sJo=";
      };
    in
    previous.codex.overrideAttrs (_oldAttrs: {
      inherit version src cargoHash;
      # buildRustPackage has already materialized the old package's cargoDeps.
      cargoDeps = final.rustPlatform.fetchCargoVendor {
        pname = "codex";
        inherit version src;
        sourceRoot = "${src.name}/codex-rs";
        hash = cargoHash;
      };
    });

  neovim-head = final.callPackage ./neovim-head {
    inherit neovim-nightly;
  };

  rayfish = final.callPackage ./rayfish.nix { };
}
