# NixOS service modules.
#
# Enable on a host by importing `./nixos`, or cherry-pick individual
# `./nixos/<name>` modules.
{
  imports = [
    ./caddy
    ./openwebui
    ./pocket-id
    ./spindle
    ./tranquil-pds
  ];
}
