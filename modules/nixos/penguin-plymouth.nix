{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.boot.plymouth.penguin;
  themeName = "penguin";

  themeScript = pkgs.writeText "${themeName}.script" ''
    Window.SetBackgroundTopColor(0, 0, 0);
    Window.SetBackgroundBottomColor(0, 0, 0);

    screen.w = Window.GetWidth();
    screen.h = Window.GetHeight();

    frame.count = 51;
    frame.position = 0;
    frame.speed = 0.5;

    for (i = 0; i < frame.count; i++) {
      if (i < 10)
        frame.image[i] = Image("frame-00" + i + ".png");
      else if (i < 100)
        frame.image[i] = Image("frame-0" + i + ".png");
      else
        frame.image[i] = Image("frame-" + i + ".png");
    }

    animation.sprite = Sprite(frame.image[0]);
    animation.sprite.SetX(screen.w / 2 - frame.image[0].GetWidth() / 2);
    animation.sprite.SetY(screen.h / 2 - frame.image[0].GetHeight() / 2);

    dialog.image = Image("password-box.png");
    dialog.sprite = Sprite(dialog.image);
    dialog.x = screen.w / 2 - dialog.image.GetWidth() / 2;
    dialog.y = screen.h / 2 + frame.image[0].GetHeight() / 2 + 32;

    if (dialog.y + dialog.image.GetHeight() > screen.h - 24)
      dialog.y = screen.h - dialog.image.GetHeight() - 24;

    dialog.sprite.SetX(dialog.x);
    dialog.sprite.SetY(dialog.y);
    dialog.sprite.SetOpacity(0);

    fun refresh() {
      animation.sprite.SetImage(frame.image[Math.Int(frame.position) % frame.count]);
      frame.position += frame.speed;
    }

    Plymouth.SetRefreshFunction(refresh);

    fun display_password(prompt_text, bullet_count) {
      if (prompt.sprite)
        prompt.sprite.SetOpacity(0);
      if (bullets.sprite)
        bullets.sprite.SetOpacity(0);

      dialog.sprite.SetOpacity(1);

      prompt.image = Image.Text(
        "Unlock NixOS",
        1, 1, 1, 1,
        "Sans Bold ${toString cfg.promptFontSize}",
        "center"
      );
      prompt.sprite = Sprite(prompt.image);
      prompt.sprite.SetX(screen.w / 2 - prompt.image.GetWidth() / 2);
      prompt.y = dialog.y + 22;
      prompt.sprite.SetY(prompt.y);

      bullets.text = "Password: ";
      for (i = 0; i < bullet_count; i++)
        bullets.text += "*";

      bullets.image = Image.Text(
        bullets.text,
        0.8, 0.82, 0.9, 1,
        "Monospace ${toString cfg.promptFontSize}",
        "center"
      );
      bullets.sprite = Sprite(bullets.image);
      bullets.sprite.SetX(screen.w / 2 - bullets.image.GetWidth() / 2);
      bullets.sprite.SetY(prompt.y + prompt.image.GetHeight() + 18);
    }

    Plymouth.SetDisplayPasswordFunction(display_password);

    fun display_question(prompt_text, answer_text) {
      if (question.sprite)
        question.sprite.SetOpacity(0);

      dialog.sprite.SetOpacity(1);
      question.image = Image.Text(
        prompt_text + " " + answer_text,
        1, 1, 1, 1,
        "Sans Bold ${toString cfg.promptFontSize}",
        "center"
      );
      question.sprite = Sprite(question.image);
      question.sprite.SetX(screen.w / 2 - question.image.GetWidth() / 2);
      question.sprite.SetY(dialog.y + dialog.image.GetHeight() / 2 - question.image.GetHeight() / 2);
    }

    Plymouth.SetDisplayQuestionFunction(display_question);

    fun display_message(text) {
      message.image = Image.Text(text, 1, 1, 1);
      message.sprite = Sprite(message.image);
      message.sprite.SetX(screen.w / 2 - message.image.GetWidth() / 2);
      message.sprite.SetY(24);
    }

    Plymouth.SetMessageFunction(display_message);

    fun display_normal() {
      dialog.sprite.SetOpacity(0);
      if (prompt.sprite)
        prompt.sprite.SetOpacity(0);
      if (bullets.sprite)
        bullets.sprite.SetOpacity(0);
      if (question.sprite)
        question.sprite.SetOpacity(0);
      if (message.sprite)
        message.sprite.SetOpacity(0);
    }

    Plymouth.SetDisplayNormalFunction(display_normal);
  '';

  penguinTheme =
    pkgs.runCommand "${themeName}-plymouth-theme"
      {
        nativeBuildInputs = [ pkgs.imagemagick ];
      }
      ''
        themeDir="$out/share/plymouth/themes/${themeName}"

        mkdir -p "$themeDir"
        magick ${../../assets/penguin.gif} \
          -coalesce \
          -resize ${toString cfg.imageSize}x${toString cfg.imageSize} \
          "$themeDir/frame-%03d.png"
        magick \
          -size ${toString cfg.dialogWidth}x${toString cfg.dialogHeight} \
          xc:'#181825' \
          -fill none \
          -stroke '#cdd6f4' \
          -strokewidth 3 \
          -draw 'roundrectangle 2,2,${toString (cfg.dialogWidth - 3)},${
            toString (cfg.dialogHeight - 3)
          },18,18' \
          "$themeDir/password-box.png"
        cp ${themeScript} "$themeDir/${themeName}.script"

        cat > "$themeDir/${themeName}.plymouth" <<EOF
        [Plymouth Theme]
        Name=Penguin
        Description=Penguin boot animation
        ModuleName=script

        [script]
        ImageDir=$themeDir
        ScriptFile=$themeDir/${themeName}.script
        EOF
      '';
in
{
  options.boot.plymouth.penguin = {
    imageSize = lib.mkOption {
      type = lib.types.ints.positive;
      default = 320;
      description = "Width and height of the penguin animation in pixels.";
    };

    dialogWidth = lib.mkOption {
      type = lib.types.ints.positive;
      default = 560;
      description = "Width of the visible password dialog in pixels.";
    };

    dialogHeight = lib.mkOption {
      type = lib.types.ints.positive;
      default = 120;
      description = "Height of the visible password dialog in pixels.";
    };

    promptFontSize = lib.mkOption {
      type = lib.types.ints.positive;
      default = 18;
      description = "Font size used in the password dialog.";
    };
  };

  config.boot = {
    plymouth = {
      enable = true;
      theme = themeName;
      themePackages = [ penguinTheme ];
    };

    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "udev.log_level=3"
    ];
  };
}
