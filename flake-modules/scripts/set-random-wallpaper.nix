{ name }:
{ lib, moduleWithSystem, ... }:
{
  flake.homeModules."${name}" = moduleWithSystem (
    { pkgs }:
    { osConfig, ... }:
    let
      inherit (osConfig.nether) dotfilesDirectory;
      inherit (osConfig.nether.graphicalEnv) wallpapers;

      set-random-wallpaper = (
        pkgs.writeShellScriptBin "set-random-wallpaper" ''
          PATH=$PATH:/run/current-system/sw/bin

          top_wallpaper=$(find ${dotfilesDirectory}/resources/wallpapers/nord-* -type f | sort -R | head -n1)
          ${wallpapers.swww.package}/bin/swww img -o DP-2 $top_wallpaper

          landscape_wallpaper=$(find ${dotfilesDirectory}/resources/wallpapers/landscapes/nord-*-m0\.* -type f | sort -R | head -n1)
          landscape_right=$''\{landscape_wallpaper/m0\./m1\.}
          ${wallpapers.swww.package}/bin/swww img -o DP-3 $landscape_wallpaper
          ${wallpapers.swww.package}/bin/swww img -o DP-1 $landscape_right
        ''
      );
    in
    {
      # TODO: Consider making this agnostic about our wallpaper switcher
      # It could potentially be its own Flake
      config = lib.mkIf (wallpapers.which == "swww") {
        home.packages = [ set-random-wallpaper ];

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
      };
    }
  );
}
