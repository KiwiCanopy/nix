# Repackages a Developer ID signed, notarized .app from its release
# ZIP. Nothing may touch the bundle's bytes: macOS ties the
# Accessibility grant to the signature, so a stripped or patched
# binary would lose it on every install.
{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:
{
  pname,
  # The bundle's name inside the ZIP, without ".app".
  appName,
  # JSON with `version`, `url` and an SRI `hash`; the release
  # workflow of each app rewrites its own file.
  source,
  # Command name -> path inside the bundle, linked into $out/bin.
  binaries ? { },
  meta ? { },
}:
let
  src = lib.importJSON source;
  links = lib.concatStrings (
    lib.mapAttrsToList (name: path: ''
      ln -s "$out/Applications/${appName}.app/${path}" "$out/bin/${name}"
    '') binaries
  );
in
stdenvNoCC.mkDerivation {
  inherit pname;
  inherit (src) version;

  src = fetchurl { inherit (src) url hash; };

  nativeBuildInputs = [ unzip ];
  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;
  # Strip and patch steps would break the code signature.
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications" "$out/bin"
    cp -R "${appName}.app" "$out/Applications/"
    ${links}
    runHook postInstall
  '';

  meta = {
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  } // meta;
}
