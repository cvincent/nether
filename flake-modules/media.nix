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

        mpv.enable = lib.mkEnableOption "mpv media player";

        ytDlp.enable = lib.mkEnableOption "yt-dlp video downloader";

        playerctl = helpers.pkgOpt pkgs.playerctl true "playerctl - CLI for media player controls";
      };
    }
  );

  flake.homeModules."${name}" = moduleWithSystem (
    { pkgs, pkgInputs }:
    { osConfig, ... }:
    let
      yt-dlp = pkgInputs.nixpkgs-yt-dlp.yt-dlp;
      inherit (osConfig.nether) media;
    in
    {
      config = lib.mkIf media.enable {
        home.packages =
          [ ]
          ++ lib.optional media.ytDlp.enable yt-dlp
          ++ lib.optional media.playerctl.enable media.playerctl.package;

        programs.mpv = {
          enable = media.mpv.enable;
          config = {
            keep-open = true;
            fullscreen = false;
            hwdec = "auto";
            save-position-on-quit = true;
          };
          scriptOpts = {
            thumbfast.network = true;
            ytdl_hook = lib.mkIf media.ytDlp.enable {
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
