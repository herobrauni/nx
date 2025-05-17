{ lib, inputs, outputs, pkgs, config, hostIP, ... }: {
  imports = [ ./k3s.nix ];
  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = toString [
      "--vpn-auth-file=/run/secrets/vpn-auth-file"
      "--flannel-iface=tailscale0"
      "--node-external-ip=${hostIP config}"
      "--tls-san=k.480p.com"
      "--secrets-encryption"
      "--disable traefik"
      "--disable local-storage"
      "--disable metrics-server"
      "--etcd-expose-metrics"
      "--embedded-registry"
      "--write-kubeconfig-mode 0644"
      "--disable coredns"
      # "--disable-network-policy"
      "--resolv-conf=/run/systemd/resolve/resolv.conf"
    ];
  };
}
