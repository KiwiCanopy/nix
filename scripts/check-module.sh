#!/usr/bin/env bash
# Evaluates a minimal Home Manager configuration that enables every
# module this flake exports, and checks the defaults KiwiDesk reads.
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"

nix eval --impure --json --expr "
let
  self = builtins.getFlake \"git+file://${root}\";
  hm = builtins.getFlake \"github:nix-community/home-manager\";
  pkgs = import self.inputs.nixpkgs { system = \"aarch64-darwin\"; };
  conf = hm.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [
      self.homeManagerModules.kiwidesk
      {
        home.username = \"ci\";
        home.homeDirectory = \"/Users/ci\";
        home.stateVersion = \"25.11\";
        programs.kiwidesk.enable = true;
        programs.kiwidesk.initLua = \"-- ci\";
      }
    ];
  };
  defaults = conf.config.targets.darwin.defaults.\"com.kiwicanopy.kiwidesk\";
in
assert conf.activationPackage.drvPath != \"\";
assert defaults.KiwiDeskUpdatesManagedBy == \"Home Manager\";
assert defaults.KiwiDeskUpdatesManagedFolder
  == \"/Users/ci/\" + conf.config.targets.darwin.copyApps.directory;
defaults
"
