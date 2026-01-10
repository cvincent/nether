{ name, mkSoftware, ... }:
mkSoftware name (
  {
    config,
    waybar,
    lib,
    helpers,
    nether,
    hmConfig,
    ...
  }:
  let
    directSymlinkConfigPath = "waybar/direct-symlink.json";
    directSymlinkCssPath = "waybar/direct-symlink.css";
  in
  {
    hm = {
      programs.waybar = {
        inherit (waybar) enable package;
        systemd.enable = true;
      };

      xdg.configFile."waybar/config".text = builtins.toJSON {
        "custom/mail" = {
          "exec" = lib.getExe nether.desk.mailWaybarModule;
        };

        "include" = [
          "${nether.homeDirectory}/${hmConfig.xdg.configFile.${directSymlinkConfigPath}.target}"
        ];
      };

      xdg.configFile.${directSymlinkConfigPath}.source = helpers.directSymlink ./configs/config.json;

      xdg.configFile."waybar/style.css".text = with config.lib.stylix.colors.withHashtag; ''
        @define-color base00 ${base00}; @define-color base01 ${base01};
        @define-color base02 ${base02}; @define-color base03 ${base03};
        @define-color base04 ${base04}; @define-color base05 ${base05};
        @define-color base06 ${base06}; @define-color base07 ${base07};

        @define-color base08 ${base08}; @define-color base09 ${base09};
        @define-color base0A ${base0A}; @define-color base0B ${base0B};
        @define-color base0C ${base0C}; @define-color base0D ${base0D};
        @define-color base0E ${base0E}; @define-color base0F ${base0F};

        @import url("${nether.homeDirectory}/${hmConfig.xdg.configFile.${directSymlinkCssPath}.target}");
      '';

      xdg.configFile.${directSymlinkCssPath}.source = helpers.directSymlink ./configs/direct-symlink.css;
    };
  }
)
