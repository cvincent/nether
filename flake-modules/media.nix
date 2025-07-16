{ name }:
{ lib, moduleWithSystem, ... }:
{
  flake.nixosModules."${name}" = {
    options.nether.media = {
      mpv.enable = lib.mkEnableOption "mpv media player";
      ytDlp.enable = lib.mkEnableOption "yt-dlp video downloader";
    };
  };

  flake.homeModules."${name}" = moduleWithSystem (
    { pkgs, pkgInputs }:
    { osConfig, ... }:
    let
      yt-dlp = pkgInputs.nixpkgs-yt-dlp.yt-dlp;
    in
    {
      home.packages = lib.optional osConfig.nether.media.ytDlp.enable yt-dlp;

      programs.mpv = {
        enable = osConfig.nether.media.mpv.enable;
        config = {
          keep-open = true;
          fullscreen = false;
          hwdec = "auto";
          save-position-on-quit = true;
        };
        scriptOpts = {
          thumbfast.network = true;
          ytdl_hook = lib.mkIf osConfig.nether.media.ytDlp.enable {
            ytdl_path = "${yt-dlp.outPath}/bin/yt-dlp";
          };
        };
        scripts = with pkgs.mpvScripts; [
          uosc
          thumbfast
        ];
      };
    }
  );
}
