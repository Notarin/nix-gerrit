# SPDX-FileCopyrightText: 2024 The nix-gerrit Authors <git@lukegb.com>
# SPDX-License-Identifier: MIT

{ gerrit
, runCommandLocal
, lib
}:

{ name
, version
, src
, depsHash ? null 
, overlayPluginCmd ? ''
    cp -R "${src}" "$out/plugins/${name}"
    echo "STABLE_BUILD_${lib.toUpper name}_LABEL v${version}-nix${if patches != [] then "-dirty" else ""}" >> $out/.version
  ''
, postOverlayPlugin ? ""
, postPatch ? ""
, patches ? [ ]
}: ((gerrit.override {
  extraBazelPackageAttrs = (old: {
    name = "${name}.jar";

    src = runCommandLocal "${name}-src" { } ''
      cp -R "${gerrit.src}" "$out"
      chmod -R +w "$out"
      ${overlayPluginCmd}
      ${postOverlayPlugin}
    '';
    depsHash = (if depsHash != null then depsHash else old.depsHash);

    bazelTargets = {
      "//plugins/${name}" = "$out";
    };

    extraBuildInstall = "";
  });
}).overrideAttrs (super: {
  postPatch = ''
    ${super.postPatch or ""}
    pushd "plugins/${name}"
    ${lib.concatMapStringsSep "\n" (patch: ''
      patch -p1 < ${patch}
    '') patches}
    popd
    ${postPatch}
  '';
}))
