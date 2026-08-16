# rayfish: p2p mesh VPN powered by iroh (https://rayfish.xyz).
#
# Not yet in nixpkgs, so we package the official GitHub release binary.
# We pick the *static* (musl) Linux build because the default glibc build
# expects /lib64/ld-linux-x86-64.so.2 and won't run on NixOS.
#
# Bump `version` and re-fetch the `sha256` (via `nix-prefetch-url`) when
# upstream cuts a new release.
#
#   nix-prefetch-url "https://github.com/rayfish/rayfish/releases/download/v<VER>/ray-linux-x86_64-musl"
{
  fetchurl,
  runCommand,
  system,
}:

let
  version = "0.3.0";
  release = "v${version}";

  # system -> (asset-name, sha256-sri)
  assets = {
    x86_64-linux = {
      name = "ray-linux-x86_64-musl";
      sha256 = "sha256-cjSGCBxBC9aEpJnZyPOWCwmsYu2doPW97uw1VXdGRu8=";
    };
    # aarch64-darwin not wired up yet; the macOS release ships a dynamic
    # binary that nix-darwin would need autoPatchelf-style handling.
    # aarch64-darwin = { name = "ray-macos-aarch64"; sha256 = "..."; };
  };
in
if !(assets ? ${system}) then
  throw "rayfish: no prebuilt binary for system '${system}'"
else
  let
    asset = assets.${system};
    url = "https://github.com/rayfish/rayfish/releases/download/${release}/${asset.name}";
    binary = fetchurl {
      inherit (asset) sha256;
      inherit url;
    };
  in
  runCommand "ray-${version}" { } ''
    mkdir -p $out/bin
    cp ${binary} $out/bin/ray
    chmod +x $out/bin/ray
  ''
