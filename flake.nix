{
  description = "CLI search and replace | Space Age seD";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixpkgs-unstable;
    flake-utils.url = github:numtide/flake-utils;
    devshell.url = github:numtide/devshell;
    naersk.url = "github:nmattia/naersk";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sad-src = { url = github:ms-jpq/sad; flake = false; };
  };

  outputs = { self, nixpkgs, flake-utils, devshell, fenix, naersk, sad-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            devshell.overlay
            fenix.overlay
          ];
        };
        naersk-lib = naersk.lib.${system}.override {
          inherit (fenix.packages.${system}.minimal) cargo rustc;
        };
      in
      rec {
        packages.sad = naersk-lib.buildPackage {
          pname = "sad";
          root = sad-src;
        };

        defaultPackage = packages.sad;

        apps.sad = flake-utils.lib.mkApp {
          drv = packages.sad;
        };

        defaultApp = apps.sad;

        devShell = pkgs.devshell.mkShell {
          packages = with pkgs; [
            fenix.packages.${system}.minimal.cargo
            fenix.packages.${system}.minimal.rustc
          ];
        };

      });
}
