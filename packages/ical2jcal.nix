{
  buildPythonApplication,
  icalendar,
  rich,
  typer,
  hatchling,
  uv-dynamic-versioning,
  fetchPypi,
}:

buildPythonApplication rec {
  pname = "ical2jcal";
  version = "1.0.6";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-yMJxCGZe0ylIZcBtNxzvCrfvEYJB/j4u3xXG61VaP+A=";
  };

  dependencies = [
    icalendar
    rich
    typer
  ];

  build-system = [
    hatchling
    uv-dynamic-versioning
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "typer-slim" "typer"
  '';

  doCheck = false;
}
