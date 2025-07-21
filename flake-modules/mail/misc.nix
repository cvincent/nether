{ private-nethers }:
{
  lib,
  config,
  pkgs,
  helpers,
  ...
}:
{
  home.packages = with pkgs; [
    isync # Sync IMAP locally
    pandoc # To view text/html emails
    msmtp # Send email from command line
    vdirsyncer # Sync contacts and calendars
    khard # Contacts TUI
    khal # Calendar TUI

    (writeShellScriptBin "file-email" ''
      # cat /dev/stdin > test.out

      address=$(cat /dev/stdin | grep "^From:" -A1 | sed -z 's/From:.*<\(.\+\)>/\1/; s/\r//g' | head -n1)

      choices="Important\nFeed\nDev\nPaper Trail\nScreened Out\n"
      choice=$(echo -e $choices | fuzzel -p "File $address: " --dmenu)
      dir=""

      case $choice in
      "Important")
        dir="important";;
      "Feed")
        dir="feed";;
      "Dev")
        dir="dev";;
      "Paper Trail")
        dir="paper_trail";;
      "Screened Out")
        dir="screened_out";;
      esac

      if [ $dir ]; then
        echo $address >> /backup/imapfilter/$dir/by_address
        notify-send -i dialog-information -t 5000 -e "Filed $address to $choice."
      fi
    '')
  ];

  programs.aerc.enable = true;
  services.vdirsyncer.enable = true;
  services.vdirsyncer.frequency = "*-*-* *:*:00"; # Every minute

  home.file = {
    "./.mbsyncrc".text = private-nethers.mail.mbsyncRC;
    "./.config/aerc/aerc.conf".source = helpers.directSymlink ./aerc/aerc.conf;
    "./.config/aerc/binds.conf".source = helpers.directSymlink ./aerc/binds.conf;
    "./.config/aerc/stylesets".source = helpers.directSymlink ./aerc/stylesets;

    "./.config/aerc/accounts.conf.dummy" = {
      text = private-nethers.mail.aercAccountsConf;
      onChange = ''
        rm -f ${config.home.homeDirectory}/.config/aerc/accounts.conf
        cp ${config.home.homeDirectory}/.config/aerc/accounts.conf.dummy ${config.home.homeDirectory}/.config/aerc/accounts.conf
        chmod 0600 ${config.home.homeDirectory}/.config/aerc/accounts.conf
      '';
    };

    "./.config/khard/khard.conf".source = ./khard.conf;
    "./.config/khal/config".source = ./khal.conf;
    "./.config/vdirsyncer/config".text = private-nethers.mail.vdirsyncerConfig;
  };

  systemd.user.services =
    let
      vdirsyncer = "${config.services.vdirsyncer.package}/bin/vdirsyncer";
      discover = pkgs.writeShellScript "vdirsyncer-discover-wrapper" ''
        # `yes` can sometimes result in a broken pipe; suppress that
        (${pkgs.coreutils}/bin/yes ||:) | ${vdirsyncer} discover $1
      '';
      discoverService = (
        name: Description: {
          Install.RequiredBy = [ "vdirsyncer.service" ];
          Unit = {
            inherit Description;
            Before = [ "vdirsyncer.service" ];
          };
          Service = {
            Type = "oneshot";
            ExecStart = "${discover} ${name}";
          };
        }
      );
    in
    {
      vdirsyncer-discover-apple-calendars = discoverService "icloud_calendars" "Initial setup for iCloud calendars";
      vdirsyncer-discover-apple-contacts = discoverService "icloud_contacts" "Initial setup for iCloud contacts";
      vdirsyncer-discover-work-calendar =
        lib.attrsets.recursiveUpdate (discoverService "work_calendar" "Initial setup for work calendar")
          {
            Unit.After = [ "davmail.service" ];
            Unit.Requires = [ "davmail.service" ];
          };
    };
}
