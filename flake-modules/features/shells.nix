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

    extra = {
      description = "Various useful shell utilities";

      bat = { };
      btop = { };
      d2 = { };
      direnv = { };
      dua = { };
      duf = { };
      dust = { };
      eza.config.enableFishIntegration = shells.fish.enable;
      fastfetch = { };
      fd = { };
      fx = { };
      fzf = { };
      gh = { };
      jq = { };
      magic-wormhole = { };
      ripgrep = { };
      starship.config.enableFishIntegration = shells.fish.enable;
      unzip = { };
      zf = { };
      zoxide.config.enableFishIntegration = shells.fish.enable;
    };

    # TODO: Figure out why lib.mkForce is needed here, it's very strange
    nixos.nether.shells = lib.mkForce { aliases.mkdir = "mkdir -p"; };
  }
)
