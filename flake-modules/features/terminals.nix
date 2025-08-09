{
  name,
  mkFeature,
  mkSoftwareChoice,
  ...
}:
mkFeature name (
  { terminals, ... }:
  (mkSoftwareChoice
    {
      inherit name;
      namespace = "toplevel";
      thisConfig = terminals;
    }
    {
      kitty = { };
    }
  )
)
