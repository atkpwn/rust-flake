{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
        rustVersion = pkgs.rust-bin.stable.latest.default;

        rustPlatform = pkgs.makeRustPlatform {
          cargo = rustVersion;
          rustc = rustVersion;
        };

        graderBuild = rustPlatform.buildRustPackage {
          pname = "basic";
          version = "0.1.0";
          src = ./.;

          cargoLock.lockFile = ./Cargo.lock;
        };
      in
      {
        defaultPackage = graderBuild;
        devShell = pkgs.mkShell {
          buildInputs = [
            (rustVersion.override { extensions = [ "rust-src" ]; })
          ];
          shellHook = ''
            export PS1="\[\e[93m\](rust-env)\[\e[0m\] $ "
          '';
        };
      }
    );
}
