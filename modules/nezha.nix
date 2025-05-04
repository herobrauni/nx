{ config, lib, pkgs, ... }:
{
  sops.secrets.nezha-client-secret = { };

  services.nezha-agent = {
    enable = true;
    clientSecretFile = "/run/secrets/nezha-client-secret";
  };
  settings = {
    server = "http://netcup1.brill-bebop.ts.net:8008";
  }
}
