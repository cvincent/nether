{ name }:
{
  lib,
  moduleWithSystem,
  inputs,
  ...
}:
{
  flake.nixosModules."${name}" = {
    options.nether.jiraCLI.enable = lib.mkEnableOption "Jira CLI tool";
  };

  flake.homeModules."${name}" = moduleWithSystem (
    { pkgs }:
    { osConfig, ... }:
    {
      config = lib.mkIf osConfig.nether.jiraCLI.enable {
        home.packages = [ pkgs.jira-cli-go ];
        programs.fish.interactiveShellInit = ''set -gx JIRA_AUTH_TOKEN "${inputs.private-nethers.jiraAuthToken}"'';
      };
    }
  );
}
