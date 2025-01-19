{
  pkgs,
  nixpkgs-yt-dlp,
  ...
}:

let
  yt-dlp = nixpkgs-yt-dlp.yt-dlp;
in
{
  home.packages = [ yt-dlp ];

  programs.mpv = {
    enable = true;
    config = {
      keep-open = true;
      fullscreen = false;
      hwdec = "auto";
      save-position-on-quit = true;
    };
    scriptOpts = {
      thumbfast.network = true;
      ytdl_hook.ytdl_path = "${yt-dlp.outPath}/bin/yt-dlp";
    };
    scripts = with pkgs.mpvScripts; [
      uosc
      thumbfast
    ];
  };
}
