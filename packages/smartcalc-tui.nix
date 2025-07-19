{ lib, rustPlatform, ... }:

rustPlatform.buildRustPackage {
  pname = "smartcalc-tui";
  version = "1.0.7";

  src = fetchTarball {
    url = "https://github.com/superhawk610/smartcalc-tui/archive/refs/tags/v1.0.7.tar.gz";
    sha256 = "sha256:1dv24rsj87avpbrmab0hy3v729fdqh1cfbvl1xsjmfn8y35z4m5m";
  };

  cargoHash = "sha256-0AWsJccfzkUkpB6imibN6iUNDEx3vrX9kEgD98nXURw=";

  buildNoDefaultFeatures = true;

  meta = with lib; {
    description = "Terminal UI for erhanbaris/smartcalc, a new way to do calculations on-the-fly.";
    homepage = "https://github.com/superhawk610/smartcalc-tui";
    license = licenses.mit;
    maintainers = [ ];
  };
}
