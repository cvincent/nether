{
  config,
  lib,
  nixpkgs-latest,
  ...
}:

{
  programs.qutebrowser = {
    enable = true;
    package = nixpkgs-latest.qutebrowser;

    settings = {
      auto_save.session = true;
      session.lazy_restore = true;
      spellcheck.languages = [ "en-US" ];
      colors.webpage.preferred_color_scheme = "dark";
      tabs.position = "right";
      tabs.select_on_remove = "last-used";

      downloads.location.directory = "~/Downloads";
      downloads.location.prompt = false;

      content.autoplay = false;
      content.cookies.accept = "no-3rdparty";
      content.geolocation = false;

      editor.command = [
        "kitty"
        "--class=qb-edit"
        "nvim"
        "{}"
      ];

      colors = {
        tabs.odd.bg = lib.mkForce "#${config.lib.stylix.colors.base00}";
        tabs.even.bg = lib.mkForce "#${config.lib.stylix.colors.base00}";
        tabs.pinned.odd.bg = lib.mkForce "#${config.lib.stylix.colors.base00}";
        tabs.pinned.even.bg = lib.mkForce "#${config.lib.stylix.colors.base00}";
      };
    };

    keyBindings = {
      normal = {
        # Scrolling
        j = "scroll-page 0 0.025";
        k = "scroll-page 0 -0.025";
        d = "scroll-page 0 0.5";
        u = "scroll-page 0 -0.5";
        "<ctrl-j>" = "scroll down";
        "<ctrl-k>" = "scroll up";
        "<ctrl-d>" = "cmd-repeat 10 scroll down";
        "<ctrl-u>" = "cmd-repeat 10 scroll up";

        # Tabs
        D = "tab-close";
        U = "undo";
        "<right>" = "tab-next";
        "<left>" = "tab-prev";
        "<ctrl-right>" = "tab-move +";
        "<ctrl-left>" = "tab-move -";
        x = "config-cycle tabs.position top right";
        "<space>ft" = "cmd-set-text -s :tab-select"; # TODO: This doesn't seem to work like before, see what's up

        # Easy esc in normal mode
        e = "fake-key <esc>";

        # Same as my NeoVim
        "<return>" = "cmd-set-text :";

        # Videos
        "<space>fv" = "hint links spawn mpv --force-window=immediate --no-terminal --keep-open=yes {hint-url}";
        "yv" = "spawn mpv --force-window=immediate --no-terminal --keep-open=yes {url}";

        # Downloads
        "<space>dc" = "download-clear";

        # Same as normal browsers
        "<ctrl-l>" = "edit-url";
      };
    };
  };
}
