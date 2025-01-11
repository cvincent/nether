{ pkgs, browser-pkgs, ... }:

{
  home.packages = with pkgs; [
    (browser-pkgs.chromium.override {
      commandLineArgs = [
        "--enable-features=VaapiVideoEncoder"
        "--ignore-gpu-blocklist"
        "--enable-zero-copy"
      ];
    })
    (browser-pkgs.brave.override {
      commandLineArgs = [
        "--enable-features=VaapiVideoEncoder"
        "--ignore-gpu-blocklist"
        "--enable-zero-copy"
      ];
    })
    firefox
  ];

  imports = [ ./qutebrowser/hm.nix ];
}
