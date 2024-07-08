# SPDX-FileCopyrightText: 2024 The nix-gerrit Authors <git@lukegb.com>
# SPDX-License-Identifier: MIT

{ buildGerritBazelPlugin, fetchgit }:

buildGerritBazelPlugin rec {
  name = "code-owners";
  version = "7de40d8";
  src = fetchgit {
    url = "https://gerrit.googlesource.com/plugins/code-owners";
    rev = "7de40d8b30e55eb64316b6fc3d0d00da9caddade";
    hash = "sha256-0sLwUcG9RN1o9vZGW8ErwL7UgJapgYoo8XMGsWLO25Q=";
  };
  patches = [
    ./using-usernames.patch
  ];
}
