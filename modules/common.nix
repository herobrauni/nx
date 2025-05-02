{ config, lib, pkgs, ... }: {
  # This module contains common configuration that should be applied to all hosts

  # Import other common modules
  imports = [
    # Import the sops module for secret management
    ./sops.nix
  ];

  # Basic system configuration
  time = {
    # Set timezone to Europe/Berlin based on your current time
    timeZone = "Europe/Berlin";
  };

  # Locale settings
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" "de_DE.UTF-8/UTF-8" ];
  };

  # Console settings
  console = { keyMap = "us"; };

  # Common system packages that should be available on all hosts
  environment.systemPackages = with pkgs; [
    # Basic utilities
    wget
    nano
    btop
    htop
    fio
    iperf
    geekbench
    geekbench_4
    geekbench_5
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

  # System maintenance
  nix = {
    # Automatic garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # Optimize store
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };

    # Enable flakes
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
  };
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Enable automatic updates for security
  system.autoUpgrade = {
    enable = false; # Set to true if you want automatic updates
    allowReboot = false;
    dates = "04:00";
    randomizedDelaySec = "90min";
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    extraSetFlags = [ "--ssh" ];
    extraUpFlags = [ "--ssh" "--reset" ];
  };
}
