{ name, mkSoftware, ... }:
mkSoftware name (
  {
    lib,
    nether,
    fish,
    ...
  }:
  {
    nixos.nether.backups.paths."${nether.homeDirectory}/.local/share/fish/fish_history" = { };

    hm =
      let
        inherit (nether) dotfilesDirectory;
      in
      {
        stylix.targets.fish.enable = false;

        # TODO: Extract a lot of this so it can be more portable between shells
        programs.fish = {
          inherit (fish) enable package;

          interactiveShellInit = ''
            bind \cH backward-kill-word
          '';

          shellAliases = nether.shells.aliases;

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

            # TODO: This should just be a bash script so we can use it from any
            # shell.
            nxrb = ''
              git -C ${dotfilesDirectory} add -AN
              if sudo nixos-rebuild switch --flake ${dotfilesDirectory} --fast
                notify-send -i dialog-information -t 5000 -e 'NixOS Rebuild Succeeded'
              else
                notify-send -i dialog-error -t 5000 -e 'NixOS Rebuild Failed'
              end
              aplay ${dotfilesDirectory}/resources/notification.wav 2> /dev/null
            '';
          };
        };
      };
  }
)
