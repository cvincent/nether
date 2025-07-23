{ name }:
{
  lib,
  moduleWithSystem,
  inputs,
  ...
}:
{
  flake.nixosModules."${name}" =
    { config, ... }:
    {
      options.nether.jiraCLI.enable = lib.mkEnableOption "Jira CLI tool";

      config = lib.mkIf config.nether.jiraCLI.enable {
        nether.backups.paths."${config.nether.homeDirectory}/.config/.jira/.config.yml" = { };
      };
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
