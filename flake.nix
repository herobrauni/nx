{
  description =
    "NixOS configuration for multiple servers (dynamic host discovery)";

  inputs = {
    #nixpkgs.url = "nixpkgs/nixos-unstable";
    # nix doesn't need the full history, this should be the default ¯\_(ツ)_/¯
    nixpkgs.url =
      "git+https://github.com/NixOS/nixpkgs?shallow=1&ref=nixos-unstable";
    deploy-rs.url = "github:serokell/deploy-rs";
    sops-nix.url = "github:Mic92/sops-nix";
    # Optional: make sops-nix use the same nixpkgs as we do
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, deploy-rs, ... }@inputs:
    let
      # Get all host directories from the hosts folder
      hostDirs = builtins.filter
        (name: (builtins.readDir ./hosts)."${name}" == "directory")
        (builtins.attrNames (builtins.readDir ./hosts));
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
              # Get the IP addresses for the first interface
              ipv4Config =
                if hasInterfaces && interfaces.${firstInterface} ? ipv4 then
                  interfaces.${firstInterface}.ipv4
                else
                  { };
              addresses =
                if ipv4Config ? addresses then ipv4Config.addresses else [ ];
              hasIpAddress = builtins.length addresses > 0;
            in if hasIpAddress then
              (builtins.elemAt addresses 0).address
            else
              config.networking.hostName;
        in getHostIP;
      }) hostDirs);

      nixosConfigurations = builtins.listToAttrs (builtins.map (hostName: {
        name = hostName;
        value = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            "${toString ./hosts}/${hostName}/configuration.nix"
            # Common configuration for all hosts
            "${toString ./modules}/common.nix"
            # Add role modules as needed, e.g. ../roles/web.nix
            inputs.sops-nix.nixosModules.sops
            # Set hostname based on directory name
            { networking.hostName = hostName; }
          ];
          specialArgs = {
            inherit inputs;
            hostIP = self.hostIPs.${hostName};
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
      checks = builtins.mapAttrs
        (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
