{
  description = "Rust development environment";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
    devshell.url = "github:numtide/devshell";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, flake-compat, devshell }:
    { }
    //
    (flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ]
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              self.overlay
              devshell.overlay
            ];
            config = { };
          };
        in
        rec {
          devShell = with pkgs; pkgs.devshell.mkShell {
            packages = [
              cask
              # (tree-sitter.overrideAttrs (old: rec {
              #   version = "master";
              #   src = pkgs.fetchFromGitHub {
              #     owner = "tree-sitter";
              #     repo = "tree-sitter";
              #     rev = "65746afeff569478ea75f71927090c316debb96f";
              #     hash = "sha256-B7w2APsEnEXfcV6pRLxQKKXwaoaKLjkvMTryfwfn5xw=";
              #   };
              #   cargoDeps = pkgs.rustPlatform.fetchCargoTarball {
              #     name = "tree-sitter-master";
              #     inherit src;
              #     hash = "sha256-7XOrlZJubsN85MQCWhhvi21xID5/E8OixVCGWFUVERU=";
              #   };
              # }))
              cargo-watch
              rustc
              cargo
              gcc
            ];
            imports = [
              (pkgs.devshell.importTOML ./bin/devshell.toml)
            ];
            env = [
              {
                name = "LIBCLANG_PATH";
                value = "${llvmPackages_9.libclang.lib}/lib";
              }
            ];
          };
        })
    ) //
    {
      overlay = final: prev: { };
    };
}
