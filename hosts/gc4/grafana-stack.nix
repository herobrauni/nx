{ config, pkgs, ... }:
{
  # grafana configuration
  services.grafana = {
    enable = true;
    domain = "grafana.brill-bebop.ts.net";
    port = 2342;
    addr = "127.0.0.1";
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
