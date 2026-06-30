{ ... }:
{
  # Unlock ThinkPad fan control in the kernel module
  boot.extraModprobeConfig = ''
    options thinkpad_acpi fan_control=1
  '';

  services.thinkfan = {
    enable = true;

    # Temperature levels for i7-10750H (Comet Lake-H)
    # Format: [ fan-level  low-temp  high-temp ]
    # Hysteresis of ~5°C between levels prevents constant on/off switching
    levels = [
      [ 1   0  55 ] # minimum always spinning — avoids fan on/off cycling and coil whine
      [ 2  51  63 ]
      [ 3  59  69 ]
      [ 4  65  76 ]
      [ 5  72  83 ]
      [ 7  79 32767 ]
    ];
  };
}
