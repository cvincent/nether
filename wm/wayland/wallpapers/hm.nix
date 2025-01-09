{ pkgs, myHomeDir, ... }:

let
  set-random-wallpaper = (
    pkgs.writeShellScriptBin "set-random-wallpaper" ''
      PATH=$PATH:/run/current-system/sw/bin

      top_wallpaper=$(find ${myHomeDir}/dotfiles/wallpapers/nord-* -type f | sort -R | head -n1)
      ${pkgs.swww}/bin/swww img -o DP-2 $top_wallpaper

      landscape_wallpaper=$(find ${myHomeDir}/dotfiles/wallpapers/landscapes/nord-*-m0\.* -type f | sort -R | head -n1)
      landscape_right=$''\{landscape_wallpaper/m0\./m1\.}
      ${pkgs.swww}/bin/swww img -o DP-3 $landscape_wallpaper
      ${pkgs.swww}/bin/swww img -o DP-1 $landscape_right
    ''
  );
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
