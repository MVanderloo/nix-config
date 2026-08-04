format:
    nix fmt

check:
    statix check .
    deadnix .
