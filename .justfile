set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

_default:
    @just --list

fmt:
    nix fmt

check *args:
    nix flake check {{args}}

update *inputs:
    nix flake update {{inputs}}

deploy host *args:
    nix run .#deploy -- ".#{{host}}" {{args}}

deploy-all *args:
    nix run .#deploy -- . {{args}}

[confirm("This will repartition the target and install NixOS. Continue?")]
install host target *args:
    nix run .#nixos-anywhere -- \
    --flake ".#{{host}}" --target-host "{{target}}" {{args}}

sops *args:
    nix run .#sops -- {{args}}

secret file:
    nix run .#sops -- edit "{{file}}"

rekey file:
    nix run .#sops -- updatekeys "{{file}}"
