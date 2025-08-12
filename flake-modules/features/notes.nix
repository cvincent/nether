{ name, mkFeature, ... }:
mkFeature name (
  { nether, pkgInputs, ... }:
  {
    # TODO: There are HM options to declare your Obsidian vaults and settings
    # which we should migrate to
    toplevel.obsidian = {
      nixos = {
        nether.backups.paths."${nether.homeDirectory}/.config/obsidian".deleteMissing = true;
        nether.backups.paths."${nether.homeDirectory}/second-brain".deleteMissing = true;
      };
      hm.home.sessionVariables.OBSIDIAN_REST_API_KEY = pkgInputs.private-nethers.obsidianRestAPIKey;
    };
  }
)
