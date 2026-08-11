{ pkgs, ... }:
{
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      use-xdg-base-directories = true;
    };
    envVars = {
      HTTP_PROXY = "http://llproxy.llan.ll.mit.edu:8080";
      HTTPS_PROXY = "http://llproxy.llan.ll.mit.edu:8080";
      ALL_PROXY = "http://llproxy.llan.ll.mit.edu:8080";
      NO_PROXY = ".ll.mit.edu,.mit.edu,localhost,127.0.0.1";
    };
  };
  ids.uids.nixbld = 351;

  users.users.mi30175 = {
    home = "/Users/mi30175";
    shell = pkgs.fish;
  };

  environment.variables = {
    HTTPS_PROXY = "http://llproxy.llan.ll.mit.edu:8080";
    HTTP_PROXY = "http://llproxy.llan.ll.mit.edu:8080";
    ALL_PROXY = "http://llproxy.llan.ll.mit.edu:8080";
    NO_PROXY = ".ll.mit.edu,.mit.edu,localhost,127.0.0.1";
  };

  programs.fish.enable = true;

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
    };
    # brews = [ ];
    casks = [
      "keepassxc"
      "raycast"
    ];
  };

  system = {
    stateVersion = 7;
    primaryUser = "mi30175";

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
      swapRightCommandAndRightOption = true;
    };

    defaults = {
      ".GlobalPreferences"."com.apple.mouse.scaling" = -1.0;
      controlcenter = {
        AirDrop = false;
        BatteryShowPercentage = true;
        Bluetooth = false;
        Display = false;
        FocusModes = false;
        NowPlaying = false;
        Sound = false;
      };
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.2;
        largesize = null;
        launchanim = true;
        mineffect = "scale";
        minimize-to-application = false;
        mru-spaces = false;
        persistent-apps = [ ];
        show-process-indicators = false;
        show-recents = false;
        static-only = true;
        tilesize = 64; # ??
      };
      finder = {
        _FXEnableColumnAutoSizing = true;
        _FXSortFoldersFirst = true;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        CreateDesktop = false;
        FXDefaultSearchScope = "SCcf";
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "clmv";
        FXRemoveOldTrashItems = false;
        NewWindowTarget = "Home";
        QuitMenuItem = true;
        ShowExternalHardDrivesOnDesktop = false;
        ShowHardDrivesOnDesktop = false;
        ShowMountedServersOnDesktop = false;
        ShowPathbar = true;
        ShowRemovableMediaOnDesktop = false;
        ShowStatusBar = true;
      };
      hitoolbox.AppleFnUsageType = "Do Nothing";
      LaunchServices.LSQuarantine = false;
      loginwindow.LoginwindowText = "Hello, World!";
      menuExtraClock = {
        FlashDateSeparators = false;
        IsAnalog = false;
        Show24Hour = true;
        ShowAMPM = false;
        ShowDate = 1;
        ShowDayOfMonth = true;
        ShowDayOfWeek = true;
        ShowSeconds = true;
      };
      NSGlobalDomain = {
        "com.apple.keyboard.fnState" = false;
        "com.apple.swipescrolldirection" = true;
        "com.apple.trackpad.scaling" = 1.0;
        _HIHideMenuBar = false;
        AppleFontSmoothing = 0;
        # null or one of "RegularDark", "RegularAutomatic", "ClearLight", "ClearDark", "ClearAutomatic", "TintedLight", "TintedDark", "TintedAutomatic"
        # To set to default mode, set this to null and you'll need to manually run defaults delete -g AppleIconAppearanceTheme
        AppleIconAppearanceTheme = "RegularAutomatic";
        # To set to light mode, set this to null and you'll need to manually run defaults delete -g AppleInterfaceStyle.
        AppleInterfaceStyle = "Dark";
        AppleInterfaceStyleSwitchesAutomatically = false;
        AppleKeyboardUIMode = 2;
        AppleSpacesSwitchOnActivate = false;
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 14;
        KeyRepeat = 2;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticWindowAnimationsEnabled = false;
        NSDisableAutomaticTermination = true;
        NSDocumentSaveNewDocumentsToCloud = false;
        NSScrollAnimationEnabled = true;
        NSStatusItemSelectionPadding = 6;
        NSStatusItemSpacing = 12;
        NSTableViewDefaultSizeMode = 2;
      };
      screencapture = {
        disable-shadow = true;
        include-date = true;
        # location = "~/Pictures/Screenshots/";
        save-selections = true;
        show-thumbnail = true;
        target = "clipboard"; # trying this out
        type = "png";
      };
      screensaver = {
        askForPassword = true;
        askForPasswordDelay = 0;
      };
      CustomUserPreferences = {
        "com.apple.CloudSubscriptionFeatures.optIn"."545129924" = false;
      };
    };
  };
}
