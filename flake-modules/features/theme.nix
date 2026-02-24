{ name, mkFeature, ... }:
mkFeature name (
  {
    config,
    theme,
    lib,
    pkgs,
    self',
    ...
  }:
  {
    options = {
      theme = lib.mkOption {
        type = lib.types.str;
        default = "nord";
      };

      themeName = lib.mkOption {
        type = lib.types.str;
        default = config.lib.stylix.colors.scheme;
      };

      polarity = lib.mkOption {
        type = lib.types.str;
        default = "dark";
      };

      isDark = lib.mkOption {
        type = lib.types.bool;
        default = theme.polarity == "dark";
      };

      stylix = lib.mkOption {
        type = lib.types.attrs;
        default = {
          enable = true;
          image = ../../resources/wallpapers/nord-irithyll.png;
          base16Scheme = lib.mkForce "${pkgs.base16-schemes}/share/themes/${theme.theme}.yaml";
          polarity = theme.polarity;

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

    nixos = { inherit (theme) stylix; };

    hm = {
      stylix.targets.waybar.enable = false;

      dconf = {
        enable = true;
        settings = {
          "org/gnome/desktop/interface".color-scheme = "prefer-${theme.polarity}";
          "org/gtk/settings/debug".enable-inspector-keybinding = true;
        };
      };

      gtk = {
        enable = true;
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
    };
  }
)
