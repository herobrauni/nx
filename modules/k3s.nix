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
  # networking.firewall.enable = lib.mkForce false;
  services.k3s.package = pkgs.k3s.override {
    util-linux = pkgs.util-linuxMinimal.overrideAttrs (prev: {
      patches = (prev.patches or [ ]) ++ [ ./fix-mount-regression.patch ];
    });
  };
}
