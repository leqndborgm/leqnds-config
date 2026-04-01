{ pkgs, ... }: {
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda; # Lenovo Thinkpad T15g Gen 1 has NVIDIA GPU
    environmentVariables = {
      OLLAMA_FLASH_ATTN = "1"; # ~10-30% speedup, no quality loss
    };
  };
}
