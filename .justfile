set positional-arguments
set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

_default:
    @just --list

fmt:
    nix fmt

check *args:
    nix flake check "$@"

update *inputs:
    nix flake update "$@"

deploy host *args:
    #!/usr/bin/env bash
    set -euo pipefail
    host="$1"
    shift
    nix run .#deploy -- ".#$host" "$@"

deploy-all *args:
    nix run .#deploy -- . "$@"

[confirm("This will repartition the target and install NixOS. Continue?")]
install host target *args:
    #!/usr/bin/env bash
    set -euo pipefail
    host="$1"
    target="$2"
    shift 2
    nix run .#nixos-anywhere -- \
      --flake ".#$host" --target-host "$target" "$@"

sops *args:
    nix run .#sops -- "$@"

secret file:
    nix run .#sops -- edit "$1"

rekey file:
    nix run .#sops -- updatekeys "$1"
