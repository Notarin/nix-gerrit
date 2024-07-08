# SPDX-FileCopyrightText: 2024 The nix-gerrit Authors <git@lukegb.com>
# SPDX-License-Identifier: MIT

{ stdenvNoCC
, lib
, makeSetupHook
, fetchFromGitHub
, coreutils
, gnugrep
, nodejs
, yarn
, git
, cacert
}:
let
  rulesNodeJS = stdenvNoCC.mkDerivation rec {
    pname = "bazelbuild-rules_nodejs";
    version = "5.8.5";

    src = fetchFromGitHub {
      owner = "bazelbuild";
      repo = "rules_nodejs";
      rev = version;
      hash = "sha256-6UbYRrOnS93+pK4VI016gQZv2jLCzkJn6wJ4vZNCNjY=";
    };

    dontBuild = true;

    postPatch = ''
      shopt -s globstar
      for i in **/*.bzl **/*.sh **/*.cjs; do
        substituteInPlace "$i" \
          --replace-quiet '#!/usr/bin/env bash' '#!${stdenvNoCC.shell}' \
          --replace-quiet '#!/bin/bash' '#!${stdenvNoCC.shell}'
      done
      sed -i '/^#!/a export PATH=${lib.makeBinPath [ coreutils gnugrep ]}:$PATH' internal/node/launcher.sh
    '';

    installPhase = ''
      cp -R . $out
    '';
  };

  localNode = stdenvNoCC.mkDerivation rec {
    name = "bazelbuild-rules_nodejs-local_node";

    src = ./local_node;

    inherit nodejs;

    buildPhase = ''
      runHook preBuild

      substituteInPlace BUILD WORKSPACE bin/* \
        --subst-var nodejs

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      cp -R . $out
      chmod +x $out/bin/*
      runHook postInstall
    '';
  };
  localYarn = stdenvNoCC.mkDerivation rec {
    name = "bazelbuild-rules_nodejs-local_yarn";

    src = ./local_yarn;

    inherit yarn;

    buildPhase = ''
      runHook preBuild

      substituteInPlace BUILD WORKSPACE bin/* \
        --subst-var yarn

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      cp -R . $out
      chmod +x $out/bin/*
      runHook postInstall
    '';
  };
in makeSetupHook {
  name = "bazelbuild-rules_nodejs-5-hook";
  propagatedBuildInputs = [
    nodejs
    yarn
    git
    cacert
  ];
  substitutions = {
    inherit nodejs yarn cacert rulesNodeJS;
    local_node = localNode;
    local_yarn = localYarn;
  };
} ./setup-hook.sh
