{
  description = "Flake for my main contract";

  # Find package versions at nixhub.io
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    # Erlang 26.2.1
    our-erlang.url = "github:nixos/nixpkgs/16e046229f3b4f53257973a5532bcbb72457d2f2";
    # NodeJS 18.15.0
    our-nodejs.url = "github:nixos/nixpkgs/96ba1c52e54e74c3197f4d43026b3f3d92e83ff9";
    # Yarn 1.22.22
    our-yarn.url = "github:nixos/nixpkgs/4ae2e647537bcdbb82265469442713d066675275";
    # PostgreSQL 14.10
    our-postgresql.url = "github:nixos/nixpkgs/f5c27c6136db4d76c30e533c20517df6864c46ee";
    # RabbitMQ 4.0.7
    our-rabbitmq.url = "github:nixos/nixpkgs/25d1b84f5c90632a623c48d83a2faf156451e6b1";

    next-ls.url = "github:elixir-tools/next-ls";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        system = system;
        config.allowUnfree = true;
      };

      beamPkg = pkgs.beam.packagesWith inputs.our-erlang.legacyPackages.${system}.erlang_26;

      our-elixir = beamPkg.elixir.overrideAttrs (old: {
        name = "elixir-1.16.0";
        src = pkgs.fetchFromGitHub {
          rev = "v1.16.0";
          sha256 = "sha256-nM3TpX18zdjDAFkljsAqwKx/1AQmwDMIQCeL75etTQc=";
          owner = "elixir-lang";
          repo = "elixir";
        };
      });

      our-elixir-ls = pkgs.beam26Packages.elixir-ls;
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          inputs.next-ls.packages.${system}.default
          inputs.our-erlang.legacyPackages.${system}.erlang_26
          our-elixir
          our-elixir-ls
          inputs.our-nodejs.legacyPackages.${system}.nodejs
          inputs.our-yarn.legacyPackages.${system}.yarn
          inputs.our-postgresql.legacyPackages.${system}.postgresql_14
          inputs.our-rabbitmq.legacyPackages.${system}.rabbitmq-server
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
