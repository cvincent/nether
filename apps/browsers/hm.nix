{ pkgs, nixpkgs-unstable, ... }:

{
  home.packages = with pkgs; [
    (nixpkgs-unstable.chromium.override {
      commandLineArgs = [
        "--enable-features=VaapiVideoEncoder"
        "--ignore-gpu-blocklist"
        "--enable-zero-copy"
      ];
    })
    (nixpkgs-unstable.brave.override {
      commandLineArgs = [
        "--enable-features=VaapiVideoEncoder"
        "--ignore-gpu-blocklist"
        "--enable-zero-copy"
      ];
    })
    firefox
  ];
}
