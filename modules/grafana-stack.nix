{ config, pkgs, ... }:
{
  # grafana configuration
  services.grafana = {
    enable = true;
    settings.server = {
      domain = "gc4.brill-bebop.ts.net";
      http_port = 2342;
      http_addr = "127.0.0.1";
    };
    # domain = "grafana.brill-bebop.ts.net";
    # port = 2342;
    # addr = "127.0.0.1";
    provision = {
      dashboards.settings.providers = [
        {
          name = "Overview";
          options.path = "/etc/grafana-dashboards";
        }
      ];

      datasources.settings = {
        apiVersion = 1;
        datasources = [
          {
            name = "VictoriaMetrics";
            type = "victoriametrics-metrics-datasource";
            access = "proxy";
            url = "http://127.0.0.1:8428";
            isDefault = true;
          }

          {
            name = "VictoriaLogs";
            type = "victoriametrics-logs-datasource";
            access = "proxy";
            url = "http://127.0.0.1:9428";
            isDefault = false;
          }
        ];
      };
    };

    declarativePlugins = with pkgs.grafanaPlugins; [
      victoriametrics-metrics-datasource
      victoriametrics-logs-datasource
    ];
  };
  services.victoriametrics = {
    enable = true;
    listenAddress = ":8428";
  };
  services.victorialogs = {
    enable = true;
    listenAddress = ":9428";
  };
  services.prometheus.enable = false;
}
