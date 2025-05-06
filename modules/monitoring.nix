{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.prometheus.exporters.node.enable = true;
  services.vmagent = {
    enable = true;
    remoteWrite.url = "http://gc4.brill-bebop.ts.net:8428/api/v1/write";
    extraArgs = [ "-remoteWrite.label=instance=${config.networking.hostName}" ];

    prometheusConfig = {
      global = {
        external_labels = {
          "host" = config.networking.hostName;
        };
      };
      scrape_configs = [
        {
          job_name = "node";
          scrape_interval = "10s";
          static_configs = [
            { targets = [ "127.0.0.1:9100" ]; }
          ];
        }
        {
          job_name = "vmagent";
          scrape_interval = "10s";
          static_configs = [
            { targets = [ "127.0.0.1:8429" ]; }
          ];
        }
      ];
    };
  };
}
