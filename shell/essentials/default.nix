{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bat
    bottom
    eza
    fzf
    jq
    unzip
    magic-wormhole
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.ripgrep = {
    enable = true;
    arguments = [
      "--glob=!*.enc"
    ];
  };

  home.sessionVariables = {
    ERL_AFLAGS = "-kernel shell_history enabled";
    FZF_DEFAULT_OPTS = "--bind=ctrl-h:backward-kill-word";
  };
}
