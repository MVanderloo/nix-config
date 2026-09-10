{ lib, pkgs, ... }:

let
  bbAuth = pkgs.callPackage ../../packages/bb-auth { };
  plugin = pkgs.stdenvNoCC.mkDerivation {
    pname = "noctalia-bb-auth";
    version = "1.1.1";

    src = pkgs.fetchFromGitHub {
      owner = "branrgx";
      repo = "noctalia-plugins";
      rev = "409d26d29faae6ed2fa1cbd44efba3d8f0eaa097";
      hash = "sha256-e7/A5VuzKkgp3RM1JtwfNqioi+S1SGAJ1QlUIE18Ub8=";
    };

    dontBuild = true;
    postPatch = ''
      substituteInPlace bb-auth/service.luau \
        --replace-fail '"python3 "' '"${pkgs.python3}/bin/python3 "'
      substituteInPlace bb-auth/panel.luau bb-auth/blocked.luau \
        --replace-fail '"python3",' '"${pkgs.python3}/bin/python3",' \
        --replace-fail 'noctalia.pluginDataDir()' 'noctalia.getenv("XDG_RUNTIME_DIR")'

      # Prompt responses are transient secrets. Keep the handoff in the private 
      # runtime directory, with names scoped to this plugin.
      substituteInPlace bb-auth/panel.luau \
        --replace-fail '.. filename' '.. "noctalia-bb-auth-" .. filename'
      substituteInPlace bb-auth/blocked.luau \
        --replace-fail '"/blocked-cancel.json"' '"/noctalia-bb-auth-blocked-cancel.json"'
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp -r bb-auth catalog.toml "$out/"
      runHook postInstall
    '';

    meta = {
      description = "Noctalia authentication UI provider for bb-auth";
      homepage = "https://github.com/branrgx/noctalia-plugins/tree/main/bb-auth";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
    };
  };
in
{
  home.packages = [ bbAuth ];

  programs.noctalia.settings = {
    shell.polkit_agent = false;
    plugins = {
      enabled = [ "branrgx/bb-auth" ];
      source = [
        {
          name = "official";
          kind = "git";
          location = "https://github.com/noctalia-dev/official-plugins";
        }
        {
          name = "community";
          kind = "git";
          location = "https://github.com/noctalia-dev/community-plugins";
        }
        {
          name = "branrgx";
          kind = "path";
          location = "${plugin}";
        }
      ];
    };
  };

  services.gpg-agent.pinentry = {
    package = lib.mkForce bbAuth;
    program = "pinentry-bb";
  };

  systemd.user.services.bb-auth = {
    Unit = {
      Description = "BB Auth - Noctalia authentication backend";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Service = {
      ExecStart = "${lib.getExe bbAuth} --daemon";
      Slice = "session.slice";
      Restart = "on-failure";
      RestartSec = 2;
      TimeoutStopSec = 5;
      UMask = "0077";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  xdg.dataFile = {
    "dbus-1/services/org.bb.auth.service".source =
      "${bbAuth}/share/dbus-1/services/org.bb.auth.service";
    "dbus-1/services/org.gnome.keyring.SystemPrompter.service".source =
      "${bbAuth}/share/bb-auth/org.gnome.keyring.SystemPrompter.service";
  };
}
