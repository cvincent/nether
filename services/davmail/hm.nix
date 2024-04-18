{ pkgs, lib, ... }:

{
  systemd.user.services.davmail = {
    description = "DavMail POP/IMAP/SMTP Exchange Gateway";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.davmail}/bin/davmail ~/.davmail.properties";
      Restart = "on-failure";
    };
  };

  home.packages = [ pkgs.davmail ];
}
