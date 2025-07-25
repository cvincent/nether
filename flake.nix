{
  description = "My dotfiles flake.";

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      nix-flatpak,
      flake-parts,
      self,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      let
        helpers = import ./helpers.nix;

        hosts =
          ./hosts
          |> builtins.readDir
          |> (nixpkgs.lib.attrsets.filterAttrs (_k: v: v == "directory"))
          |> nixpkgs.lib.attrsets.attrNames;
      in
      flake@{ lib, moduleWithSystem, ... }:
      {
        debug = true;

        perSystem =
          {
            system,
            pkgs,
            inputs',
            ...
          }:
          {
            _module.args.pkgs = import self.inputs.nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };

            # TODO: With `debug = true;`, inspect this with the repl. This seems
            # to only make sense for nixpkgs inputs; the rest error about no
            # `default.nix`. Why aren't we / can't we just using `inputs'`
            # everywhere?
            _module.args.pkgInputs = builtins.mapAttrs (
              _: input:
              import input {
                inherit system;
                config.allowUnfree = true;
              }
            ) self.inputs;

            # TODO: Iterate over the packages directory
            packages.maildir-rank-addr = pkgs.callPackage ./packages/maildir-rank-addr.nix { };
            packages.smartcalc-tui = pkgs.callPackage ./packages/smartcalc-tui.nix { };

            legacyPackages.fonts.Helvetica = inputs'.private-nethers.legacyPackages.fonts.Helvetica;
            legacyPackages.fonts.PragmataPro = inputs'.private-nethers.legacyPackages.fonts.PragmataPro;
          };

        imports = [
          home-manager.flakeModules.home-manager
          helpers.flakeModuleHelpers
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
              # Automatically import any nixosModules that were defined
              modules = lib.attrsets.attrValues flake.config.flake.nixosModules ++ [
                (moduleWithSystem (import ./hosts/${host}))

                {
                  options.nether.hosts = lib.mkOption {
                    type = lib.types.listOf lib.types.str;
                  };

                  config = {
                    _module.args = { inherit inputs; };
                    nixpkgs.config.allowUnfree = true;
                    nether.networking.hostname = host;
                    nether.hosts = hosts;
                    nether.backups.defaultFallbackSource = "revachol";
                  };
                }

                inputs.stylix.nixosModules.stylix
                nix-flatpak.nixosModules.nix-flatpak

                home-manager.nixosModules.home-manager
                (
                  osConfig@{ ... }:
                  {
                    # Use same pkgs for HM as system; saves eval, adds
                    # consistency, and removes dependency on NIX_PATH
                    home-manager.useGlobalPkgs = true;

                    # Install to /etc/profiles instead of ~/.nix-profile. Needed
                    # for `nixos-rebuild build-vm` to work
                    home-manager.useUserPackages = true;

                    home-manager.users."${osConfig.config.nether.username}" = {
                      # Automatically import any homeModules that were defined
                      imports = nixpkgs.lib.attrsets.attrValues flake.config.flake.homeModules ++ [
                        { programs.home-manager.enable = true; }
                        helpers.homeModuleHelpers
                        # Attempting to import these in their related modules
                        # causes infinite recursion
                        inputs.xremap-flake.homeManagerModules.default
                        inputs.ha-notifier.homeManagerModules.default
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
    # TODO: Pinned versions of things should be passed in as options from the
    # host
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "nixpkgs/nixos-25.05";
    nixpkgs-latest.url = "nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    nixpkgs-unstable-latest.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.4.1";
    stylix.url = "github:nix-community/stylix/release-25.05";

    # TODO: Set this in an option one time so anywhere can access it via config
    # or osConfig
    private-nethers.url = "git+ssh://git@github.com/cvincent/private-nethers.git?ref=main";

    browser-pkgs.url = "nixpkgs/nixos-unstable";
    ha-notifier.url = "github:cvincent/ha-notifier";
    hyprland.url = "github:hyprwm/Hyprland?ref=v0.45.0";
    nixpkgs-kitty.url = "nixpkgs/nixos-unstable";
    nixpkgs-neovim.url = "nixpkgs/nixos-unstable";
    nixpkgs-signal.url = "nixpkgs/nixos-unstable";
    nixpkgs-slack.url = "nixpkgs/nixos-unstable";
    nixpkgs-spotify.url = "nixpkgs/nixos-unstable";
    nixpkgs-tmux.url = "nixpkgs/nixos-unstable";
    nixpkgs-yt-dlp.url = "nixpkgs/nixos-unstable";
    nixpkgs-zoom.url = "github:NixOS/nixpkgs/3f316d2a50699a78afe5e77ca486ad553169061e";
    xremap-flake.url = "github:xremap/nix-flake";

    # Package dropped from later NixOS
    nixpkgs-peroxide.url = "nixpkgs/nixos-24.11";
    # Latest version crashes due to GPU shit
    nixpkgs-qutebrowser.url = "nixpkgs/nixos-24.11";
  };
}
