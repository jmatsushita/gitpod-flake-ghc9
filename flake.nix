{
  description = "gitpod-flake-ghc9";
  nixConfig.bash-prompt = "\[develop\]$ ";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/21.11";
    flake-utils.url = "github:numtide/flake-utils";

    hls.url = "github:haskell/haskell-language-server";
    hls.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, hls }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowBroken = true; };
          overlays = [];
        };
        haskellPackages = pkgs.haskell.packages.ghc921.override  {
          overrides = self: super: {
            # In case you need them
            network = pkgs.haskell.lib.dontCheck (self.callHackage "network" "3.1.2.5" {});
          };
        };
        packageName ="gitpod-flake-ghc9";
      in {

        packages.${packageName} =
          haskellPackages.callCabal2nix packageName self rec {
            # Link cabal extra-librarires to nix system packages
            # zlib = pkgs.zlib;
          };

        defaultPackage = self.packages.${system}.${packageName};

        devShell = haskellPackages.shellFor {
          packages = p: [];

          buildInputs = with haskellPackages; [
            pkgs.zlib
            pkgs.zlib.dev

            cabal-install
            ghcid
            # haskell-language-server
            hls
            # hlint
            # ormolu
          ];
          # withHoogle = true;
        };
      }
    );
}
