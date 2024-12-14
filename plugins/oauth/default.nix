# SPDX-FileCopyrightText: 2024 The nix-gerrit Authors <git@lukegb.com>
# SPDX-License-Identifier: MIT

{ buildGerritBazelPlugin, fetchgit, lib }:

buildGerritBazelPlugin rec {
  name = "oauth";
  version = "982316";
  src = fetchgit {
    url = "https://gerrit.googlesource.com/plugins/oauth";
    rev = "98231604d60788bb43490f1a301d792817ac8008";
    hash = "sha256-AuVO1Yys8BYqGHZI/adszCUg0JM2v4Td4fe26LdOPLM=";
  };
  depsHash = "sha256-LnfVTPvGDpLqAQ1QfAwFv0FA0aCg6H1WUgxVjjYTLoY=";
  postOverlayPlugin = ''
    cp "${src}/external_plugin_deps.bzl" "$out/plugins/external_plugin_deps.bzl"
  '';
}
