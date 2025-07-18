{ name }:
{
  lib,
  moduleWithSystem,
  helpers,
  ...
}:
{
  flake.nixosModules."${name}" = moduleWithSystem (
    { pkgs }:
    {
      options.nether.media = {
        enable = lib.mkEnableOption "Media viewing, playing, and acquisition";

        apps = {
          mpv = helpers.pkgOpt pkgs.mpv true "mpv media player";
          playerctl = helpers.pkgOpt pkgs.playerctl true "playerctl - CLI for media player controls";
          ytDlp = helpers.pkgOpt pkgs.yt-dlp true "yt-dlp video downloader";
        };
      };
    }
  );

  flake.homeModules."${name}" = moduleWithSystem (
    { pkgs }:
    { osConfig, ... }:
    let
      yt-dlp = media.apps.ytDlp.package;
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
          config = {
            keep-open = true;
            fullscreen = false;
            hwdec = "auto";
            save-position-on-quit = true;
          };
          scriptOpts = {
            thumbfast.network = true;
            ytdl_hook = lib.mkIf media.apps.ytDlp.enable {
              ytdl_path = "${yt-dlp.outPath}/bin/yt-dlp";
            };
          };
          scripts = with pkgs.mpvScripts; [
            uosc
            thumbfast
          ];
        };
      };
    }
  );
}
