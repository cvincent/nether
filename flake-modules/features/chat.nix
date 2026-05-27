{ name, mkFeature, ... }:
mkFeature name (
  { nether, pkgInputs, ... }:
  {
    description = "The many chat apps of the Internet";

    apps =
      let
        withBackupPath = homeRelDir: {
          nixos.nether.backups.paths."${nether.homeDirectory}/${homeRelDir}".deleteMissing = true;
        };
      in
      {
        bluebubbles = withBackupPath ".local/share/app.bluebubbles.BlueBubbles";

        discord-canary = (withBackupPath ".config/discordcanary") // {
          package = pkgInputs.nixpkgs-discord.discord-canary;
        };

        discord = (withBackupPath ".config/discord") // {
          package = pkgInputs.nixpkgs-discord.discord;
        };

        signal-desktop = withBackupPath ".config/Signal";
        slack = withBackupPath ".config/Slack";
        element-desktop = { };

        zoom-us = {
          nixos.nether.backups.paths = {
            "${nether.homeDirectory}/.config/zoom.conf".deleteMissing = true;
            "${nether.homeDirectory}/.config/zoomus.conf".deleteMissing = true;
          };
        };
      };
  }
)
