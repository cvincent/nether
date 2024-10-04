{ config, inputs, ... }:

let
  zoom-pkgs = import inputs.nixpkgs-zoom {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in
{
  home.packages = [
    zoom-pkgs.zoom-us
  ];

  xdg.configFile."zoomus.conf" = {
    text = ''
    [General]
    xwayland=true
    enableWaylandShare=true
    '';
  };
}
