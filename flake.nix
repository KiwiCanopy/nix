{
  description = "Packages and Home Manager modules for KiwiCanopy apps";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      systems = [ "aarch64-darwin" ];

      # Our apps are licensed BSL 1.1, which nixpkgs counts as
      # unfree. Allow exactly our own packages, nothing else.
      ours = [ "kiwidesk" ];
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
          config.allowUnfreePredicate = p: builtins.elem (lib.getName p) ours;
        };
      forAll = f: lib.genAttrs systems (system: f (pkgsFor system));
    in
    {
      overlays.default = final: _prev: {
        kiwidesk = final.callPackage ./pkgs/kiwidesk {
          signedZipApp = final.callPackage ./lib/signed-zip-app.nix { };
        };
      };

      packages = forAll (pkgs: {
        inherit (pkgs) kiwidesk;
        default = pkgs.kiwidesk;
      });

      homeManagerModules = {
        kiwidesk = import ./modules/home-manager/kiwidesk.nix self;
        default = self.homeManagerModules.kiwidesk;
      };

      checks = forAll (pkgs: {
        inherit (pkgs) kiwidesk;
      });
    };
}
