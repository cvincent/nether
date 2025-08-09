{ name, mkSoftware, ... }:
mkSoftware name (
  {
    hmOptions,
    nether,
    kitty,
    lib,
    helpers,
    ...
  }:
  {
    options = lib.getAttrs [
      "enableGitIntegration"
      "environment"
      "extraConfig"
      "keybindings"
      "settings"
      "themeFile"
    ] hmOptions.programs.kitty;

    nixos.nether.software.kitty = {
      settings = {
        shell = nether.shells.default.path;
      };

      extraConfig = lib.mkAfter ''
        include ./main.conf
      '';
    };

    hm = {
      programs.kitty = {
        inherit (kitty)
          enable
          package
          enableGitIntegration
          environment
          keybindings
          settings
          themeFile
          ;

        extraConfig = lib.mkAfter kitty.extraConfig;
      };

      xdg.configFile."kitty/main.conf".source = helpers.directSymlink ./main.conf;
    };
  }
)
