{ name, mkFeature, ... }:
mkFeature name (
  {
    nether,
    newMail,
    inputs,
    ...
  }:
  {
    protonmail = {
      peroxide = {
        config.service = {
          certPem = inputs.private-nethers.mail.peroxide.certPem;
          keyPem = inputs.private-nethers.mail.peroxide.keyPem;
        };
      };
    };
  }
)
