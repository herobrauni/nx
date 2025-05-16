{ inputs, outputs, config, lib, pkgs, pkgs-unstable, machine, ... }: {
  # Use unstable packages for resilio
  nixpkgs.overlays = [ (final: prev: {
    mount = pkgs-stable.mount;
  }) ];
}