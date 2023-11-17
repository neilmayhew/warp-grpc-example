{
  description = "warp-grpc-example";

  inputs = {

    hackage = {
      url = "github:input-output-hk/hackage.nix";
      flake = false;
    };

    haskell-nix = {
      url = "github:input-output-hk/haskell.nix";
      inputs.hackage.follows = "hackage";
    };

    nixpkgs.follows = "haskell-nix/nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { flake-utils, nixpkgs, haskell-nix, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ] (system:
      let
        warp-grpc-example-overlay = final: prev: {
          warp-grpc-example = final.haskell-nix.cabalProject' rec {
            src = final.haskell-nix.cleanSourceHaskell {
              src = ./.;
              name = "warp-grpc-example-src";
            };
            compiler-nix-name = "ghc928";
            shell.buildInputs = with final; [
              protobuf
              haskell.packages.${compiler-nix-name}.proto-lens-protoc
            ];
          };
        };
        overlays = [ haskell-nix.overlay warp-grpc-example-overlay ];
        pkgs = import nixpkgs { inherit system overlays; inherit (haskell-nix) config; };
        flake = pkgs.warp-grpc-example.flake { };
      in
      flake // {
        packages.default = flake.packages."warp-grpc-example:exe:warp-grpc-example";
      });

  nixConfig = {
    extra-substituters = [
      "https://cache.iog.io"
    ];
    extra-trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];
    allow-import-from-derivation = true;
    accept-flake-config = true;
  };
}
