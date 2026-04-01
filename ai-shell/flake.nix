{
  description = "AI dev shell — oterm + Ollama tools";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.${system}.default = pkgs.mkShell {
      name = "ai-shell";

      packages = with pkgs; [
        oterm          # TUI for chatting with Ollama models
        ollama         # CLI access to the Ollama service
      ];

      shellHook = ''
        echo ""
        echo "🤖 AI Shell ready"
        echo ""
        echo "Commands:"
        echo "  oterm — open AI chat (has file access to ~/Projekte)"
        echo ""
      '';
    };
  };
}
