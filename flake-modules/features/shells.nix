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

      binds = lib.mkOption {
        type = with lib.types; attrsOf str;
        default = { };
      };

      contextualCompletionKey = lib.mkOption {
        type = lib.types.str;
        default = "ctrl-j";
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
      # NOTE: Do we have enableFishIntegration for fzf? Would be nice to be able
      # to ctrl-t to fuzzy find past ssh connections, or kill -9 ctrl-t, etc...
      fzf = { };
      gh = { };
      jless = { };
      jq = { };
      magic-wormhole = { };
      presenterm = { };
      ripgrep = { };
      starship.config.enableFishIntegration = shells.fish.enable;
      unzip = { };
      zf = { };
      zoxide.config.enableFishIntegration = shells.fish.enable;
    };

    nixos.nether.shells.aliases.mkdir = "mkdir -p";
  }
)
