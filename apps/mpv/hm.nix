{
  nixpkgs-yt-dlp,
  ...
}:

{
  nixpkgs.overlays = [
    (self: super: {
      mpv = super.mpv.override {
        scripts = with self.mpvScripts; [
          uosc
          thumbfast
        ];
      };
    })
  ];

  home.packages = [ nixpkgs-yt-dlp.yt-dlp ];

  programs.mpv = {
    enable = true;
    config = {
      keep-open = true;
      fullscreen = false;
      hwdec = "auto";
    };
    scriptOpts = {
      thumbfast.network = true;
    };
  };
}
