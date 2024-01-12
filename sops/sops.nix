{ mySopsKey, ... }:

{
  sops.defaultSopsFile = ./secrets/secrets.yml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "${mySopsKey}";
}
