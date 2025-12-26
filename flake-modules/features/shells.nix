{
  name,
  mkFeature,
  mkSoftwareChoice,
  ...
}:
mkFeature name (
  { lib, shells, ... }:
  (mkSoftwareChoice
    {
      inherit name;
      namespace = "toplevel";
      thisConfig = shells;
    }
    {
      fish = { };
      zsh = { };
    }
  )
  |> lib.recursiveUpdate {
    description = "Shells and shell tools and commands";

    options = {
      aliases = lib.mkOption {
        type = with lib.types; attrsOf str;
        default = { };
      };
    };

    extra = {
      description = "Various useful shell utilities";

      bat = { };
      btop = { };
      d2 = { };
      direnv = { };
      dnsutils = { };
      dua = { };
      duf = { };
      dust = { };
      eza.config.enableFishIntegration = shells.fish.enable;
      fastfetch = { };
      fd = { };
      fx = { };
      fzf = { };
      gh = { };
      jless = { };
      jq = { };
      magic-wormhole = { };
      ripgrep = { };
      starship.config.enableFishIntegration = shells.fish.enable;
      unzip = { };
      zf = { };
      zoxide.config.enableFishIntegration = shells.fish.enable;
    };

    nixos.nether.shells.aliases.mkdir = "mkdir -p";
  }
)
