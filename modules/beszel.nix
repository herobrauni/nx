{ config, lib, pkgs, ... }: {
  sops.secrets.beszel-env = { };

  virtualisation = {
    podman = { enable = true; };
    oci-containers.containers = {
      beszel-agent = {
        image = "henrygd/beszel-agent:latest";
        # privileged = true;
        # capabilities = { "NET_RAW" = true; };
        extraOptions = [ "--network=host" "--pull=always" ];
        environmentFiles = [ /run/secrets/beszel-env ];
      };
    };
  };
}
