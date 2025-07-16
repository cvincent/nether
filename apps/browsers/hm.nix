{ pkgs, browser-pkgs, ... }:

{
  # Add this line to nixosModule
  # Silences warnings on Chromium boot, and useful for checking battery levels
  # from CLI
  # services.upower.enable = true;
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
