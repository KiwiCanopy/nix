self:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.kiwidesk;
  copyApps = config.targets.darwin.copyApps or { };
in
{
  options.programs.kiwidesk = {
    enable = lib.mkEnableOption "KiwiDesk, a tiling window manager for macOS";

    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${pkgs.stdenv.hostPlatform.system}.kiwidesk;
      defaultText = lib.literalExpression "kiwicanopy.packages.\${system}.kiwidesk";
      description = "The KiwiDesk package to install.";
    };

    initLua = lib.mkOption {
      type = lib.types.nullOr lib.types.lines;
      default = null;
      example = ''
        gap.set_global(8, 8)
      '';
      description = ''
        Contents of {file}`~/.config/KiwiDesk/init.lua`. When set, the
        file is managed by Home Manager and read-only. Null leaves it
        to you and the Settings app. Profiles and every other file in
        that folder stay the app's: KiwiDesk rewrites them itself.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = pkgs.stdenv.hostPlatform.isDarwin;
        message = "programs.kiwidesk: KiwiDesk runs on macOS only.";
      }
      {
        assertion = copyApps.enable or false;
        message = ''
          programs.kiwidesk needs targets.darwin.copyApps.enable = true.
          A symlinked app moves to a new /nix/store path on every
          update, which leaves KiwiDesk's login item pointing at an
          old or deleted copy.
        '';
      }
    ];

    home.packages = [ cfg.package ];

    xdg.configFile."KiwiDesk/init.lua" = lib.mkIf (cfg.initLua != null) {
      text = cfg.initLua;
    };

    # KiwiDesk keeps Sparkle off for a copy inside this folder, since
    # the next switch would undo any update Sparkle installed. The
    # folder is part of the contract: a stale name alone must not
    # switch updates off for a copy installed some other way.
    targets.darwin.defaults."com.kiwicanopy.kiwidesk" = {
      KiwiDeskUpdatesManagedBy = "Home Manager";
      KiwiDeskUpdatesManagedFolder = "${config.home.homeDirectory}/${
        copyApps.directory or "Applications/Home Manager Apps"
      }";
    };
  };
}
