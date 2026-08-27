{
  programs.yazi = {
    enable = true;
    settings = {
      manager = {
        sort_by = "extension";
        sort_sensitive = false;
        sort_dir_first = true;
        linemode = "size";
        show_hidden = true;
        show_symlink = true;
      };
    };
    keymap = {
      manager.prepend_keymap = [
        {
          on = "<C-o>";
          run = "back";
          desc = "Go back to the previous directory";
        }
        {
          on = "<C-i>";
          run = "forward";
          desc = "Go forward to the next directory";
        }
      ];
    };
  };
}
