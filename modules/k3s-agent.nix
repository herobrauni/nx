{ lib, inputs, outputs, pkgs, config, hostIP, ... }: {
  sops.secrets.k3s-token = { };
  sops.secrets.vpn-auth-file = { };
  boot.kernelModules = [ "nbd" "rbd" "br_netfilter" ];
  services.k3s = {
    enable = true;
    tokenFile = "/run/secrets/k3s-token";
    role = "agent";
    serverAddr = "https://k.480p.com:6443";
    extraFlags = toString [
      "--vpn-auth-file=/run/secrets/vpn-auth-file"
      "--flannel-iface=tailscale0"
      "--node-external-ip=${hostIP config}"
    ];
    package = let
      patchedUtilLinux = pkgs.util-linuxMinimal.overrideAttrs (prev: {
        patches = (prev.patches or [ ]) ++ [ ./fix-mount-regression.patch ];
      });
      k3sWithPatchedUtilLinux =
        pkgs.k3s.override { util-linux = patchedUtilLinux; };
    in k3sWithPatchedUtilLinux.overrideAttrs (oldAttrs: {
      installPhase =
        lib.replaceStrings [ (lib.makeBinPath (oldAttrs.k3sRuntimeDeps)) ]
        [ (lib.makeBinPath (oldAttrs.k3sRuntimeDeps ++ [ pkgs.tailscale ])) ]
        oldAttrs.installPhase;
    });
  };
}
