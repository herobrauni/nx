{ config, lib, pkgs, ... }: {
  virtualisation = {
    podman = { enable = true; };
    oci-containers.containers = {
      uptime-kuma = {
        image = "louislam/uptime-kuma:beta";
        extraOptions = [ "--pull=always" ];
        ports = [ "127.0.0.1:3001:3001" ];
        volumes = [ "/opt/uptime-kuma:/app/data" ];
      };
    };
  };
}
