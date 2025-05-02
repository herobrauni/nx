{ lib, inputs, config, ... }: {
  # force disable tailscale
  # services.tailscale.enable = lib.mkForce false;
  sops.secrets.tskey-auth-bf = { };
  services.tailscale.authKeyFile = "/run/secrets/tskey-auth-bf";
  imports = [
    (inputs.nixpkgs.outPath + "/nixos/modules/profiles/minimal.nix")
    (inputs.nixpkgs.outPath + "/nixos/modules/profiles/headless.nix")
    # (inputs.nixpkgs.outPath + "/nixos/modules/profiles/perlless.nix")
  ];
}
