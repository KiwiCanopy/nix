{ lib, signedZipApp }:
signedZipApp {
  pname = "kiwidesk";
  appName = "KiwiDesk";
  source = ./source.json;
  binaries.kiwidesk = "Contents/MacOS/KiwiDesk";
  meta = {
    description = "Tiling window manager for macOS with layouts, profiles and Lua";
    homepage = "https://kiwidesk.kiwicanopy.com/";
    changelog = "https://github.com/KiwiCanopy/KiwiDesk/releases";
    license = lib.licenses.bsl11;
    mainProgram = "kiwidesk";
  };
}
