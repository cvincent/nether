{ name }:
{ lib, moduleWithSystem, ... }:
{
  flake.nixosModules."${name}" = moduleWithSystem (
    { pkgs, self' }:
    { config, ... }:
    {
      options = {
        nether.stylix = lib.mkOption {
          type = lib.types.attrs;
          default = {
            enable = true;
            image = ../wallpapers/nord-irithyll.png;
            # base16Scheme = lib.mkForce "${pkgs.base16-schemes}/share/themes/nord.yaml";
            polarity = "dark";

            targets.fish.enable = false;

            opacity.popups = 0.8;

            cursor = {
              package = pkgs.nordzy-cursor-theme;
              name = "Nordzy-cursors";
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
      inherit (osConfig.nether) stylix;

      dconf = {
        enable = osConfig.nether.stylix.enable;
        settings = {
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
          };
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
