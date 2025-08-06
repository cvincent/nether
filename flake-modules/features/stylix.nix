{ name, ... }:
{ lib, moduleWithSystem, ... }:
{
  flake.nixosModules."${name}" = moduleWithSystem (
    { pkgs, self' }:
    { config, ... }:
    {
      options = {
        # TODO: This is just for our convenience and consistency for now, for
        # when other configs want the name of a base 16 theme. We want to look
        # into fast switchable theming at some point.
        nether.theme = lib.mkOption {
          type = lib.types.str;
          default = "nord";
        };

        nether.stylix = lib.mkOption {
          type = lib.types.attrs;
          default = {
            enable = true;
            image = ../../resources/wallpapers/nord-irithyll.png;
            base16Scheme = lib.mkForce "${pkgs.base16-schemes}/share/themes/${config.nether.theme}.yaml";
            polarity = "dark";

            targets.fish.enable = false;

            opacity.popups = 0.8;

            cursor = {
              package = pkgs.nordzy-cursor-theme;
              name = "Nordzy-cursors";
              size = 32;
            };

            fonts = {
              monospace = {
                name = "PragmataPro Mono";
                package = self'.legacyPackages.fonts.PragmataPro;
              };

              serif = config.stylix.fonts.monospace;
              sansSerif = config.stylix.fonts.monospace;
              emoji = config.stylix.fonts.monospace;
            };
          };
        };
      };
      config = { inherit (config.nether) stylix; };
    }
  );

  flake.homeModules."${name}" = moduleWithSystem (
    { pkgs }:
    { osConfig, ... }:
    {
      home.packages = [ pkgs.glib ];

      dconf = {
        enable = osConfig.nether.stylix.enable;
        settings = {
          "org/gnome/desktop/interface".color-scheme = "prefer-dark";
          "org/gtk/settings/debug".enable-inspector-keybinding = true;
        };
      };

      gtk = {
        enable = osConfig.nether.stylix.enable;
        iconTheme = {
          name = "Nordzy-dark";
          package = pkgs.nordzy-icon-theme;
          # name = "WhiteSur";
          # package = pkgs.whitesur-icon-theme.override {
          #   # themeVariants = ["nord"];
          #   alternativeIcons = true;
          # };
        };
      };
    }
  );
}
