{
  description = "gitpod-flake-ghc9";
  nixConfig.bash-prompt = "\[develop\]$ ";
  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/21.11";
    nixpkgs.url = "github:NixOS/nixpkgs/5181d5945eda382ff6a9ca3e072ed6ea9b547fee";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.nixpkgs.follows = "nixpkgs";

    hls.url = "github:haskell/haskell-language-server";
    hls.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs = { self, nixpkgs, flake-utils, hls /*, rhine*/ }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowBroken = true; };
          overlays = [];
        };
        # Change GHC version here. To get the appropriate value, run:
        #   nix-env -f "<nixpkgs>" -qaP -A haskell.compiler
        # hp = pkgs.haskellPackages;
        hp = pkgs.haskell.packages.ghc922.override {
          overrides = self: super: (
            if system == "aarch64-darwin"
              then
                let
                  # https://github.com/NixOS/nixpkgs/issues/140774#issuecomment-976899227
                  workaround140774 = hpkg: with pkgs.haskell.lib;
                    overrideCabal hpkg (drv: {
                      enableSeparateBinOutput = false;
                    });
                in
                  {
                    ghcid = workaround140774 super.ghcid;
                  }
              else {});
        };

        packageName ="gitpod-flake-ghc9";

        project = returnShellEnv :
          hp.developPackage {
            inherit returnShellEnv;
            name = packageName;
            root = ./.;
            overrides = self: super: {
              # Use callCabal2nix to override Haskell dependencies here
              # cf. https://tek.brick.do/K3VXJd8mEKO7
              # Example:
              # > NanoID = self.callCabal2nix "NanoID" inputs.NanoID { };
              # Assumes that you have the 'NanoID' flake input defined.
              network = pkgs.haskell.lib.dontCheck (self.callHackage "network" "3.1.2.5" {});
              retry = pkgs.haskell.lib.dontCheck (self.callHackage "retry" "0.9.2.0" {});
            };
            modifier = drv:
              pkgs.haskell.lib.addBuildTools drv (with hp; [
                # Specify your build/dev dependencies here.
                # cabal-fmt
                cabal-install
                ghcid
                haskell-language-server
                hls
                hlint
                fourmolu
                pkgs.nixpkgs-fmt
              ]);
            };
      in {

        # Used by `nix build` & `nix run` (prod exe)
        defaultPackage = project false;
        # Used by `nix develop` (dev shell)
        devShell = project true;

      }
    );
}
