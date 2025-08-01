{ name, ... }:
{
  lib,
  moduleWithSystem,
  helpers,
  ...
}:
{
  # TODO: Why isn't this under shells.nix?
  flake.nixosModules."${name}" = moduleWithSystem (
    { pkgs }:
    { config, ... }:
    {
      options.nether.tmux = (helpers.pkgOpt pkgs.tmux false "tmux - the terminal multiplexer") // {
        tmuxinator = helpers.pkgOpt pkgs.tmuxinator true "tmuxinator - repeatable tmux sessions";
      };

      config = lib.mkIf config.nether.tmux.enable {
        nether.shells.aliases = lib.mkIf config.nether.tmux.tmuxinator.enable {
          mux = "tmuxinator start --suppress-tmux-version-warning=SUPPRESS-TMUX-VERSION-WARNING";
        };
      };
    }
  );

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
      config = {
        programs.tmux = {
          inherit (osConfig.nether.tmux) enable;
          package = pkgInputs.nixpkgs-tmux.tmux;

          tmuxinator = { inherit (osConfig.nether.tmux.tmuxinator) enable; };
          plugins = [ tmux-safekill ];

          shell = osConfig.nether.shells.default.path;
          prefix = "C-f";
          escapeTime = 0;
          keyMode = "vi";
          reverseSplit = true;
          mouse = true;
          historyLimit = 50000;

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
