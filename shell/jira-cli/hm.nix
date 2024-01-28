{ config, pkgs, ... }:

{
  home.packages = [ pkgs.jira-cli-go ];
  sops.secrets.jira_api_token = {};
  programs.fish.interactiveShellInit = "set -gx JIRA_API_TOKEN $(cat ${config.sops.secrets.jira_api_token.path})";
}
