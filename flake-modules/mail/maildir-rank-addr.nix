{
  config,
  maildir-rank-addr,
  pkgs,
  ...
}:
let
  sync-script = (
    pkgs.writeShellScriptBin "maildir-sync-contacts" ''
      for dir in ${config.home.homeDirectory}/mail/*/; do
        dir=''${dir%*/}
        dir=''${dir##*/}

        ${maildir-rank-addr}/bin/maildir-rank-addr \
          --maildir=${config.home.homeDirectory}/mail/$dir \
          --outputpath=${config.home.homeDirectory}/.cache/maildir-rank-addr/$dir.tsv
      done
    ''
  );
in
{
  home.packages = [
    maildir-rank-addr
    sync-script
  ];

  systemd.user.services.maildir-sync-contacts = {
    Install.WantedBy = [ "graphical.target" ];
    Service.ExecStart = "${sync-script}/bin/maildir-sync-contacts";
    Service.Type = "oneshot";
  };

  systemd.user.timers.maildir-sync-contacts = {
    Install.WantedBy = [ "timers.target" ];
    Timer.OnCalendar = "Mon..Sun *-*-* 00,12:00:00";
  };
}
