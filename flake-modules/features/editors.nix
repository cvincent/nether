{
  name,
  mkFeature,
  mkSoftwareChoice,
  ...
}:
mkFeature name (
  {
    editors,
    lib,
    pkgs,
    ...
  }:
  (mkSoftwareChoice
    {
      inherit name;
      namespace = "toplevel";
      thisConfig = editors;
    }
    {
      neovim = { };
    }
  )
  |> lib.recursiveUpdate {
    description = "Textual human-computer interfacing";

    formatters = {
      description = "We generally install LSPs in devShells, but there are a few we always want around";
      nixfmt-rfc-style = { };
      pgformatter = { };
      prettier.package = pkgs.nodePackages.prettier;
    };

    lsps = {
      description = "We generally install LSPs in devShells, but there are a few we always want around";
      lua-language-server = { };
      nixd = { };
      nil = { };
      tailwindcss-language-server = { };
      typescript-language-server.package = pkgs.nodePackages.typescript-language-server;
      vscode-langservers-extracted = { };
    };
  }
)
