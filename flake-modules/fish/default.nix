{ name }:
{ ... }:
{
  flake.nixosModules."${name}" =
    { config, ... }:
    {
      nether.backups.paths."${config.nether.homeDirectory}/.local/share/fish/fish_history" = { };
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
        enable = osConfig.nether.shells.fish.enable;

        interactiveShellInit = ''
          bind \cH backward-kill-word
        '';

        shellAliases = {
          cd = "z";
          mkdir = "mkdir -p";
          ls = "exa";
          l = "eza -lh --group-directories-first";
          ll = "eza -lha --group-directories-first";
          lt = "eza --tree --group-directories-first";
          cat = "bat";
          grep = "rg";
          # Put this one in mpv config
          lfhh = "mpv --no-resume-playback --force-window=immediate --http-proxy='https://192.168.1.114:8888' 'https://www.youtube.com/watch?v=jfKfPfyJRdk'";
          mux = "tmuxinator start --suppress-tmux-version-warning=SUPPRESS-TMUX-VERSION-WARNING";
          nvs = "nvim -S Session.vim";
        };

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
          fish_prompt = builtins.readFile ./fish_prompt.fish;

          nxrb = ''
            if nixos-rebuild switch --flake ~/dotfiles --use-remote-sudo
              notify-send -i dialog-information -t 5000 -e 'NixOS Rebuild Succeeded'
            else
              notify-send -i dialog-error -t 5000 -e 'NixOS Rebuild Failed'
            end
            aplay ~/dotfiles/misc/notification.wav 2> /dev/null
          '';

          m = ''
            mpv --force-window=immediate --volume=50 $argv & disown
          '';
        };
      };
    };
}
