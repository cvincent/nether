{ pkgs, inputs, ... }:

{
  imports = [
    inputs.stylix.homeManagerModules.stylix
    ./common.nix
  ];

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
}
