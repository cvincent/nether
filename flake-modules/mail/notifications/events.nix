{ config, pkgs, ... }:
let
  watch-vdirsyncer-dir = (
    pkgs.writeShellScriptBin "watch-vdirsyncer-dir" ''
      #!/usr/bin/env bash

      PATH=$PATH:/run/current-system/sw/bin

      mkdir -p ${config.home.homeDirectory}/.cache/event-notifications
      touch ${config.home.homeDirectory}/.cache/event-notifications/next-15m-seen
      touch ${config.home.homeDirectory}/.cache/event-notifications/next-1m-seen

      now=$(date +"%Y-%m-%d %I:%M %p")
      # now="2024-04-16 09:59 AM"

      (
        ${pkgs.khal}/bin/khal list --notstarted --format "{uid}|{title}|{start-time}|{duration}|{location}|15m" "$now" "15m" --day-format "" 2> /dev/null &
        ${pkgs.khal}/bin/khal list --notstarted --format "{uid}|{title}|{start-time}|{duration}|{location}|1m" "$now" "1m" --day-format "" 2> /dev/null
      ) | while read event
      do
        uid=$(echo $event | cut -d"|" -f1)
        title=$(echo $event | cut -d"|" -f2)
        start_time=$(echo $event | cut -d"|" -f3)
        duration=$(echo $event | cut -d"|" -f4)
        location=$(echo $event | cut -d"|" -f5)
        starts_in=$(echo $event | cut -d"|" -f6)

        seen=$(grep "$uid" ${config.home.homeDirectory}/.cache/event-notifications/next-$starts_in-seen)

        if [ "$seen" == "" ]; then
          echo $uid >> ${config.home.homeDirectory}/.cache/event-notifications/next-$starts_in-seen
          ${notify-event}/bin/notify-event "$title" "in $starts_in ($start_time)" "$location" & disown
        fi
      done
    ''
  );

  notify-event = (
    pkgs.writeShellScriptBin "notify-event" ''
      #!/usr/bin/env bash

      ${pkgs.alsa-utils}/bin/aplay ${config.home.homeDirectory}/dotfiles/resources/notification.wav &
      resp=$(${pkgs.libnotify}/bin/notify-send -u critical -i dialog-information -A "default=Open" "$1" "$2")

      if [ "$resp" == "default" ]; then
        ${pkgs.chromium}/bin/chromium $3
      fi
    ''
  );
in
{
  home.packages = [
    watch-vdirsyncer-dir
    notify-event
  ];

  systemd.user.services.send-event-notifications = {
    Unit.PartOf = [ "graphical.target" ];
    Unit.After = [ "graphical.target" ];
    Install.WantedBy = [ "graphical.target" ];
    Service.ExecStart = "${watch-vdirsyncer-dir}/bin/watch-vdirsyncer-dir";
    Service.Type = "forking";
  };

  systemd.user.timers.send-event-notifications = {
    Install.WantedBy = [ "timers.target" ];
    Timer.OnCalendar = "*:*:00,20,40";
    Timer.AccuracySec = "1s";
  };

  systemd.user.services.clear-send-event-notifications-cache = {
    Install.WantedBy = [ "graphical.target" ];
    Service.ExecStart = "rm ${config.home.homeDirectory}/.cache/event-notifications/*";
    Service.Type = "oneshot";
  };

  systemd.user.timers.clear-send-event-notifications-cache = {
    Install.WantedBy = [ "timers.target" ];
    Timer.OnCalendar = "02:00:00";
    Timer.AccuracySec = "1s";
  };
}
