{ name }:
{
  lib,
  moduleWithSystem,
  helpers,
  ...
}:
{
  imports = [ (import ../software/fish { name = "fish"; }) ];

  flake.nixosModules."${name}" = moduleWithSystem (
    { pkgs }:
    { config, options, ... }:
    let
      inherit (config.nether) shells;
    in
    {
      options = {
        nether.shells = {
          fish = helpers.pkgOpt pkgs.fish (config.nether.shells.default == "fish") "Fish shell";

          extra = {
            enable = lib.mkEnableOption "Various useful shell utilities";

            bat = helpers.delegateToSoftware options "bat" true;
            btop = helpers.delegateToSoftware options "btop" true;
            direnv = helpers.delegateToSoftware options "direnv" true;
            eza = helpers.delegateToSoftware options "eza" true;
            fzf = helpers.delegateToSoftware options "fzf" true;
            jq = helpers.delegateToSoftware options "jq" true;
            ripgrep = helpers.delegateToSoftware options "ripgrep" true;
            starship = helpers.delegateToSoftware options "starship" true;
            zoxide = helpers.delegateToSoftware options "zoxide" true;

            d2 = helpers.pkgOpt pkgs.dua true "d2 - text-to-diagram tool";
            dua = helpers.pkgOpt pkgs.dua true "dua - disk usage like du, but simpler";
            duf = helpers.pkgOpt pkgs.duf true "duf - per-disk usage like df, but nicely formatted";
            dust = helpers.pkgOpt pkgs.dust true "dust - disk usage like du, but more visual";
            fastfetch = helpers.pkgOpt pkgs.fastfetch true "fastfetch - system information fetcher";
            fd = helpers.pkgOpt pkgs.fd true "fd - a simpler alternative to find";
            fx = helpers.pkgOpt pkgs.fx true "fx - interactive terminal JSON viewer";
            gh = helpers.pkgOpt pkgs.gh true "gh - GitHub CLI";
            unzip = helpers.pkgOpt pkgs.unzip true "unzip - easy zip extraction";

            magicWormhole =
              helpers.pkgOpt pkgs.magic-wormhole true
                "wormhole - easy, secure file transfer over the Internet";

            zf =
              helpers.pkgOpt pkgs.zf true
                "zf - a command-line fuzzy finder that prioritizes base filename matches";
          };

          default = {
            which = lib.mkOption {
              type = lib.types.enum [
                null
                "fish"
              ];
              default = null;
            };

            package = lib.mkOption { type = lib.types.package; };
            path = lib.mkOption { type = lib.types.str; };
          };
        };
      };

      config.nether = {
        shells.default = lib.mkIf (shells.default.which != null) {
          package = lib.mkForce shells."${shells.default.which}".package;
          path = lib.mkForce "${shells.default.package}/bin/${shells.default.which}";
        };

        software = lib.mkIf shells.extra.enable {
          bat = {
            inherit (shells.extra.bat) enable package;
            enableFishIntegration = shells.fish.enable;
          };

          btop = { inherit (shells.extra.btop) enable package; };
          direnv = { inherit (shells.extra.direnv) enable package; };

          eza = {
            inherit (shells.extra.eza) enable package;
            enableFishIntegration = shells.fish.enable;
          };

          fzf = { inherit (shells.extra.fzf) enable package; };
          jq = { inherit (shells.extra.jq) enable package; };
          ripgrep = { inherit (shells.extra.ripgrep) enable package; };

          starship = {
            inherit (shells.extra.starship) enable package;
            enableFishIntegration = shells.fish.enable;
          };

          zoxide = {
            inherit (shells.extra.zoxide) enable package;
            enableFishIntegration = shells.fish.enable;
          };
        };
      };
    }
  );

  flake.homeModules."${name}" =
    { osConfig, ... }:
    let
      inherit (osConfig.nether) shells;
      inherit (shells) extra;
    in
    {
      config = lib.mkIf extra.enable {
        home.packages =
          [ ]
          ++ helpers.pkgOptPkg extra.d2
          ++ helpers.pkgOptPkg extra.dua
          ++ helpers.pkgOptPkg extra.duf
          ++ helpers.pkgOptPkg extra.dust
          ++ helpers.pkgOptPkg extra.fx
          ++ helpers.pkgOptPkg extra.magicWormhole
          ++ helpers.pkgOptPkg extra.unzip
          ++ helpers.pkgOptPkg extra.zf;

        programs = {
          fastfetch = { inherit (extra.fastfetch) enable package; };
          fd = { inherit (extra.fd) enable package; };
          gh = { inherit (extra.gh) enable package; };
        };
      };
    };
}
