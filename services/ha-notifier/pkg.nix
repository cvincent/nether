{ pkgs, fetchFromGitHub, ... }:

pkgs.python3Packages.buildPythonPackage rec {
  pname = "home-assistant-desktop-receiver";
  version = "0.1";
  format = "setuptools";

  propagatedBuildInputs = [ pkgs.python3Packages.dbus-python ];

  src = fetchFromGitHub {
    owner = "arsenicks";
    repo = "home-assistant-desktop-receiver";
    rev = "master";
    sha256 = "sha256-OPAg1LJe0X/v6SccjzqWLim+uzqYiO8u+iSeCcvMnH0=";
  };
}
