{
  description = "My dotfiles flake.";

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      flake-parts,
      self,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      let
        # commonArgs = rec {
        #   myTestSecret = inputs.private-nethers.my-secrets.hi;
        # };

        hosts =
          ./hosts
          |> builtins.readDir
          |> (nixpkgs.lib.attrsets.filterAttrs (_k: v: v == "directory"))
          |> nixpkgs.lib.attrsets.attrNames;
      in
      flake@{ lib, ... }:
      {
        perSystem =
          { ... }:
          {
            _module.args.pkgs = import self.inputs.nixpkgs { config.allowUnfree = true; };

            _module.args.pkgInputs = builtins.mapAttrs (
              _: input: import input { config.allowUnfree = true; }
            ) self.inputs;
          };

        imports = [
          home-manager.flakeModules.home-manager
          ./flake-modules
        ];

        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ];

        flake = {
          nixosConfigurations = nixpkgs.lib.attrsets.genAttrs hosts (
            host:
            (nixpkgs.lib.nixosSystem {
              modules = lib.attrsets.attrValues flake.config.flake.nixosModules ++ [
                ./hosts/${host}
                { nether.hostname = host; }
                home-manager.nixosModules.home-manager
                (
                  system@{ ... }:
                  {
                    # Use same pkgs for HM as system; saves eval, adds
                    # consistency, and removes dependency on NIX_PATH
                    home-manager.useGlobalPkgs = true;

                    # Install to /etc/profiles instead of ~/.nix-profile. Needed
                    # for `nixos-rebuild build-vm` to work
                    home-manager.useUserPackages = true;

                    home-manager.users."${system.config.nether.username}" = {
                      # Automatically import any homeModules that were defined
                      imports = nixpkgs.lib.attrsets.attrValues flake.config.flake.homeModules ++ [
                        { programs.home-manager.enable = true; }
                        (
                          hm@{ ... }:
                          {
                            _module.args.utils.directSymlink = (
                              path: hm.config.lib.file.mkOutOfStoreSymlink "${hm.config.home.homeDirectory}/dotfiles/${path}"
                            );
                          }
                        )
                      ];
                    };
                  }
                )
              ];
            })
          );
        };
      }
    );

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "nixpkgs/nixos-24.11";
    nixpkgs-latest.url = "nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    nixpkgs-unstable-latest.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    private-nethers.url = "git+ssh://git@github.com/cvincent/private-nethers.git?ref=main";
    sops-nix.url = "github:Mic92/sops-nix";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.4.1";

    browser-pkgs.url = "nixpkgs/nixos-unstable";
    ha-notifier.url = "github:cvincent/ha-notifier";
    hyprland.url = "github:hyprwm/Hyprland?ref=v0.45.0";
    nixpkgs-kitty.url = "nixpkgs/nixos-unstable";
    nixpkgs-neovim.url = "nixpkgs/nixos-unstable";
    nixpkgs-signal.url = "nixpkgs/nixos-unstable";
    nixpkgs-slack.url = "nixpkgs/nixos-unstable";
    nixpkgs-spotify.url = "nixpkgs/nixos-unstable";
    nixpkgs-yt-dlp.url = "nixpkgs/nixos-unstable";
    nixpkgs-zoom.url = "github:NixOS/nixpkgs/3f316d2a50699a78afe5e77ca486ad553169061e";
    stylix.url = "github:danth/stylix";
    xremap-flake.url = "github:xremap/nix-flake";
  };
}
