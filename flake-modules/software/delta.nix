{ name, mkSoftware, ... }:
mkSoftware name (
  { delta, nether, ... }:
  {
    hm.programs.delta = {
      inherit (delta) enable package;
      enableJujutsuIntegration = true;

      options = {
        dark = nether.theme.isDark;
        syntax-theme = nether.theme.themeName;
      };
    };
  }
)
