{
  description = "leqnd's NixOS-config";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nvf.url = "github:notashelf/nvf";
    stylix.url = "github:danth/stylix";
  };

  outputs = {nixpkgs, ...} @ inputs: let
    system = "x86_64-linux";
    username = "martinb";

    mkSystem = {host, profile, modules}: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs username host profile;
      };
      inherit modules;
    };
  in {
    nixosConfigurations = {
      # ── Home ──────────────────────────────────────────────
      amd = mkSystem {
        host = "home"; profile = "amd";
        modules = [./profiles/amd];
      };
      nvidia = mkSystem {
        host = "home"; profile = "nvidia";
        modules = [./profiles/nvidia];
      };
      nvidia-laptop = mkSystem {
        host = "home"; profile = "nvidia-laptop";
        modules = [./profiles/nvidia-laptop];
      };
      intel = mkSystem {
        host = "home"; profile = "intel";
        modules = [./profiles/intel];
      };
      vm = mkSystem {
        host = "home"; profile = "vm";
        modules = [./profiles/vm];
      };

      # ── Work ──────────────────────────────────────────────
      work = mkSystem {
        host = "work"; profile = "intel";
        modules = [./profiles/work];
      };
    };
  };
}
