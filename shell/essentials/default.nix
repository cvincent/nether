{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ripgrep
    eza
    bat
    jq
    fzf
    unzip
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.sessionVariables = {
    ERL_AFLAGS = "-kernel shell_history enabled";
    FZF_DEFAULT_OPTS = "--bind=ctrl-h:backward-kill-word";
  };
}
