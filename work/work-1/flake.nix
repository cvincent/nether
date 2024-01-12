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
    # PostgreSQL 14.10
    our-postgresql.url = "github:nixos/nixpkgs/f5c27c6136db4d76c30e533c20517df6864c46ee";
  };

  outputs = { self, nixpkgs, ... }@inputs:
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
  {
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        inputs.our-erlang.legacyPackages.${system}.erlangR25
        inputs.our-elixir.legacyPackages.${system}.elixir_1_15
        our-elixir-ls
        inputs.our-nodejs.legacyPackages.${system}.nodejs
        inputs.our-postgresql.legacyPackages.${system}.postgresql_14
        redis
        cockroachdb-bin
        inotify-tools
      ];

      PGDATA="./pgdata";

      # On first time:
      # initdb in base dir
      # createuser -s postgres -h localhost

      shellHook = ''
        echo "$(elixir --version | tr -s '\n')"
        echo "Node $(node --version)"
        echo "PostgreSQL $(psql --version | cut -d' ' -f3)"
        echo $(redis-server --version)
        echo "CockroachDB $(cockroachdb --version | grep 'Build Tag' | tr -s ' ' | cut -d' ' -f3)"
        echo ""
        echo "LFG."
      '';
    };
  };
}
