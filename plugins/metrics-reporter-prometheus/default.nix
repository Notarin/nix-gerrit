# SPDX-FileCopyrightText: 2024 The nix-gerrit Authors <git@lukegb.com>
# SPDX-License-Identifier: MIT

{ buildGerritBazelPlugin, fetchgit }:

buildGerritBazelPlugin rec {
  name = "metrics-reporter-prometheus";
  version = "f2ee1d";
  src = fetchgit {
    url = "https://gerrit.googlesource.com/plugins/metrics-reporter-prometheus";
    rev = "f2ee1de665281596ae300144243fcf94bf6f1f7d";
    hash = "sha256-iUFzSXKIKBdZBZMpZiejkEEXXI20wTJQRYkufc/YjOM=";
  };
  depsHash = "sha256-hxnQlzzVQ15fyVo613FOsHlZZgOL1lBKOgqEGBoc7To=";
  postOverlayPlugin = ''
    cp "${src}/external_plugin_deps.bzl" "$out/plugins/external_plugin_deps.bzl"
  '';
}
