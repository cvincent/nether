{
  description = "My dotfiles Flake";

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      commonArgs = rec {
        inherit inputs;
        myUsername = "cvincent";
        myHomeDir = "/home/${myUsername}";
        myHostname = "nether";
        mySopsKey = /home/${myUsername}/.config/sops/age/keys.txt;
        mySystem = system;
        myTZ = "America/Chicago";
        myLocale = "en_US.UTF-8";

        importAttrs = {
          inherit system;
          config.allowUnfree = true;
        };

        nixpkgs-latest = import inputs.nixpkgs-latest importAttrs;
        nixpkgs-unstable = import inputs.nixpkgs-unstable importAttrs;
        nixpkgs-unstable-latest = import inputs.nixpkgs-unstable-latest importAttrs;
        browser-pkgs = import inputs.browser-pkgs importAttrs;
        nixpkgs-slack = import inputs.nixpkgs-slack importAttrs;
        nixpkgs-yt-dlp = import inputs.nixpkgs-yt-dlp importAttrs;
        nixpkgs-zoom = import inputs.nixpkgs-zoom importAttrs;
      };
    in
    {
      nixosConfigurations = {
        "${commonArgs.myHostname}" = lib.nixosSystem {
          inherit system;
          specialArgs = commonArgs;

          modules = [
            ./configuration.nix
          ];
        };
      };

      homeConfigurations = {
        "${commonArgs.myUsername}" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = commonArgs;

          modules = [
            ./utils.nix
            ./home.nix
          ];
        };
      };
    };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    nixpkgs-latest.url = "nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    nixpkgs-unstable-latest.url = "nixpkgs/nixos-unstable";
    browser-pkgs.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.4.1";

    sops-nix.url = "github:Mic92/sops-nix";
    hyprland.url = "github:hyprwm/Hyprland?ref=v0.45.0";
    xremap-flake.url = "github:xremap/nix-flake";
    stylix.url = "github:danth/stylix";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    nixpkgs-slack.url = "nixpkgs/nixos-unstable";
    nixpkgs-zoom.url = "github:NixOS/nixpkgs/18536bf04cd71abd345f9579158841376fdd0c5a";
    nixpkgs-yt-dlp.url = "nixpkgs/nixos-unstable";
    ha-notifier.url = "github:cvincent/ha-notifier";
  };
}
