{ pkgs, ... }: {
  services.ollama = {
    enable = true;
    package = pkgs.ollama;
    environmentVariables = {
      OLLAMA_FLASH_ATTN = "1";
      # Keep models in RAM 30min after last request — avoids cold reloads.
      OLLAMA_KEEP_ALIVE = "30m";
      # Two models at once: chat (qwen3) + FIM completion (deepseek-coder).
      OLLAMA_MAX_LOADED_MODELS = "2";
      # Parallel requests per model (e.g. chat + ghost-text).
      OLLAMA_NUM_PARALLEL = "2";
    };
  };
}
