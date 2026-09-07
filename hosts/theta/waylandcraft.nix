{ pkgs, ... }:

{
  nixpkgs.config.allowUnfreePackages = [
    "discord"
    "discord-unwrapped"
  ];

  programs.waylandcraft-desktop = {
    enable = true;
    offerTtySession = true;
    keybindings = {
      minecraft.quickActions = "key.keyboard.unknown";
      waylandcraft.captureKeyboard = "key.keyboard.unknown";
      desktop.keyboardLock = {
        key = "key.keyboard.q";
        modifiers = [ "super" ];
      };
      desktop.logout = {
        key = "key.keyboard.q";
        modifiers = [
          "control"
          "super"
        ];
      };
    };
    extraPackages = with pkgs; [
      discord
      firefox
      ghostty
      obs-studio
      prismlauncher
    ];
  };

  services.displayManager.ly = {
    enable = true;
    x11Support = false;
  };
}
