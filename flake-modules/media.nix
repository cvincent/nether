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
      };
    }
  );
}
