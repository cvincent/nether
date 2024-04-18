{ pkgs, myHomeDir, ... }:

let
  set-random-wallpaper = (pkgs.writeShellScriptBin "set-random-wallpaper" ''
    PATH=$PATH:/run/current-system/sw/bin
    ${pkgs.swww}/bin/swww img $(find ${myHomeDir}/dotfiles/wallpapers/nord-* -type f | sort -R | head -n1)
  '');
in
{
  home.packages = [
    pkgs.swww
    set-random-wallpaper
  ];

  systemd.user.services.set-random-wallpaper = {
    Unit.PartOf = [ "graphical.target" ];
    Unit.After = [ "graphical.target" ];
    Install.WantedBy = [ "graphical.target" ];
    Service.ExecStart = "${set-random-wallpaper}/bin/set-random-wallpaper";
    Service.Type = "oneshot";
  };

  systemd.user.timers.set-random-wallpaper = {
    Install.WantedBy = [ "timers.target" ];
    Timer.OnCalendar = "*:00,20,40:00";
    Timer.AccuracySec = "1s";
  };
}
