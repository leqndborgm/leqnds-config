{ pkgs, ... }: {
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda; # Lenovo Thinkpad T15g Gen 1 has NVIDIA GPU
  };
}
