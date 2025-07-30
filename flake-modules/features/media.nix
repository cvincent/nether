{ name, ... }:
{
  lib,
  moduleWithSystem,
  helpers,
  ...
}:
{
  flake.nixosModules."${name}" = moduleWithSystem (
    { pkgs }:
    { config, ... }:
    let
      inherit (config.nether) media;
    in
    {
      options.nether.media = {
        enable = lib.mkEnableOption "Media viewing, playing, and acquisition";

        apps = {
          mpv = (helpers.pkgOpt pkgs.mpv true "mpv media player") // {
            config = lib.mkOption {
              type = lib.types.attrs;
              default = {
                keep-open = true;
                fullscreen = false;
                hwdec = "auto";
                save-position-on-quit = true;
              };
            };

            scripts = lib.mkOption {
              type = lib.types.listOf lib.types.package;
              default = with pkgs.mpvScripts; [
                uosc
                thumbfast
              ];
            };

            scriptOpts = lib.mkOption {
              type = lib.types.attrs;
              default = {
                thumbfast.network = true;
                ytdl_hook = lib.mkIf media.apps.ytDlp.enable {
                  ytdl_path = "${media.apps.ytDlp.package.outPath}/bin/yt-dlp";
                };
              };
            };
          };

          obsStudio = (helpers.pkgOpt pkgs.obs-studio true "OBS Studio") // {
            plugins = lib.mkOption {
              type = lib.types.listOf lib.types.package;
              default = [ pkgs.obs-studio-plugins.wlrobs ];
            };
          };

          playerctl = helpers.pkgOpt pkgs.playerctl true "playerctl - CLI for media player controls";
          ytDlp = helpers.pkgOpt pkgs.yt-dlp true "yt-dlp video downloader";
        };

        extra = {
          lofiHipHop = helpers.boolOpt true "lfhh alias for quickly starting lo-fi hip hop radio: beats to relax/study to";
        };
      };

      config = lib.mkIf media.enable (
        lib.mkMerge [
          {
            nether.backups.paths."${config.nether.homeDirectory}/videos".deleteMissing = true;
          }
          (lib.mkIf media.extra.lofiHipHop {
            nether.shells.aliases.lfhh = "mpv --no-resume-playback --force-window=immediate --http-proxy='https://192.168.1.114:8888' 'https://www.youtube.com/watch?v=jfKfPfyJRdk'";
          })
          (lib.mkIf media.apps.mpv.enable {
            nether.shells.aliases.m = "mpv --force-window=immediate --volume=50 $argv & disown";
          })
        ]
      );
    }
  );

  flake.homeModules."${name}" =
    { osConfig, ... }:
    let
      inherit (osConfig.nether) media;
    in
    {
      config = lib.mkIf media.enable {
        home.packages =
          [ ]
          ++ lib.optional media.apps.ytDlp.enable media.apps.ytDlp.package
          ++ lib.optional media.apps.playerctl.enable media.apps.playerctl.package;

        programs.mpv = {
          enable = media.apps.mpv.enable;
          package = media.apps.mpv.package;
          inherit (media.apps.mpv) config scripts scriptOpts;
        };

        programs.obs-studio = {
          inherit (media.apps.obsStudio) enable package plugins;
        };
      };
    };
}
