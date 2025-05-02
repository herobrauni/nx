{ lib, inputs, config, ... }: {
  imports = [ ../../modules/k3s-agent.nix ];
  sops.secrets.tskey-auth-k3s = { };
  services.tailscale.authKeyFile = "/run/secrets/tskey-auth-k3s";
  # force disable tailscale
  # services.tailscale.enable = lib.mkForce false;
}
