{
  description =
    "NixOS configuration for multiple servers (dynamic host discovery)";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nix doesn't need the full history, this should be the default ¯\_(ツ)_/¯
    nixpkgs-unstable.url =
      "git+https://github.com/NixOS/nixpkgs?shallow=1&ref=nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    deploy-rs.url = "github:serokell/deploy-rs";
    sops-nix.url = "github:Mic92/sops-nix";
    # Optional: make sops-nix use the same nixpkgs as we do
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    determinate.url =
      "https://flakehub.com/f/DeterminateSystems/determinate/0.1";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, nixpkgs-unstable, deploy-rs, ... }@inputs:
    let
      # Get all host directories from the hosts folder
      hostDirs = builtins.filter
        (name: (builtins.readDir ./hosts)."${name}" == "directory")
        (builtins.attrNames (builtins.readDir ./hosts));
      system = "x86_64-linux";

    in {
      # Dynamic host discovery for NixOS configurations
      # Calculate host IPs once to reuse in both nixosConfigurations and deploy
      hostIPs = builtins.listToAttrs (builtins.map (hostName: {
        name = hostName;
        value = let
          # This is a placeholder that will be replaced with the actual IP
          # during system evaluation - we can't calculate it here yet
          # but we define the logic to be used later
          getHostIP = config:
            let
              # Get all network interfaces
              interfaces = config.networking.interfaces;
              # Get the first interface name
              interfaceNames = builtins.attrNames interfaces;
              hasInterfaces = builtins.length interfaceNames > 0;
              firstInterface = if hasInterfaces then
                builtins.elemAt interfaceNames 0
              else
                null;

              # Get the IPv4 addresses for the first interface
              ipv4Config =
                if hasInterfaces && interfaces.${firstInterface} ? ipv4 then
                  interfaces.${firstInterface}.ipv4
                else
                  { };
              ipv4Addresses =
                if ipv4Config ? addresses then ipv4Config.addresses else [ ];
              hasIpv4 = builtins.length ipv4Addresses > 0;

              # Get the IPv6 addresses for the first interface
              ipv6Config =
                if hasInterfaces && interfaces.${firstInterface} ? ipv6 then
                  interfaces.${firstInterface}.ipv6
                else
                  { };
              ipv6Addresses =
                if ipv6Config ? addresses then ipv6Config.addresses else [ ];
              hasIpv6 = builtins.length ipv6Addresses > 0;

              # If multiple addresses are present, always use the first one.
            in if hasIpv4 then
              (builtins.elemAt ipv4Addresses 0).address
            else if hasIpv6 then
              (builtins.elemAt ipv6Addresses 0).address
            else
              config.networking.hostName;
        in getHostIP;
      }) hostDirs);

      nixosConfigurations = builtins.listToAttrs (builtins.map (hostName: {
        name = hostName;
        value = nixpkgs.lib.nixosSystem {
          system = system;
          modules = [
            "${toString ./hosts}/${hostName}/configuration.nix"
            inputs.sops-nix.nixosModules.sops
            # Set hostname based on directory name
            { networking.hostName = hostName; }
          ];
          specialArgs = {
            inherit inputs;
            hostIP = self.hostIPs.${hostName};
            pkgs-stable = nixpkgs-stable.legacyPackages.${system};
            pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
          };
        };
      }) hostDirs);

      # Dynamic host discovery for deploy-rs
      deploy = {
        activationTimeout = 600;
        # Use the same host discovery logic for deploy nodes
        nodes = builtins.listToAttrs (builtins.map (hostName: {
          name = hostName;
          value = {
            # Reuse the IP address calculation from hostIPs
            hostname = (self.hostIPs.${hostName})
              self.nixosConfigurations.${hostName}.config;
            # You can add more generic options here if needed
            sshUser = "root";
            # Use port 666 as specified
            sshOpts = [ "-p" "666" ];

            profiles.system = {
              user = "root";
              path = deploy-rs.lib.x86_64-linux.activate.nixos
                self.nixosConfigurations.${hostName};
              # You can add profile-specific options here if needed
              # autoRollback = true;
              # magicRollback = true;
            };
          };
        }) hostDirs);
      };

      # This is highly advised, and will prevent many possible mistakes
      # checks = builtins.mapAttrs
      #   (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
