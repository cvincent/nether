{ name }:
{ lib, moduleWithSystem, ... }:
{
  flake.nixosModules."${name}" = {
    options.nether.tmux.enable = lib.mkEnableOption "tmux - the terminal multiplexer";
  };

  flake.homeModules."${name}" = moduleWithSystem (
    { pkgs, pkgInputs }:
    { osConfig, ... }:
    let
      tmux-safekill = pkgs.tmuxPlugins.mkTmuxPlugin {
        pluginName = "safekill";
        version = "master";
        src = pkgs.fetchFromGitHub {
          owner = "cvincent";
          repo = "tmux-safekill";
          rev = "master";
          sha256 = "sha256-xAf9IZ7OLzsv7ywvM5csFhkoMdRGOfWDrwc0yrXu1hw=";
        };
      };
    in
    {
      config = lib.mkIf osConfig.nether.tmux.enable {
        home.packages = [ pkgs.tmuxinator ];

        programs.tmux = {
          enable = true;
          # TODO: Make sure this latest ersion has our scroll-middle/top/bottom
          # support! We previously used an overlay to get it.
          package = pkgInputs.nixpkgs-tmux.tmux;

          shell = "~/.nix-profile/bin/fish";
          prefix = "C-f";
          escapeTime = 0;
          keyMode = "vi";
          reverseSplit = true;
          mouse = true;
          historyLimit = 50000;

          plugins = [
            tmux-safekill
          ];

          extraConfig = ''
            # Scroll relative to cursor like Vim zz, zt, and zb
            bind-key -T copy-mode-vi z switch-client -T my-scroll-keys
            bind-key -T my-scroll-keys z send -X scroll-middle
            bind-key -T my-scroll-keys t send -X scroll-top
            bind-key -T my-scroll-keys b send -X scroll-bottom

            # Clipboard setup
            set -s copy-command 'wl-copy'
            bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel 'wl-copy'
            # v like Vim visual mode
            bind-key -T copy-mode-vi v send -X begin-selection

            # Shift arrow to switch windows
            bind -n S-Left  previous-window
            bind -n S-Right next-window

            # Ctrl arrow to move windows
            # bind -n C-Left  swap-window -d -t -1
            # bind -n C-Right swap-window -d -t +1

            # Navigate panes like Vim
            # We can't just C-h because that's ctrl-backspace...
            bind-key h select-pane -L
            bind-key l select-pane -R
            bind-key j select-pane -D
            bind-key k select-pane -U

            # Tabs at the top
            set -g status-position top
          '';
        };
      };
    }
  );
}
