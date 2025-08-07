{ name, mkSoftware, ... }:
mkSoftware name (
  {
    config,
    waybar,
    lib,
    helpers,
    ...
  }:
  {
    hm = {
      programs.waybar = {
        inherit (waybar) enable package;
        systemd = {
          enable = true;
          # TODO: We should move to installing Hyprland via options, at which
          # point this probably won't be needed...
          target = "default.target";
        };
      };

      home.file."./.config/waybar/config".source = helpers.directSymlink ./configs/config;

      home.file."./.config/waybar/style.css".text =
        with config.lib.stylix.colors.withHashtag;
        ''
          @define-color base00 ${base00}; @define-color base01 ${base01};
          @define-color base02 ${base02}; @define-color base03 ${base03};
          @define-color base04 ${base04}; @define-color base05 ${base05};
          @define-color base06 ${base06}; @define-color base07 ${base07};

          @define-color base08 ${base08}; @define-color base09 ${base09};
          @define-color base0A ${base0A}; @define-color base0B ${base0B};
          @define-color base0C ${base0C}; @define-color base0D ${base0D};
          @define-color base0E ${base0E}; @define-color base0F ${base0F};
        ''
        + (builtins.readFile ./configs/style.css);

      systemd.users.services.waybar = {
        Install.WantedBy = lib.mkForce [ "graphical.target" ];
        Unit.After = lib.mkForce [ "graphical.target" ];
        Unit.PartOf = lib.mkForce [ "graphical.target" ];
      };
    };
  }
)
