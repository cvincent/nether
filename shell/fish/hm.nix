{ config, pkgs, ... }:

{
  imports = [ ../essentials ];

  programs.fish = {
    enable = true;

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
      lfhh = "mpv --no-resume-playback --force-window=immediate 'https://www.youtube.com/watch?v=jfKfPfyJRdk'";
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
        if sudo nixos-rebuild switch --flake ~/dotfiles
          notify-send -i dialog-information -t 5000 -e 'NixOS Rebuild Succeeded'
        else
          notify-send -i dialog-error -t 5000 -e 'NixOS Rebuild Failed'
        end
        aplay ~/dotfiles/misc/notification.wav 2> /dev/null
      '';

      nxhm = ''
        if home-manager switch --flake ~/dotfiles
          systemctl --user start sops-nix
          notify-send -i dialog-information -t 5000 -e 'Home Manager Rebuild Succeeded'
        else
          notify-send -i dialog-error -t 5000 -e 'Home Manager Rebuild Failed'
        end
        aplay ~/dotfiles/misc/notification.wav 2> /dev/null
      '';

      m = ''
        mpv --force-window=immediate --volume=50 $argv & disown
      '';
    };
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };
}
