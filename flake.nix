{
  description = "TODO...";

  inputs = {
    dream2nix.url = "github:nix-community/dream2nix";
    nixpkgs.follows = "dream2nix/nixpkgs";
  };

  outputs = {
    self,
    dream2nix,
    nixpkgs,
    ...
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems (supportedSystem:
        f rec {
          system = supportedSystem;
          pkgs = import nixpkgs {
            system = system;
            overlays = [];
          };
        });
  in {
    packages = forEachSupportedSystem ({pkgs, ...}: {
      default = dream2nix.lib.evalModules {
        packageSets.nixpkgs = pkgs;
        modules = [
          ./default.nix
          {
            paths.projectRoot = ./.;
            paths.projectRootFile = "flake.nix";
            paths.package = ./.;
            paths.lockFile =
              if pkgs.stdenv.isDarwin
              then "lock.default.darwin.json"
              else "lock.default.linux.json";
          }
        ];
      };
      dev = dream2nix.lib.evalModules {
        packageSets.nixpkgs = pkgs;
        modules = [
          ./default.nix
          {
            paths.projectRoot = ./.;
            paths.projectRootFile = "flake.nix";
            paths.package = ./.;
            paths.lockFile =
              if pkgs.stdenv.isDarwin
              then "lock.dev.darwin.json"
              else "lock.dev.linux.json";
            flags.pyarrow = true;
          }
        ];
      };
    });

    formatter = forEachSupportedSystem ({pkgs, ...}: pkgs.alejandra);

    devShells = forEachSupportedSystem ({
      system,
      pkgs,
      ...
    }: {
      default = pkgs.mkShell {
        inputsFrom = [
          self.packages.${system}.dev.devShell
        ];

        packages = [];
      };
    });
  };
}
