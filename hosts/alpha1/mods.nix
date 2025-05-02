{ lib, inputs, config, ... }: {
  # force disable tailscale
  # services.tailscale.enable = lib.mkForce false;
  sops.secrets.tskey-auth-bf = { };
  services.tailscale.authKeyFile = "/run/secrets/tskey-auth-bf";
}
