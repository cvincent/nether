{ config, lib, pkgs, inputs, stylix, ... }:

{
  stylix = {
    image = ../wallpapers/nord-irithyll.png;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/nord.yaml";
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
        package = pkgs.fonts.PragmataPro;
      };

      serif = config.stylix.fonts.monospace;
      sansSerif = config.stylix.fonts.monospace;
      emoji = config.stylix.fonts.monospace;
    };
  };
}
