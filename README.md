<div align="center">

<img src="https://kiwicanopy.com/brand/icon-512.png" alt="KiwiCanopy" width="96">

# KiwiCanopy Nix flake

</div>

Nix packages and Home Manager modules for [KiwiCanopy](https://kiwicanopy.com) apps. Each
package repackages the app's signed, notarized release as it ships.
Nothing is built from source, so the code signature, and with it
macOS's Accessibility grant, survives every update.

| App | Package | Home Manager module |
|---|---|---|
| [KiwiDesk](https://kiwidesk.kiwicanopy.com/) | `kiwidesk` | `programs.kiwidesk` |

Apple silicon Macs only (`aarch64-darwin`).

## KiwiDesk with Home Manager

```nix
{
  inputs.kiwicanopy.url = "github:KiwiCanopy/nix";

  # in your Home Manager configuration:
  imports = [ inputs.kiwicanopy.homeModules.kiwidesk ];

  targets.darwin.copyApps.enable = true; # the default from stateVersion 25.11
  programs.kiwidesk = {
    enable = true;
    # initLua = builtins.readFile ./init.lua;  # optional
  };
}
```

The module needs `targets.darwin.copyApps`. A symlinked app moves to
a new `/nix/store` path on every update, which leaves KiwiDesk's
login item pointing at an old copy.

To update:

```sh
nix flake update kiwicanopy && home-manager switch
```

KiwiDesk's own updater stays off for this copy, and Settings says
updates come from Home Manager.

### What the module manages

- The app in `~/Applications/Home Manager Apps` and `kiwidesk` on
  your `PATH`.
- `~/.config/KiwiDesk/init.lua`, only when you set `initLua`.
- Two defaults that tell KiwiDesk Home Manager installs its updates.

Profiles, `gui.json` and every other file in `~/.config/KiwiDesk`
stay the app's. KiwiDesk rewrites them itself, so the module never
touches them.

### Rolling back

Going back to an older Home Manager generation can meet profiles a
newer KiwiDesk has already upgraded. The older version cannot read
them. Before rolling back across a KiwiDesk update, back up the
contents of `~/.config/KiwiDesk`.

### License

KiwiDesk is licensed under BSL 1.1, which nixpkgs counts as unfree.
This flake allows exactly its own packages. If you take the package
from the overlay into your own nixpkgs instead, allow it there:

```nix
nixpkgs.config.allowUnfreePredicate = pkg:
  builtins.elem (lib.getName pkg) [ "kiwidesk" ];
```

## Without Home Manager

```sh
nix run github:KiwiCanopy/nix#kiwidesk -- --version
```

## Updates to this repository

Each app's release workflow rewrites its own
`pkgs/<app>/source.json` when a release is published, so two apps'
releases never write the same file.
