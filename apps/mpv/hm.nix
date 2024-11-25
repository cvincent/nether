{
  nixpkgs-unstable-latest,
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

  home.packages = [ nixpkgs-unstable-latest.yt-dlp ];

  programs.mpv = {
    enable = true;
    config = {
      keep-open = true;
      fullscreen = false;
    };
    scriptOpts = {
      thumbfast.network = true;
    };
  };
}
