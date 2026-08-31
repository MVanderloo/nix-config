{ config, pkgs, ... }:
{
  programs.pi-coding-agent = {
    enable = true;

    extraPackages = [ pkgs.bun ];

    configDir = "${config.xdg.configHome}/pi/agent";

    settings = {
      autocompleteMaxVisible = 10;
      collapseChangelog = true;
      defaultModel = "~deepseek/deepseek-v4-flash-latest";
      defaultProvider = "openrouter";
      defaultThinkingLevel = "low";
      enableInstallTelemetry = false;
      hideThinkingBlock = false;
      npmCommand = [ "bun" ];
      packages = [
        "npm:@eko24ive/pi-ask"
        "npm:@ollama/pi-web-search"
        "npm:pi-manage-todo-list"
        "npm:pi-prompt-template-model"
        "npm:pi-subagents"
        "npm:pi-terminal-theme"
      ];
      quietStartup = true;
      subagents.agentOverrides = {
        context-builder.model = "~deepseek/deepseek-v4-flash-latest";
        planner.model = "~deepseek/deepseek-v4-flash-latest";
        researcher.model = "~deepseek/deepseek-v4-flash-latest";
        reviewer.model = "~deepseek/deepseek-v4-flash-latest";
        scout.model = "~deepseek/deepseek-v4-flash-latest";
        worker.model = "~deepseek/deepseek-v4-flash-latest";
      };
      terminal.clearOnShrink = false;
      theme = "terminal";
      transport = "auto";
    };

    keybindings = {
      "tui.editor.cursorUp" = [
        "ctrl+p"
        "up"
      ];
      "tui.editor.cursorDown" = [
        "ctrl+n"
        "down"
      ];
      "tui.editor.cursorLeft" = [ "ctrl+b" ];
      "tui.editor.cursorRight" = [ "ctrl+f" ];
      "tui.editor.cursorWordLeft" = [ "alt+b" ];
      "tui.editor.cursorWordRight" = [ "alt+f" ];
      "tui.editor.cursorLineStart" = [ "ctrl+a" ];
      "tui.editor.cursorLineEnd" = [ "ctrl+e" ];
      "tui.editor.deleteCharBackward" = [ "backspace" ];
      "tui.editor.deleteCharForward" = [ "delete" ];
      "tui.editor.deleteWordBackward" = [
        "ctrl+w"
        "alt+backspace"
      ];
      "tui.editor.deleteWordForward" = [
        "alt+d"
        "alt+delete"
      ];
      "tui.editor.deleteToLineStart" = [ "ctrl+u" ];
      "tui.editor.deleteToLineEnd" = [ "ctrl+k" ];
      "tui.editor.yank" = [ "ctrl+y" ];
      "tui.editor.yankPop" = [ "alt+y" ];
      "tui.editor.undo" = [
        "ctrl+-"
        "ctrl+_"
      ];

      "tui.input.newLine" = [
        "ctrl+j"
        "shift+enter"
      ];
      "tui.input.submit" = [
        "ctrl+m"
        "enter"
      ];
      "tui.input.tab" = [ "tab" ];
      "tui.input.copy" = [ ];

      "tui.select.up" = [ "ctrl+p" ];
      "tui.select.down" = [ "ctrl+n" ];
      "tui.select.pageUp" = [ "ctrl+u" ];
      "tui.select.pageDown" = [ "ctrl+p" ];
      "tui.select.enter" = [ "enter" ];
      "tui.select.cancel" = [
        "escape"
        "ctrl+c"
        "ctrl+d"
      ];

      "app.interrupt" = [ "escape" ];
      "app.clear" = [ "ctrl+c" ];
      "app.exit" = [ "ctrl+d" ];
      "app.suspend" = [ "ctrl+z" ];
      "app.editor.external" = [
        "ctrl+g"
        "alt+e"
      ];
      "app.clipboard.pasteImage" = [ "ctrl+v" ];

      "app.session.new" = [ ];
      "app.session.tree" = [ ];
      "app.session.fork" = [ ];
      "app.session.resume" = [ ];
      "app.session.togglePath" = [ ];
      "app.session.toggleSort" = [ ];
      "app.session.toggleNamedFilter" = [ ];
      "app.session.rename" = [ ];
      "app.session.delete" = [ ];
      "app.session.deleteNoninvasive" = [ ];

      "app.model.select" = [ "alt+m" ];
      "app.model.cycleForward" = [ ];
      "app.model.cycleBackward" = [ ];

      "app.thinking.cycle" = [ ];
      "app.thinking.toggle" = [ ];

      "app.tools.expand" = [ "ctrl+o" ];
      "app.message.followUp" = [ "alt+enter" ];
      "app.message.dequeue" = [ "alt+up" ];
    };
  };
}
