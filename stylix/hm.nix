{ pkgs, inputs, ... }:

{
  imports = [
    inputs.stylix.homeManagerModules.stylix
    ./common.nix
  ];

  # We want this here when we get back to Stylix/theming
  # dconf = {
  #   enable = true;
  #   settings = {
  #     "org/gnome/desktop/interface" = {
  #       color-scheme = "prefer-dark";
  #     };
  #   };
  # };

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
