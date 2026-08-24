{ config, ... }:
{
  programs = {
    sesh = {
      enable = true;
      enableAlias = false;
      enableTmuxIntegration = false;
    };
    tmux = {
      enable = true;

      prefix = "C-Space";

      focusEvents = true;
      mouse = true;
      newSession = true;

      baseIndex = 1;
      escapeTime = 0;
      historyLimit = 5000;
      keyMode = "vi";

      extraConfig = ''
        # undercurl support
        set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'

        # underscore colours
        set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'

        set -g extended-keys on
        set -g extended-keys-format csi-u

        set -g set-clipboard on

        # yazi image preview
        set -g allow-passthrough on
        set -ga update-environment TERM
        set -ga update-environment TERM_PROGRAM

        ################################## KEY BINDINGS #################################

        # Reload config
        bind r source "${config.xdg.configHome}/tmux/tmux.conf" \; display 'config reloaded'

        ################################## STATUS BAR ##################################

        set -g status-interval 1

        set -g status-position top
        set -g status-justify 'left'

        set -g status-left-length 100
        set -g status-right-length 100

        set -g status-style 'bold fg=terminal bg=terminal'

        set -g window-status-format ' #[default]#I:#W '
        set -g window-status-current-format '#[fg=black bg=yellow] #I:#W '

        set -g status-left ""

        set -g status-right ' #[fg=black bg=yellow] #{s|#{HOME}|\~|\:session_path} #[default]'

        #################################### PANES #####################################

        bind m resize-pane -Z
        bind h if -F '#{pane_at_left}' "" 'select-pane -L'
        bind j if -F '#{pane_at_bottom}' "" 'select-pane -D'
        bind k if -F '#{pane_at_top}' "" 'select-pane -U'
        bind l if -F '#{pane_at_right}' "" 'select-pane -R'

        # delete
        bind BSpace kill-pane
        unbind x

        # window styling
        setw -g window-active-style fg=terminal,bg=terminal
        setw -g window-style fg=terminal,bg=terminal
        set -g pane-border-style fg=terminal,bg=terminal
        set -g pane-active-border-style fg=blue,bg=terminal

        bind S setw synchronize-panes

        #################################### WINDOWS ###################################

        # reindex when window is deleted
        set -g renumber-windows on

        # prevent tmux renaming windows
        set -g allow-rename off

        # window switching
        bind n next-window
        bind N swap-window -t +1 \; select-window -t +1
        bind p previous-window
        bind P swap-window -t -1 \; select-window -t -1

        # move current pane
        bind C break-pane       # to new window
        bind < join-pane -t :-1 # to previous window
        bind > join-pane -t :+1 # to next window

        # split current pane
        bind - split-window -v
        bind \\ split-window -h

        # split whole window
        bind _ split-window -fv
        bind | split-window -fh

        ################################## COPY MODE ###################################

        bind -T copy-mode-vi v send-keys -X begin-selection
        bind -T copy-mode-vi V send-keys -X select-line
        bind -T copy-mode-vi 'C-v' send-keys -X rectangle-toggle \; send-keys -X begin-selection
        bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel
        bind -T copy-mode-vi Y send-keys -X append-selection-and-cancel
        bind -T copy-mode-vi 'C-[' send-keys -X cancel
        bind -T copy-mode-vi 'Escape' send-keys -X cancel

        # scroll one line at a time
        bind -T copy-mode-vi WheelUpPane send-keys -N 1 -X scroll-up
        bind -T copy-mode-vi WheelDownPane send-keys -N 1 -X scroll-down

        # don't exit scroll mode when scrolling with mouse
        unbind -T copy-mode-vi MouseDragEnd1Pane

        ################################### SESSIONS ###################################

        bind -N 'attach to last session' L run-shell 'sesh last'

        bind -N 'attach to root session' S run-shell 'sesh connect --root "$(pwd)"'

        # --preview "sesh preview {}" --preview-window "right:50%" \
        bind -N 'session manager' s run-shell 'sesh connect "$(
          sesh list --icons | fzf-tmux --no-sort --reverse \
            -p 100%,100% --ansi --padding 0,1 --prompt="❯ " \
            --border=none --input-border=bold --preview-border=bold \
            --header "^a all ^t tmux ^g configs ^x zoxide ^f find ^d kill" \
            --bind "tab:down,btab:up,ctrl-j:down,ctrl-k:up,ctrl-n:down,ctrl-p:up" \
            --bind "ctrl-a:reload(sesh list --icons)" \
            --bind "ctrl-t:reload(sesh list -t --icons)" \
            --bind "ctrl-g:reload(sesh list -c --icons)" \
            --bind "ctrl-x:reload(sesh list -z --icons)" \
            --bind "ctrl-f:reload(fd -H -d 2 -t d -E .Trash . ~)" \
            --bind "ctrl-d:execute(tmux kill-session -t {2..})+reload(sesh list --icons)" \
            --preview '${config.xdg.configHome}/tmux/sesh-preview.py {}' --preview-window "right:50%" \
        )"'
      '';
    };
  };

  xdg.configFile."tmux/sesh-preview.py".text = ''
    #!/usr/bin/env python3
    """Preview a tmux session: render a summary tree of its windows and panes.

    Used as the fzf preview in the sesh session picker. The preview arg is the
    session id/name (e.g. `0` or `23`) from `sesh list -t`. Falls back to
    `sesh preview` when the arg isn't a running tmux session (config/zoxide
    directory entries), so those still render their directory/file preview.
    """
    import os
    import subprocess
    import sys


    def run(cmd):
        try:
            return subprocess.run(cmd, capture_output=True, text=True, timeout=3).stdout
        except Exception:
            return ""


    def main():
        s = sys.argv[1] if len(sys.argv) > 1 else ""
        flt = f"#{{==:#{{session_name}},{s}}}"

        ses = run(
            ["tmux", "list-sessions", "-f", flt,
             "-F", "#{session_id} #{session_name} (#{session_windows}w)"]
        ).strip()
        if not ses:
            path = os.path.expanduser(s)
            print(run(["sesh", "preview", path]).strip() or "(no preview)")
            return

        print(f"SESSION  {ses}")
        print("--------------------------------------------------")

        win_fmt = "#{window_id}\t#{window_index}\t#{window_name}\t#{window_active}"
        pane_fmt = "#{pane_index}\t#{pane_current_command}\t#{pane_width}x#{pane_height}\t#{pane_active}"

        wins = run(["tmux", "list-windows", "-a", "-f", flt, "-F", win_fmt]).splitlines()
        for w in wins:
            if not w:
                continue
            c = w.split("\t")
            wid, idx, name, isactive = c[0], c[1], c[2], c[3]
            mark = "*" if isactive == "1" else " "
            print(f"  {mark} {idx}:{name}")
            panes = run(["tmux", "list-panes", "-t", wid, "-F", pane_fmt]).splitlines()
            for p in panes:
                if not p:
                    continue
                pc = p.split("\t")
                ac = ">>" if len(pc) > 3 and pc[3] == "1" else "  "
                print(f"      {ac} {pc[0]}  {pc[1]}  {pc[2]}")


    if __name__ == "__main__":
        main()
  '';

}
