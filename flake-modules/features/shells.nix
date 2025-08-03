{
  name,
  mkFeature,
  mkSoftwareChoice,
  ...
}:
mkFeature name (
  { lib, shells, ... }:
  (mkSoftwareChoice lib name "toplevel" shells {
    fish = { };
    zsh = { };
  })
  |> lib.recursiveUpdate {
    description = "Shells and shell tools and commands";

    options = {
      aliases = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
      };
    };

    extra =
      {
        description = "Various useful shell utilities";
        eza.config.enableFishIntegration = shells.fish.enable;
        starship.config.enableFishIntegration = shells.fish.enable;
        zoxide.config.enableFishIntegration = shells.fish.enable;
      }
      |> lib.recursiveUpdate (
        [
          "bat"
          "btop"
          "direnv"
          "fastfetch"
          "fd"
          "fzf"
          "gh"
          "jq"
          "ripgrep"
          "d2"
          "dua"
          "duf"
          "dust"
          "fx"
          "unzip"
          "magic-wormhole"
          "zf"
        ]
        |> map (package: {
          name = package;
          value = { };
        })
        |> lib.listToAttrs
      );

    # TODO: Figure out why lib.mkForce is needed here, it's very strange
    nixos.nether.shells = lib.mkForce { aliases.mkdir = "mkdir -p"; };
  }
)
