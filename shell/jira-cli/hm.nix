{ config, pkgs, ... }:

{
  home.packages = [ pkgs.jira-cli-go ];
  sops.secrets.jira_auth_token = { };
  programs.fish.interactiveShellInit = "set -gx JIRA_AUTH_TOKEN $(cat ${config.sops.secrets.jira_auth_token.path})";
}
