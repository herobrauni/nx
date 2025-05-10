{ config, lib, pkgs, ... }: {
  sops.secrets.globalping-env = { };

  virtualisation = {
    podman = { enable = true; };
    oci-containers.containers = {
      globalping-probe = {
        image = "globalping/globalping-probe:latest";
        privileged = true;
        capabilities = { "NET_RAW" = true; };
        extraOptions = [ "--network=host" "--pull=always" ];
        environmentFiles = [ /run/secrets/globalping-env ];
      };
    };
  };
}
