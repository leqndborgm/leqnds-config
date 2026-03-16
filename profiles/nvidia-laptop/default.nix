{
  config,
  pkgs,
  inputs,
  host,
  ...
}: let
  inherit (import ../../hosts/${host}/variables.nix) intelID nvidiaID;
in {
  imports = [
    ../../hosts/${host}
    ../../modules/drivers
    ../../modules/core/home
  ];

  # Enable GPU Drivers
  drivers.amdgpu.enable = false;
  drivers.nvidia.enable = true;
  drivers.nvidia-prime = {
    enable = true;
    intelBusID = "${intelID}";
    nvidiaBusID = "${nvidiaID}";
  };
  drivers.intel.enable = false;

  # Disable guest additions
  vm.guest-services.enable = false;
}
