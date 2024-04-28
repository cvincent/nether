{
  description = "My dotfiles Flake";

  outputs = inputs@{ nixpkgs, nixpkgs-latest, home-manager, ... }:
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
      myTZ = "America/Chicago";
      myLocale = "en_US.UTF-8";

      nixpkgs-latest = import inputs.nixpkgs-latest {
        inherit system;
        config.allowUnfree = true;
      };

      nixpkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

      our-discord = import inputs.our-discord {
        inherit system;
        config.allowUnfree = true;
      };
    };
  in {
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
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.4.1";

    sops-nix.url = "github:Mic92/sops-nix";
    hyprland.url = "github:hyprwm/Hyprland?ref=v0.34.0";
    xremap-flake.url = "github:xremap/nix-flake";
    stylix.url = "github:danth/stylix";
    our-discord.url = "github:nixos/nixpkgs/080a4a27f206d07724b88da096e27ef63401a504";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };
}
