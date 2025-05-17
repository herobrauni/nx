{ lib, inputs, outputs, pkgs, config, hostIP, ... }: {
  imports = [ ./k3s.nix ];
  services.k3s = {
    enable = true;
    role = "agent";
    extraFlags = toString [
      "--vpn-auth-file=/run/secrets/vpn-auth-file"
      "--flannel-iface=tailscale0"
      "--node-external-ip=${hostIP config}"
      "--resolv-conf=/run/systemd/resolve/resolv.conf"
    ];
  };
}
