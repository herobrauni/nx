{
  config,
  lib,
  pkgs,
  ...
}:
{
  systemd.tmpfiles.rules = [ "d /opt/uptime-kuma 0770 root root -" ];
  virtualisation = {
    oci-containers.containers = {
      uptime-kuma = {
        image = "louislam/uptime-kuma:beta";
        extraOptions = [ "--pull=always" ];
        ports = [ "127.0.0.1:3001:3001" ];
        volumes = [ "uptime-kuma:/app/data" ];
        capabilities = {
          "NET_RAW" = true;
        };
      };
    };
  };
  sops.secrets.cloudflared-env = { };
  services.cloudflared.enable = true;
  services.cloudflared.tunnels."c18bf297-0da3-4daf-bdcf-0920ccdf77a3" = {
    credentialsFile = "/run/secrets/cloudflared-env";
    default = "http_status:404";
    ingress = {
      "kuma.brauni.dev" = "http://localhost:3001";
    };
  };
}
