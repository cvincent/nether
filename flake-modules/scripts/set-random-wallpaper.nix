{ name, mkSoftware, ... }:
mkSoftware name (
  { nether, pkgs, ... }:
  let
    inherit (nether) dotfilesDirectory;
    swww = "${nether.graphicalEnv.wallpapers.default.package}/bin/swww";

    script = (
      pkgs.writeShellScriptBin name ''
        PATH=$PATH:/run/current-system/sw/bin

        top_wallpaper=$(find ${dotfilesDirectory}/resources/wallpapers/nord-* -type f | sort -R | head -n1)
        ${swww} img -o DP-2 $top_wallpaper

        landscape_wallpaper=$(find ${dotfilesDirectory}/resources/wallpapers/landscapes/nord-*-m0\.* -type f | sort -R | head -n1)
        landscape_right=$''\{landscape_wallpaper/m0\./m1\.}
        ${swww} img -o DP-3 $landscape_wallpaper
        ${swww} img -o DP-1 $landscape_right
      ''
    );
  in
  {
    # TODO: Consider making this agnostic about our wallpaper switcher
    hm = {
      home.packages = [ script ];

      systemd.user.services.set-random-wallpaper = {
        Install.WantedBy = [ "graphical-session.target" ];
        Unit.After = [ "graphical-session.target" ];
        Service.ExecStart = "${script}/bin/set-random-wallpaper";
        Service.Type = "oneshot";
      };

      systemd.user.timers.set-random-wallpaper = {
        Install.WantedBy = [ "timers.target" ];
        Timer.OnCalendar = "*:00,20,40:00";
        Timer.AccuracySec = "1s";
      };
    };
  }
)
