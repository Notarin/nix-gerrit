# SPDX-FileCopyrightText: 2026 The nix-gerrit Authors <git@lukegb.com>
# SPDX-License-Identifier: MIT

{ buildGerritBazelPlugin, fetchgit, depsHash }:

buildGerritBazelPlugin {
  name = "readonly";
  version = "unstable-2024-08-05";
  src = fetchgit {
    url = "https://gerrit.googlesource.com/plugins/readonly";
    rev = "de07a6b95d94ef4124fba9c3ded89d83fe2adc01";
    hash = "sha256-ZIpTikTASueAZ/vyVCWWroFmowXD3UVhWPE4A1wyDZo=";
  };
  inherit depsHash;
}
