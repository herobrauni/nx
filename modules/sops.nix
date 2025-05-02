{ config, lib, pkgs, ... }:

{
  # This module sets up sops-nix for secret management

  # Enable SSH key-based decryption
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # Generate a new key if it doesn't exist
  sops.age.generateKey = true;

  # Store the key in a persistent location
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  # Set the default sops file for all secrets
  sops.defaultSopsFile = ../secrets/secrets.sops.yaml;

  # Define example secrets - uncomment and adjust as needed
  # sops.secrets.example-secret = {};
  # sops.secrets.database-password = {};
  # sops.secrets."services/nginx/basic-auth-password" = {};
  # sops.secrets."services/postgres/admin-password" = {};
  # sops.secrets."services/postgres/user-password" = {};

  # Ensure the directory exists
  system.activationScripts.sopsDirs = lib.stringAfter [ "var" ] ''
    mkdir -p /var/lib/sops-nix
    chmod 700 /var/lib/sops-nix
  '';
}
