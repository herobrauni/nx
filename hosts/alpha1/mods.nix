{ lib, inputs, config, ... }: {
  # force disable tailscale
  # services.tailscale.enable = lib.mkForce false;
  sops.secrets.tskey-auth-k3s = { };
  services.tailscale.authKeyFile = "/run/secrets/tskey-auth-bf";
  # imports = [ ../../modules/k3s-agent.nix ];
}
