{
  description = "My dotfiles Flake";

  outputs = inputs@{ nixpkgs, home-manager, ... }:
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
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    hyprland.url = "github:hyprwm/Hyprland?ref=v0.34.0";
    xremap-flake.url = "github:xremap/nix-flake";
    stylix.url = "github:danth/stylix";
  };
}
