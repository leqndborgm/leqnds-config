{ host, ... }: {
  imports = [
    ../../hosts/${host}
    ../../modules/drivers
    ../../modules/core/home
  ];
  # Enable GPU Drivers
  drivers.amdgpu.enable = true;
  drivers.nvidia.enable = false;
  drivers.nvidia-prime.enable = false;
  drivers.intel.enable = false;
  vm.guest-services.enable = false;
}
