# SPDX-FileCopyrightText: 2024 The nix-gerrit Authors <git@lukegb.com>
# SPDX-License-Identifier: MIT

{ buildGerritBazelPlugin, fetchgit }:

buildGerritBazelPlugin rec {
  name = "oauth";
  version = "982316";
  src = fetchgit {
    url = "https://gerrit.googlesource.com/plugins/oauth";
    rev = "98231604d60788bb43490f1a301d792817ac8008";
    hash = "sha256-AuVO1Yys8BYqGHZI/adszCUg0JM2v4Td4fe26LdOPLM=";
  };
  depsHash = "sha256-mWR7hGl0c2lBH1YvUv6vAJohAwqhvDJohv559ms6Mkw=";
  postOverlayPlugin = ''
    cp "${src}/external_plugin_deps.bzl" "$out/plugins/external_plugin_deps.bzl"
  '';
}
