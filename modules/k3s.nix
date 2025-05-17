{ lib, inputs, outputs, pkgs, config, hostIP, ... }: {
  sops.secrets.k3s-token = { };
  sops.secrets.vpn-auth-file = { };
  boot.kernelModules = [ "nbd" "rbd" "br_netfilter" "ceph" ];
  services.k3s = {
    gracefulNodeShutdown.enable = true;
    tokenFile = "/run/secrets/k3s-token";
    serverAddr = "https://k.480p.com:6443";
  };
  systemd.services.k3s.path = [ pkgs.tailscale ];
  services.tailscale.enable = lib.mkForce false;
}
