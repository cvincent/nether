{
  buildLua,
  fetchFromGitHub,
  gitUpdater,
}:
buildLua (finalAttrs: {
  pname = "delete-current-file";
  version = "main";
  scriptPath = "delete_current_file.lua";

  src = fetchFromGitHub {
    owner = "stax76";
    repo = "mpv-scripts";
    rev = "main";
    hash = "sha256-qEw0T/37n8aQ2WU4YsxCjJGdoa2Ft3Vg6y6jGWAnJDM=";
  };

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };
  # TODO: Add trash-cli as a dependency
})
