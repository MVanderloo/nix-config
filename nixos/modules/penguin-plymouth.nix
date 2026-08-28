{ pkgs, ... }:

let
  themeName = "framework-penguin";

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

    fun refresh() {
      animation.sprite.SetImage(frame.image[Math.Int(frame.position) % frame.count]);
      frame.position += frame.speed;
    }

    Plymouth.SetRefreshFunction(refresh);

    fun display_password(prompt_text, bullet_count) {
      prompt.image = Image.Text(prompt_text, 1, 1, 1);
      prompt.sprite = Sprite(prompt.image);
      prompt.sprite.SetX(screen.w / 2 - prompt.image.GetWidth() / 2);
      prompt.y = screen.h / 2 + frame.image[0].GetHeight() / 2 + 24;
      prompt.sprite.SetY(prompt.y);

      bullets.text = "";
      for (i = 0; i < bullet_count; i++)
        bullets.text += "*";

      bullets.image = Image.Text(bullets.text, 1, 1, 1);
      bullets.sprite = Sprite(bullets.image);
      bullets.sprite.SetX(screen.w / 2 - bullets.image.GetWidth() / 2);
      bullets.sprite.SetY(prompt.y + prompt.image.GetHeight() + 12);
    }

    Plymouth.SetDisplayPasswordFunction(display_password);

    fun display_question(prompt_text, answer_text) {
      question.image = Image.Text(prompt_text + " " + answer_text, 1, 1, 1);
      question.sprite = Sprite(question.image);
      question.sprite.SetX(screen.w / 2 - question.image.GetWidth() / 2);
      question.sprite.SetY(screen.h / 2 + frame.image[0].GetHeight() / 2 + 24);
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
      prompt.sprite = null;
      bullets.sprite = null;
      question.sprite = null;
      message.sprite = null;
    }

    Plymouth.SetDisplayNormalFunction(display_normal);
  '';

  frameworkPenguin =
    pkgs.runCommand "${themeName}-plymouth-theme"
      {
        nativeBuildInputs = [ pkgs.imagemagick ];
      }
      ''
        themeDir="$out/share/plymouth/themes/${themeName}"

        mkdir -p "$themeDir"
        magick ${../../assets/framework-penguin.gif} -coalesce "$themeDir/frame-%03d.png"
        cp ${themeScript} "$themeDir/${themeName}.script"

        cat > "$themeDir/${themeName}.plymouth" <<EOF
        [Plymouth Theme]
        Name=Framework Penguin
        Description=Framework penguin boot animation
        ModuleName=script

        [script]
        ImageDir=$themeDir
        ScriptFile=$themeDir/${themeName}.script
        EOF
      '';
in
{
  boot = {
    plymouth = {
      enable = true;
      theme = themeName;
      themePackages = [ frameworkPenguin ];
    };

    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "udev.log_level=3"
    ];
  };
}
