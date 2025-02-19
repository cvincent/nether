{
  description = "Flake for my main contract";

  # Find package versions at nixhub.io
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    # Erlang 26.2.1
    our-erlang.url = "github:nixos/nixpkgs/f8e2ebd66d097614d51a56a755450d4ae1632df1";
    # Elixir 1.17.2
    our-elixir.url = "github:nixos/nixpkgs/5ed627539ac84809c78b2dd6d26a5cebeb5ae269";
    # ElixirLS 0.25.0
    our-elixir-ls.url = "github:nixos/nixpkgs/7cc0bff31a3a705d3ac4fdceb030a17239412210";
    # NodeJS 18.14.1
    our-nodejs.url = "github:nixos/nixpkgs/06365ba4549654b7ce58c33365c1282800e83a9e";
    # Yarn 1.22.22
    our-yarn.url = "github:nixos/nixpkgs/4ae2e647537bcdbb82265469442713d066675275";
    # PostgreSQL 14.10
    our-postgresql.url = "github:nixos/nixpkgs/f5c27c6136db4d76c30e533c20517df6864c46ee";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        system = system;
        config.allowUnfree = true;
      };

      elixir = inputs.our-elixir.legacyPackages.${system}.elixir_1_17;
      beamPkg = pkgs.beam.packagesWith inputs.our-erlang.legacyPackages.${system}.erlang_26;
      our-elixir-ls = inputs.our-elixir-ls.legacyPackages.${system}.elixir-ls.override {
        inherit elixir;
        mixRelease = beamPkg.mixRelease.override { inherit elixir; };
      };

    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          inputs.our-erlang.legacyPackages.${system}.erlang_26
          inputs.our-elixir.legacyPackages.${system}.elixir_1_17
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
