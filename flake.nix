{
  description = "leqnd's NixOS-config";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nvf.url = "github:notashelf/nvf";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:danth/stylix";
    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";
    };
    astal = {
      url = "github:aylur/astal/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {nixpkgs, ...} @ inputs: let
    system = "x86_64-linux";
    username = "martinb";

    mkSystem = {hostname, host, profile, modules}: nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs username host profile hostname;
      };
      modules = modules ++ [
        { nixpkgs.hostPlatform = system; }
        { nixpkgs.config.allowUnfree = true; }
      ];
    };
  in {
    nixosConfigurations = {
      # ── Home ──────────────────────────────────────────────
      amd = mkSystem {
        hostname = "amd"; host = "home"; profile = "amd";
        modules = [./profiles/amd];
      };
      # nvidia = mkSystem {
      #   hostname = "nvidia"; host = "home"; profile = "nvidia";
      #   modules = [./profiles/nvidia];
      # };
      nvidia-laptop = mkSystem {
        hostname = "nvidia-laptop"; host = "home"; profile = "nvidia-laptop";
        modules = [./profiles/nvidia-laptop];
      };
      intel = mkSystem {
        hostname = "intel"; host = "home"; profile = "intel";
        modules = [./profiles/intel];
      };
      # vm = mkSystem {
      #   hostname = "vm"; host = "home"; profile = "vm";
      #   modules = [./profiles/vm];
      # };

      # ── Work ──────────────────────────────────────────────
      work = mkSystem {
        hostname = "work"; host = "work"; profile = "intel";
        modules = [./profiles/work];
      };
    };
  };
}
