{ name, mkFeature, ... }:
mkFeature name (
  {
    nether,
    media,
    pkgs,
    ...
  }:
  {
    description = "Media viewing, listening, broadcasting, and acquisition";

    apps = {
      ffmpeg = { };

      mpv = {
        config = {
          config = {
            keep-open = true;
            fullscreen = false;
            hwdec = "auto";
            save-position-on-quit = true;
          };

          scripts = with pkgs.mpvScripts; [
            uosc
            thumbfast
          ];

          scriptOpts = {
            thumbfast.network = true;
            ytdl_hook.ytdl_path = "${media.apps.yt-dlp.package.outPath}/bin/yt-dlp";
          };
        };

        nixos.nether.shells.aliases.m =
          "${media.apps.mpv.package}/bin/mpv --force-window=immediate --volume=50 $argv & disown";
      };

      obs-studio.config.plugins = with pkgs.obs-studio-plugins; [ wlrobs ];

      playerctld = { };
      showmethekey = { };

      spotify.nixos.nether.backups.paths."${nether.homeDirectory}/.config/spotify".deleteMissing = true;

      yt-dlp.config = {
        extraConfig = "--update";

        settings = {
          # TODO: Once we've got all our hosts in nether, obv we'll pull this
          # from config
          proxy = "http://192.168.1.114:8888";
          embed-chapters = true;
          embed-thumbnail = true;
          embed-subs = true;
          sub-langs = "all";
        };
      };
    };

    extra.lofiHipHop = {
      package = null;
      nixos.nether.shells.aliases.lfhh =
        "${media.apps.mpv.package}/bin/mpv --no-resume-playback --force-window=immediate --http-proxy='https://192.168.1.114:8888' 'https://www.youtube.com/watch?v=jfKfPfyJRdk'";
    };

    nixos.nether.backups.paths."${nether.homeDirectory}/videos".deleteMissing = true;
  }
)
