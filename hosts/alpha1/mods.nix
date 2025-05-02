{ lib, inputs, config, ... }: {
  # force disable tailscale
  # services.tailscale.enable = lib.mkForce false;
  sops.secrets.tskey-auth-bf = { };
  services.tailscale.authKeyFile = "/run/secrets/tskey-auth-bf";
  imports = [
    (nixpkgs.outPath + "/nixos/modules/profiles/minimal.nix")
    (nixpkgs.outPath + "/nixos/modules/profiles/headless.nix")
    (nixpkgs.outPath + "/nixos/modules/profiles/perlless.nix")
  ];
}
