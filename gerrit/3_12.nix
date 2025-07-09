# SPDX-FileCopyrightText: 2024 The nix-gerrit Authors <git@lukegb.com>
# SPDX-License-Identifier: MIT

{ buildBazelPackageNG
, lib
, fetchgit
, bazel_7
, python3
, openjdk21_headless
, curl
, unzip
, extraBazelPackageAttrs ? {}
}:

let
  inherit (buildBazelPackageNG) bazelRulesJavaHook bazelRulesNodeJS5Hook;
in
(buildBazelPackageNG rec {
  pname = "gerrit";
  version = "3.12.0";

  bazel = bazel_7;

  src = (fetchgit {
    url = "https://gerrit.googlesource.com/gerrit";
    rev = "v${version}";
    fetchSubmodules = true;
    deepClone = true;
    hash = "sha256-CeZlvN9f1qZNhsPnKxFcHsI1Qvpsq1x/e/m5/D7YhGc=";
  }).overrideAttrs (_: {
    env.NIX_PREFETCH_GIT_CHECKOUT_HOOK = ''
      pushd "$dir" >/dev/null
      ${python3}/bin/python tools/workspace_status_release.py | sort > .version
      popd >/dev/null

      # delete all the .git; we can't do this using fetchgit if deepClone is on,
      # but our mischief has already been achieved by the python command above :)
      find "$dir" -name .git -print0 | xargs -0 rm -rf
    '';
  });
  depsHash = "sha256-5bjU3/pOYhvMO1S5RqQc0VC3ecXirs+vIujOOhuTnLo=";

  patches = [
    ./0001-Revert-Remove-net.i2p.crypto-eddsa.patch
    ./0002-Syntax-highlight-rules.pl.patch
    ./0003-Add-titles-to-CLs-over-HTTP.patch
  ];

  nativeBuildInputs = [
    bazelRulesJavaHook
    bazelRulesNodeJS5Hook

    curl
    openjdk21_headless
    python3
    unzip
  ];

  shellHook = ''
    bazelFlagsArray+=(
      '--javacopt="-XepDisableAllChecks"'
    )
  '';

  prePatch = ''
    rm .bazelversion

    ln -sf ${./bazelrc} user.bazelrc

    ln -sf ${./workspace_overrides.bzl} workspace_overrides.bzl
    substituteInPlace WORKSPACE \
      --replace-fail 'load("@io_bazel_rules_webtesting//web:repositories.bzl"' 'load("//:workspace_overrides.bzl"' \
      --replace-fail 'load("@io_bazel_rules_webtesting//web/versioned:browsers-0.3.3.bzl"' 'load("//:workspace_overrides.bzl"'

    patchShebangs Documentation/replace_macros.py
  '';

  postPatch = ''
    sed -Ei 's,^(STABLE_BUILD_GERRIT_LABEL.*)$,\1-dirty-nix,' .version
  '';

  preBuild = ''
    export GERRIT_CACHE_HOME=$NIXBAZEL_CACHE_ROOT/gerrit-cache
  '';

  extraCacheInstall = ''
    cp -R $GERRIT_CACHE_HOME $out/gerrit-cache
    # lcov_merger_tools is from bazel (and thus depends on nixpkgs
    # version, breaking hashes), but isn't actually needed for the
    # build. So let's remove that specific path.
    lcov_merger_tools_path=$(grep -rl all_lcov_merger_tools_deploy.jar $out | head -n1)
    rm -r "$(dirname "$lcov_merger_tools_path")"
  '';

  extraBuildSetup = ''
    ln -sf $deps/gerrit-cache $GERRIT_CACHE_HOME
  '';
  extraBuildInstall = ''
    mkdir -p "$out"/share/api/
    unzip bazel-bin/api-skip-javadoc.zip -d "$out"/share/api
  '';

  bazelTargets = {
    "//:release" = "$out/webapps/gerrit-${version}.war";
    "//:api-skip-javadoc" = null;
  };

  passthru = {
    # A list of plugins that are part of the gerrit.war file.
    # Use `java -jar gerrit.war ls | grep -Po '(?<=plugins/)[^.]+' | sed -e 's,^,",' -e 's,$,",' | sort` to generate that list.
    plugins = [
      "codemirror-editor"
      "commit-message-length-validator"
      "delete-project"
      "download-commands"
      "gitiles"
      "hooks"
      "plugin-manager"
      "replication"
      "reviewnotes"
      "singleusergroup"
      "webhooks"
    ];
  };
}).override extraBazelPackageAttrs
