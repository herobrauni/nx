{
  lib,
  inputs,
  config,
  ...
}:
{
  # force disable tailscale
  # services.tailscale.enable = lib.mkForce false;
  sops.secrets.tskey-auth-bf = { };
  services.tailscale.authKeyFile = "/run/secrets/tskey-auth-bf";
  # imports = [ ../../modules/k3s-agent.nix ];
  imports = [
    ../../modules/nezha.nix
    ./grafana-stack.nix
  ];
}
