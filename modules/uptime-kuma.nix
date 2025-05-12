{ config, lib, pkgs, ... }: {
  systemd.tmpfiles.rules = [ "d /opt/uptime-kuma 0770 root root -" ];
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings = {
        dns_enabled = true;
        ipv6_enabled = true;
      };
    };
    oci-containers.containers = {
      uptime-kuma = {
        image = "louislam/uptime-kuma:beta";
        extraOptions = [ "--pull=always" ];
        ports = [ "127.0.0.1:3001:3001" ];
        volumes = [ "uptime-kuma:/app/data" ];
        capabilities = { "NET_RAW" = true; };
      };
    };
  };
  sops.secrets.cloudflared-env = { };
  services.cloudflared.enable = true;
  services.cloudflared.tunnels."ca628217-fbdd-4414-9665-5cc7b0789bde" = {
    credentialsFile = "/run/secrets/cloudflared-env";
    default = "http_status:404";
    ingress = { "kuma.brauni.dev" = "http://localhost:3001"; };
  };
}
