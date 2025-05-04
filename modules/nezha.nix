{ config, lib, pkgs, ... }:
{
  sops.secrets.nezha-client-secret = { };
  networking.domain = "brill-bebop.ts.net";

  services.nezha-agent = {
    enable = true;
    clientSecretFile = "/run/secrets/nezha-client-secret";
    genUuid = true;
    debug = false;
  settings = {
    server = "netcup1.brill-bebop.ts.net:8008";
  };
  };
}
