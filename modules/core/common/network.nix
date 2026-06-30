{
  pkgs,
  host,
  options,
  ...
}: {
  networking = {
    hostName = "${host}";
    networkmanager = {
      enable = true;
      plugins = with pkgs; [networkmanager-openvpn];
      settings = {
        device."wifi.scan-rand-mac-address" = "no";
        connection."wifi.powersave" = 3;
      };
    };
    timeServers = options.networking.timeServers.default ++ ["pool.ntp.org"];
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        80
        443
        59010
        59011
        8080
      ];
      allowedUDPPorts = [
        59010
        59011
      ];
    };
  };

  environment.systemPackages = with pkgs; [networkmanagerapplet];
}
