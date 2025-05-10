{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  # This module contains common configuration that should be applied to all hosts

  # Import other common modules
  imports = [
    # Import the sops module for secret management
    ./sops.nix
    ./nezha.nix
    ./monitoring.nix
    ./globalping.nix
    (modulesPath + "/profiles/headless.nix")
    (modulesPath + "/profiles/minimal.nix")
  ];

  # Basic system configuration
  time = {
    # Set timezone to Europe/Berlin based on your current time
    timeZone = "Europe/Berlin";
  };

  # Locale settings
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "de_DE.UTF-8/UTF-8"
    ];
  };

  # Console settings
  console = {
    keyMap = "us";
  };
  services.resolved.enable = true;
  # Common system packages that should be available on all hosts
  environment.systemPackages = with pkgs; [
    # Basic utilities
    git
    wget
    nano
    btop
    gtop
    htop
    fio
    iperf
    ncdu
    # geekbench
    # geekbench_4
    # geekbench_5
  ];

  # SSH server configuration (common for all servers)
  services.openssh = {
    enable = true;
    settings = {
      # Disable password authentication for better security
      PasswordAuthentication = false;
      # Disable root login with password
      PermitRootLogin = "prohibit-password";
      # Use more secure key exchange algorithms
      KexAlgorithms = [
        "curve25519-sha256"
        "curve25519-sha256@libssh.org"
        "diffie-hellman-group16-sha512"
        "diffie-hellman-group18-sha512"
      ];
    };
    # Use a non-standard port for better security
    ports = [ 666 ];
  };
  networking.firewall = {
    # enable the firewall
    enable = true;

    # always allow traffic from your Tailscale network
    trustedInterfaces = [ "tailscale0" ];

    # allow the Tailscale UDP port through the firewall
    allowedUDPPorts = [
      config.services.tailscale.port
    ];

    # allow you to SSH in over the public internet
    allowedTCPPorts = [
      666
    ];
  };

  # System maintenance
  nix = {
    # Automatic garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 2d";
    };

    # Optimize store
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };

    # Enable flakes and configure binary cache
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;

      substituters = [
        "https://brauni.cachix.org"
        "https://cache.nixos.org" # Keep the default cache
      ];

      trusted-public-keys = [
        "brauni.cachix.org-1:AK1gTT3vQZQh2OqWS4rh+DjV9lOlqa834O5pssx2rUw="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" # Default NixOS key
      ];

      # Ensure binary caches are used
      builders-use-substitutes = true;
    };

    # Additional options to prefer binary cache
    extraOptions = ''
      # Prefer binary cache over building
      fallback = true
    '';
  };
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable automatic updates for security
  system.autoUpgrade = {
    enable = true;
    flake = "github:herobrauni/nx";
    flags = [
      "-L" # print build logs
    ];
    dates = "02:00";
    randomizedDelaySec = "95min";
    allowReboot = true;
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    extraSetFlags = [ "--ssh" ];
    extraUpFlags = [
      "--ssh"
      "--reset"
      "--hostname=${config.networking.hostName}"
    ];
  };

  # User brauni with SSH keys and passwordless sudo
  users.users.brauni = {
    isNormalUser = true;
    description = "brauni";
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBPFkI1tmXLQ5awKEqqoEUMbCalSqARtODdy8nQ18pKk"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIETmaz2oKUkpoSSeGKQefhFb+PUCEwY9Onh9+q1+hXXt"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAICvklcYlHcJVJzEAmkevC9eZ/rjCN7d1jhDHMBbVSmkqAAAABHNzaDo="
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIJUzimGYl+VtbaQVuGkVRwxRBMQEJDsmD5g+YeHx2s9bAAAABHNzaDo="
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINz7Y1oRX+SURSXOoNv5se/hrpi6VvLHK0T3zqz+q5kqAAAABHNzaDo="
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJmpZL3J2RqRK7ynIgowaZBKzI+EiuCGmwB6l0AxLk1v"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFfL/A140RdlJ1LQQR/lwtPwf0MAn5haqDdXGKWsW8sa"
    ];
  };

  # Passwordless sudo for wheel group
  security.sudo.wheelNeedsPassword = false;
}
