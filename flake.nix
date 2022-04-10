{
  description = "gitpod-flake-ghc9";
  nixConfig.bash-prompt = "\[develop\]$ ";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowBroken = true; };
          overlays = [];
        };
        haskellPackages = pkgs.haskellPackages.override  {
          overrides = self: super: {
            # In case you need them
          };
        };
        packageName ="gitpod-flake-ghc9";
      in {

        packages.${packageName} =
          haskellPackages.callCabal2nix packageName self rec {
            # Link cabal extra-librarires to nix system packages
            zlib = pkgs.zlib;
          };

        defaultPackage = self.packages.${system}.${packageName};

        devShell = haskellPackages.shellFor {
          packages = p: [];

          buildInputs = with haskellPackages; [
            pkgs.zlib
            pkgs.zlib.dev

            cabal-install
            ghcid
            haskell-language-server
            hlint
            ormolu
          ];
          withHoogle = true;
        };
      });
}
