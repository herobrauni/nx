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
  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 0;
        grpc_listen_port = 0;
      };
      positions.filename = "/tmp/positions.yaml";
      clients = [
        {
          url = "http://gc4.brill-bebop.ts.net:9428/insert/loki/api/v1/push";
        }
      ];
      scrape_configs = [
        {
          job_name = "journal";
          journal = {
            max_age = "6h";
            labels = {
              job = "systemd-journal";
              host = config.networking.hostName;
            };
          };
          relabel_configs = [
            {
              source_labels = [ "__journal_priority" ];
              target_label = "priority";
            }
            {
              source_labels = [ "__journal_priority_keyword" ];
              target_label = "level";
            }
            {
              source_labels = [ "__journal__systemd_unit" ];
              target_label = "unit";
            }
            {
              source_labels = [ "__journal__systemd_user_unit" ];
              target_label = "user_unit";
            }
            {
              source_labels = [ "__journal__boot_id" ];
              target_label = "boot_id";
            }
            {
              source_labels = [ "__journal__comm" ];
              target_label = "command";
            }
          ];
        }
      ];
    };
  };
}
