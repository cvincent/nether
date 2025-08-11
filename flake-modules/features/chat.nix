{ name, mkFeature, ... }:
mkFeature name (
  { nether, ... }:
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
        discord-canary = withBackupPath ".config/discordcanary";
        discord = withBackupPath ".config/discord";
        fractal = withBackupPath ".local/share/fractal";
        signal-desktop = withBackupPath ".config/Signal";
        slack = withBackupPath ".config/Slack";

        zoom-us = {
          nixos.nether.backups.paths = {
            "${nether.homeDirectory}/.config/zoom.conf".deleteMissing = true;
            "${nether.homeDirectory}/.config/zoomus.conf".deleteMissing = true;
          };
        };
      };
  }
)
