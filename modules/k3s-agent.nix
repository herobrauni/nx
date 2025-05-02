{ lib, inputs, outputs, pkgs, config, hostIP, ... }: {

  sops.secrets.k3s-token = { };
  sops.secrets.tskey-auth-k3s = { };
  boot.kernelModules = [ "nbd" "rbd" "ceph" ];
  services.k3s = {
    enable = true;
    tokenFile = "/run/secrets/k3s-token";
    role = "agent";
    serverAddr = "https://k.480p.com:6443";
    extraFlags = ''
      --vpn-auth=name=tailscale,joinKey=$''${builtins.readFile /run/secrets/tskey-auth-k3s}
      --flannel-iface=tailscale0
      --node-external-ip=$''${hostIP config}
      --resolv-conf=/etc/rancher/k3s/resolv.conf
    '';
    package = pkgs.k3s.overrideAttrs (oldAttrs: {
      installPhase =
        lib.replaceStrings [ (lib.makeBinPath (oldAttrs.k3sRuntimeDeps)) ]
        [ (lib.makeBinPath (oldAttrs.k3sRuntimeDeps ++ [ pkgs.tailscale ])) ]
        oldAttrs.installPhase;
    });
  };
}
