{ config, pkgs, utils, ... }:

{
  home.packages = [
    pkgs.spotifyd
    pkgs.spotify-tui
  ];

  sops.secrets."spotify/username" = {};
  sops.secrets."spotify/password" = {};

  systemd.user.services.spotifyd = {
    Install.WantedBy = [ "multi-user.target" ];
    Environment.SHELL = "/bin/sh";
    Unit.After = [ "sops-nix.service" ];

    # Not sure why I have to specify the full path for cat here
    Service.ExecStart = ''
      ${pkgs.spotifyd}/bin/spotifyd \
      --no-daemon \
      --use-mpris=true \
      --backend=pulseaudio \
      --username-cmd='/run/current-system/sw/bin/cat ${config.sops.secrets."spotify/username".path}' \
      --password-cmd='/run/current-system/sw/bin/cat ${config.sops.secrets."spotify/password".path}'
    '';
  };

  home.file."./.config/spotify-tui/config.yml".source = utils.directSymlink "apps/spotify/spotify-tui-config.yml";
}
