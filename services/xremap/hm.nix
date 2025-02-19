{ inputs, lib, ... }:

{
  imports = [
    inputs.xremap-flake.homeManagerModules.default
    {
      services.xremap = {
        withWlroots = true;
        watch = true;
        config.keymap =
          let
            kitty_mappings = {
              "copy" = "CTRL-SHIFT-c";
              "paste" = "CTRL-SHIFT-v";
            };
          in
          [
            {
              application.only = "kitty";
              remap = kitty_mappings;
            }
            {
              application.only = "kitty-scratch";
              remap = kitty_mappings;
            }
            {
              application.only = "neorg-scratch";
              remap = kitty_mappings;
            }
            {
              application.only = "obsidian-scratch";
              remap = kitty_mappings;
            }
            {
              application.only = "ytsub-scratch";
              remap = kitty_mappings;
            }
            {
              application.only = "spotify-tui-scratch";
              remap = kitty_mappings;
            }
            {
              application.only = "kitty-tmux";
              remap = kitty_mappings;
            }
            {
              application.only = "kitty-dotfiles";
              remap = kitty_mappings;
            }
            {
              name = "Global";
              remap = {
                "undo" = "CTRL-z";
                "copy" = "CTRL-c";
                "paste" = "CTRL-v";
              };
            }
          ];
      };
    }
  ];

  systemd.user.services.xremap.Unit.PartOf = lib.mkForce [ "graphical.target" ];
  systemd.user.services.xremap.Unit.After = lib.mkForce [ "graphical.target" ];
  systemd.user.services.xremap.Install.WantedBy = lib.mkForce [ "graphical.target" ];
}
