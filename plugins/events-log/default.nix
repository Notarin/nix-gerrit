# SPDX-FileCopyrightText: 2024 The nix-gerrit Authors <git@lukegb.com>
# SPDX-License-Identifier: MIT

{ buildGerritBazelPlugin, fetchgit, depsHash }:

buildGerritBazelPlugin rec {
  name = "events-log";
  version = "af36ed";
  src = fetchgit {
    url = "https://gerrit.googlesource.com/plugins/events-log";
    rev = "94da50d56bf9d5957b7eca6b402736a3244946c9";
    hash = "sha256-Rp6sgvEd4rt/xE8dhlxkSVg8zDNAMG4Y0xLxFfouYbQ=";
  };
  inherit depsHash;
  postOverlayPlugin = ''
    cp "${src}/external_plugin_deps.bzl" "$out/plugins/external_plugin_deps.bzl"
  '';
}
