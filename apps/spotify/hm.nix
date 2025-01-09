{
  nixpkgs-unstable,
  ...
}:

{
  programs.ncspot = {
    enable = true;
    package = nixpkgs-unstable.ncspot;
    settings = {
      keybindings = {
        "Esc" = "back";
        "Backspace" = "noop";
        "q" = "noop";
      };
    };
  };
}
