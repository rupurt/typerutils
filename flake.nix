# {
#   description = "Nix flake for typer utility helpers";
#
#   inputs = {
#     nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
#     flake-utils.url = "github:numtide/flake-utils";
#   };
#
#   outputs = {
#     flake-utils,
#     nixpkgs,
#     ...
#   }: let
#     systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
#     outputs = flake-utils.lib.eachSystem systems (system: let
#       pkgs = import nixpkgs {
#         inherit system;
#         overlays = [];
#       };
#     in {
#       # packages exported by the flake
#       packages = {};
#
#       # nix run
#       apps = {};
#
#       # nix fmt
#       formatter = pkgs.alejandra;
#
#       # nix develop -c $SHELL
#       devShells.default = pkgs.mkShell {
#         name = "default dev shell";
#
#         buildInputs = with pkgs;
#           [
#             ccache
#             gnumake
#             zlib
#             openssl
#             (python311Full.withPackages (ps:
#               with ps; [
#                 pip
#                 setuptools
#               ]))
#             uv
#           ]
#           ++ pkgs.lib.optionals (pkgs.stdenv.isLinux) [
#             pythonManylinuxPackages.manylinux1
#           ];
#
#         packages = with pkgs; [
#           python311Packages.venvShellHook
#         ];
#
#         venvDir = ".venv";
#         postShellHook = ''
#           export PATH=$(realpath .)/bin:$PATH
#         '';
#       };
#     });
#   in
#     outputs;
# }
{
  description = "Typer utility helpers";

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
            inherit system;
            overlays = [ ];
          };
        });
  in {
    packages = forEachSupportedSystem ({pkgs, ...}: rec {
      prod = dream2nix.lib.evalModules {
        packageSets.nixpkgs = pkgs;
        modules = [
          ./default.nix
          {
            paths.projectRoot = ./.;
            paths.projectRootFile = "flake.nix";
            paths.package = ./.;
            paths.lockFile =
              if pkgs.stdenv.isDarwin
              then "lock.prod.darwin.json"
              else "lock.prod.linux.json";
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
            flags.groupDev = true;
          }
        ];
      };
      default = prod;
    });

    # nix fmt
    formatter = forEachSupportedSystem ({pkgs, ...}: pkgs.alejandra);

    # nix develop
    devShells = forEachSupportedSystem ({
      system,
      pkgs,
      ...
    }: {
      # nix develop -c $SHELL
      default = pkgs.mkShell {
        inputsFrom = [
          self.packages.${system}.dev.devShell
        ];

        packages = with pkgs;
          [
            argc
          ];

        shellHook = ''
          export IN_NIX_DEVSHELL=1;
        '';
      };
    });

    overlay = final: prev: {
      typerutils = self.packages.${prev.system};
    };
  };
}
