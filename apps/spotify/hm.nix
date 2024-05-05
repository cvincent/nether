{ config, pkgs, utils, nixpkgs-unstable, ... }:

{
  programs.ncspot = {
    enable = true;
    package = nixpkgs-unstable.ncspot;
    settings = {
      keybindings = {
        "Esc" = "back";
        "Backspace" = "noop";
        "q" = "noop";
      };
      theme = {
        background = "default";
        primary = "#D8DEE9";
        secondary = "#4C566A";
        title = "#EBCB8B";
        playing = "#2E3440";
        playing_selected = "#FF6060";
        playing_bg = "#88C0D0";
        highlight = "#88C0D0";
        highlight_bg = "#4C566A";
        error = "#ECEFF4";
        error_bg = "#BF616A";
        statusbar = "#2E3440";
        statusbar_progress = "#A3BE8C";
        statusbar_bg = "#8FBCBB";
        cmdline = "#D8DEE9";
        cmdline_bg = "#2E3440";
        search_match = "#B48EAD";
      };
    };
  };
}
