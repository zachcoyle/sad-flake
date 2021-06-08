{
  description = "naersk flake template";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixpkgs-unstable;
    flake-utils.url = github:numtide/flake-utils;
    naersk.url = "github:nmattia/naersk";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sad-src = { url = github:ms-jpq/sad; flake = false; };
  };

  outputs = { self, nixpkgs, flake-utils, fenix, naersk, sad-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ fenix.overlay ];
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

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            fenix.packages.${system}.minimal.cargo
            fenix.packages.${system}.minimal.rustc
          ];
        };

      });
}
