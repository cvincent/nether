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
      tmux-easymotion = pkgs.tmuxPlugins.mkTmuxPlugin rec {
        pluginName = "easymotion";
        version = "v1.2.2";
        src = pkgs.fetchFromGitHub {
          owner = "ddzero2c";
          repo = "tmux-easymotion";
          rev = version;
          sha256 = "sha256-3Yn8/W13Zr7HzUdRlsjBS+/WtoG0JsyTEWKePhny9bI=";
        };

        buildInputs = [ pkgs.python3 ];
        postInstall = "patchShebangs easymotion.py";
      };

      tmux-safekill = pkgs.tmuxPlugins.mkTmuxPlugin rec {
        pluginName = "safekill";
        version = "master";
        src = pkgs.fetchFromGitHub {
          owner = "cvincent";
          repo = "tmux-safekill";
          rev = version;
          sha256 = "sha256-xAf9IZ7OLzsv7ywvM5csFhkoMdRGOfWDrwc0yrXu1hw=";
        };
      };

      tmux-smooth-scroll = pkgs.tmuxPlugins.mkTmuxPlugin rec {
        pluginName = "smooth-scroll";
        rtpFilePath = "smooth-scroll.tmux";
        version = "e7f0b489d28f85e5a4e90d1aae335ac390159657";
        src = pkgs.fetchFromGitHub {
          owner = "azorng";
          repo = "tmux-smooth-scroll";
          rev = version;
          sha256 = "sha256-2oDwVMuuu6gnaKqaqUjTdJ4nMuvOIt04W5SipxHBxQY=";
        };

        buildInputs = [ pkgs.perl ];
        postInstall = "patchShebangs src/animator.pl";

        extraConfig = ''
          # Lower = faster
          set -g @smooth-scroll-speed 25
          set -g @smooth-scroll-easing linear
          set -g @smooth-scroll-exit-copy-mode-at-bottom false
        '';
      };
    in
    {
      config = {
        programs.tmux = {
          inherit (osConfig.nether.tmux) enable package;

          tmuxinator = { inherit (osConfig.nether.tmux.tmuxinator) enable; };

          plugins = [
            {
              plugin = tmux-easymotion;
              extraConfig = ''
                # Not sure which I prefer!
                # TODO: Would be nice to match the style of tmux-fingers, which
                # I prefer, but it's not configurable.
                set -g @easymotion-s j
                set -g @easymotion-s2 C-j
                set -g @easymotion-hints 'asdfghjkl;'
              '';
            }

            {
              plugin = pkgInputs.nixpkgs-tmux-fingers.tmuxPlugins.fingers;
              extraConfig = ''
                set -g @fingers-enable-bindings 0
                set -g @fingers-keyboard-layout qwerty-homerow

                # Match Nix hashes, of course
                set -g @fingers-pattern-0 'sha256-.{43}='

                bind-key space run -b "#{@fingers-cli} start #{pane_id}"
                # Just to see the difference from tmux-easymotion. This one is
                # limited to the focused pane and wrapped text messes it up. I
                # might like it better though if that were fixed.
                # bind-key C-j run -b "#{@fingers-cli} start #{pane_id} --mode jump"
              '';
            }

            tmux-safekill
            tmux-smooth-scroll
          ];

          shell = osConfig.nether.shells.default.path;
          prefix = "C-f";
          escapeTime = 0;
          keyMode = "vi";
          reverseSplit = true;
          mouse = true;
          historyLimit = 50000;
          baseIndex = 1;

          extraConfig = ''
            # Reload config
            bind r source-file "~/.config/tmux/tmux.conf"

            bind-key C-f copy-mode
            unbind-key [

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
            bind-key -T copy-mode-vi C-v send -X rectangle-toggle

            # Shift arrow to switch windows
            bind -n S-Left  previous-window
            bind -n S-Right next-window

            # Alt arrow to move windows
            bind -n M-Left  swap-window -d -t -1
            bind -n M-Right swap-window -d -t +1

            # Alt-hjkl panes like Vim
            bind -n M-h select-pane -L
            bind -n M-j select-pane -D
            bind -n M-k select-pane -U
            bind -n M-l select-pane -R

            set -g status-left "#S "
            set -g status-right ""

            # Status / window tabs at the top
            set -g status-position top

            # Renumber windows when created/killed
            set -g renumber-windows on
          '';
        };
      };
    }
  );
}
