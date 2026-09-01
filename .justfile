format:
    nix fmt

check:
    statix check .
    deadnix .

sops-hermes:
    #!/usr/bin/env bash
    set -euo pipefail
    sudo -v
    nix shell nixpkgs#sops nixpkgs#ssh-to-age -c bash -c '
      export SOPS_AGE_KEY_CMD="sudo -n $(command -v ssh-to-age) -private-key -i /etc/ssh/ssh_host_ed25519_key"
      exec sops secrets/theta-hermes.yaml
    '
