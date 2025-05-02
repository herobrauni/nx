# Garnix Binary Cache Implementation Plan

This document outlines the steps to implement Garnix binary cache for your NixOS VPS servers to reduce build times.

## Overview

Garnix provides both CI/CD and binary cache services for Nix projects. By configuring your NixOS systems to use Garnix as a binary cache, you can significantly reduce build times on your low-spec VPS servers.

## Prerequisites

- A GitHub repository connected to Garnix
- Garnix CLI already set up in your repository

## Implementation Steps

### 1. Configure Nix Settings in common.nix

Modify your `modules/common.nix` file to add Garnix as a binary cache:

```nix
{ config, lib, pkgs, ... }: {
  # Existing configuration...

  # Nix settings
  nix = {
    # Existing nix configuration...
    
    # Add these settings for Garnix
    settings = {
      # Keep your existing settings
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      
      # Add Garnix as a substituter
      substituters = [
        "https://cache.garnix.io"
        "https://cache.nixos.org"  # Keep the default cache
      ];
      
      # Add Garnix's public key to trusted keys
      trusted-public-keys = [
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJOqMjk="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="  # Default NixOS key
      ];
      
      # Ensure binary caches are used
      builders-use-substitutes = true;
      
      # Optional: Set a higher priority for Garnix cache
      # This makes Nix check Garnix before the default cache
      extra-substituters = [
        "https://cache.garnix.io"
      ];
    };
    
    # Existing nix configuration...
  };
  
  # Rest of your configuration...
}
```

### 2. Configure Extra Nix Options

To ensure your VPS servers prefer using the binary cache over building packages themselves, add these additional settings:

```nix
{ config, lib, pkgs, ... }: {
  # Existing configuration...

  # Additional Nix settings to prefer binary cache
  nix = {
    # Existing nix configuration...
    
    # Add these settings
    extraOptions = ''
      # Prefer binary cache over building
      fallback = true
      
      # Increase log verbosity for cache-related messages
      # Useful for debugging cache issues
      # Remove or set to 0 once everything is working
      narinfo-cache-negative-ttl = 0
    '';
  };
}
```

### 3. Deploy the Configuration

After updating the configuration, deploy it to your VPS servers using deploy-rs:

```bash
nix run github:serokell/deploy-rs .
```

### 4. Verify Cache Usage

To verify that your servers are using the Garnix cache, you can check the Nix logs during a build. Look for messages indicating downloads from `cache.garnix.io`.

You can also run this command on your VPS to see if the cache is configured correctly:

```bash
nix show-config | grep substituters
```

### 5. Monitor and Optimize

- Monitor build times to see the improvement
- Check the Garnix dashboard to ensure your packages are being built and cached
- Consider adding a GitHub workflow to pre-build packages and push them to the cache

## Troubleshooting

If you're not seeing improved build times:

1. Verify the cache is configured correctly:
   ```bash
   nix show-config | grep substituters
   nix show-config | grep trusted-public-keys
   ```

2. Check if your packages are available in the cache:
   ```bash
   nix path-info --store https://cache.garnix.io <package-path>
   ```

3. Increase log verbosity temporarily:
   ```nix
   nix.extraOptions = ''
     narinfo-cache-negative-ttl = 0
     verbose = 1
   '';
   ```

## Alternative: Using Cachix

If Garnix doesn't meet your needs, Cachix is another popular option:

```nix
nix.settings = {
  substituters = [
    "https://your-cache-name.cachix.org"
    "https://cache.nixos.org"
  ];
  trusted-public-keys = [
    "your-cache-name.cachix.org-1:your-public-key-here="
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];
};
```

## Alternative: Using Attic (Self-hosted)

For a self-hosted solution, Attic provides more control:

```nix
nix.settings = {
  substituters = [
    "https://your-attic-server.example.com/your-cache"
    "https://cache.nixos.org"
  ];
  trusted-public-keys = [
    "your-attic-server:your-public-key-here="
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];
};