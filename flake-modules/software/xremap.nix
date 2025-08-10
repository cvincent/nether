{ name, ... }:
{ lib, ... }:
{
  flake.nixosModules."${name}" =
    { config, ... }:
    {
      options = {
        nether.xremap = lib.mkEnableOption "xremap tool for remapping keys per application";
      };

      config = lib.mkIf config.nether.xremap {
        hardware.uinput.enable = true;
        users.groups.uinput.members = [ config.nether.username ];
        users.groups.input.members = [ config.nether.username ];
      };
    };

  flake.homeModules."${name}" =
    { osConfig, ... }:
    {
      config = lib.mkIf osConfig.nether.xremap {
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
      };
    };
}
