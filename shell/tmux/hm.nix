{ pkgs, ... }:

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
  nixpkgs.overlays = [
    (self: super: {
      # Tmux seems to rarely tag new versions. We want the latest for proper
      # scroll-middle/top/bottom support.
      tmux-latest = super.tmux.overrideAttrs (old: {
        src = super.fetchFromGitHub {
          owner = "tmux";
          repo = "tmux";
          rev = "a5545dbc9f576d8f324333942eda562f3b80beeb";
          sha256 = "sha256-yut4cux2OXc7OXnCogyVeJnGGWWh/Y9/LWTyySW5fIk=";
        };

        # NOTE: Existing patch fails the build, says it was already applied. It's
        # probably true!
        patches = [ ];
      });
    })
  ];

  home.packages = with pkgs; [
    tmuxinator
  ];

  programs.tmux = {
    enable = true;
    package = pkgs.tmux-latest;

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
}
