{ name }:
{ lib, ... }:
{
  flake.nixosModules."${name}" =
    { config, ... }:
    {
      nether.backups.paths."${config.nether.homeDirectory}/.local/share/fish/fish_history" =
        lib.mkIf config.nether.shells.fish.enable
          { };
    };

  flake.homeModules."${name}" =
    { osConfig, ... }:
    {
      stylix.targets.fish.enable = false;

      # TODO: Extract a lot of this so it can be more portable between shells
      # Some things should be grouped with other modules, e.g. `m` belongs in
      # media.nix. And aliases for various utilities should be grouped with
      # those utilities.
      programs.fish = {
        inherit (osConfig.nether.shells.fish) enable package;

        interactiveShellInit = ''
          bind \cH backward-kill-word
        '';

        shellAliases = osConfig.nether.shells.aliases;

        functions = {
          fish_greeting = ''
            echo (
              set_color red; echo "";
              set_color yellow; echo "";
              set_color normal; echo LFG;
              set_color yellow; echo "";
              set_color red; echo ""; set_color normal
            )
          '';

          # NOTE: This is my old prompt. Right now this does nothing because we
          # use Starship. But I liked it, and I don't feel like deleting it.
          # Call me sentimental.
          # fish_prompt = builtins.readFile ./fish_prompt.fish;

          nxrb = ''
            if sudo nixos-rebuild switch --flake ~/dotfiles --fast
              notify-send -i dialog-information -t 5000 -e 'NixOS Rebuild Succeeded'
            else
              notify-send -i dialog-error -t 5000 -e 'NixOS Rebuild Failed'
            end
            aplay ~/dotfiles/resources/notification.wav 2> /dev/null
          '';
        };
      };
    };
}
