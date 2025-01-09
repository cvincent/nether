{
  description = "Flake for my main contract";

  # Find package versions at nixhub.io
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    # Erlang 25.1.2
    our-erlang.url = "github:nixos/nixpkgs/80c24eeb9ff46aa99617844d0c4168659e35175f";
    # Elixir 1.15.7
    our-elixir.url = "github:nixos/nixpkgs/90e85bc7c1a6fc0760a94ace129d3a1c61c3d035";
    # NodeJS 18.14.1
    our-nodejs.url = "github:nixos/nixpkgs/06365ba4549654b7ce58c33365c1282800e83a9e";
    # Yarn 1.22.22
    our-yarn.url = "github:nixos/nixpkgs/4ae2e647537bcdbb82265469442713d066675275";
    # PostgreSQL 14.10
    our-postgresql.url = "github:nixos/nixpkgs/f5c27c6136db4d76c30e533c20517df6864c46ee";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        system = system;
        config.allowUnfree = true;
      };

      elixir = inputs.our-elixir.legacyPackages.${system}.elixir_1_15;
      beamPkg = pkgs.beam.packagesWith inputs.our-erlang.legacyPackages.${system}.erlangR25;
      our-elixir-ls = pkgs.elixir-ls.override {
        inherit elixir;
        mixRelease = beamPkg.mixRelease.override { inherit elixir; };
      };

    in
    # our-cockroachdb-bin = pkgs.cockroachdb-bin.overrideAttrs (oldAttrs: rec {
    #   version = "22.1.22";
    #   srcs = {
    #     x86_64-linux = pkgs.fetchzip {
    #       url = "https://binaries.cockroachdb.com/cockroach-v${version}.linux-amd64.tgz";
    #       hash = "";
    #     };
    #   };
    # });
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          inputs.our-erlang.legacyPackages.${system}.erlangR25
          inputs.our-elixir.legacyPackages.${system}.elixir_1_15
          our-elixir-ls
          inputs.our-nodejs.legacyPackages.${system}.nodejs
          inputs.our-yarn.legacyPackages.${system}.yarn
          inputs.our-postgresql.legacyPackages.${system}.postgresql_14
          inotify-tools
          # We run redis-stack-server using an AppImage because nobody has built
          # the package for NixOS yet :( And I don't feel like doing it
          # ¯\_(ツ)_/¯
          appimage-run
          # TODO: Figure out how to properly override the nixpkgs version and do
          # this correctly. Or just wait until we dump this shitty software.
          (pkgs.callPackage ./cockroachdb.nix {
            version = "22.2.19";
            version-hash = "sha256-AUkFMaCfWNirtdAy9GhNPzeAuRaklCfW35GPt8h9KPM=";
          })
        ];
        # change

        PGDATA = "./pgdata";

        # On first time:
        # initdb in base dir
        # createuser -s postgres -h localhost

        shellHook = ''
          echo "$(elixir --version | tr -s '\n')"
          echo "Node $(node --version)"
          echo "PostgreSQL $(psql --version | cut -d' ' -f3)"
          echo "CockroachDB $(cockroachdb --version | grep 'Build Tag' | tr -s ' ' | cut -d' ' -f3)"
          echo ""
          echo "LFG."
        '';
      };
    };
}
