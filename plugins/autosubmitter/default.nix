# SPDX-FileCopyrightText: 2024 The nix-gerrit Authors <git@lukegb.com>
# SPDX-License-Identifier: MIT

{ buildGerritBazelPlugin, fetchgit, depsHash }:

buildGerritBazelPlugin {
  name = "autosubmitter";
  version = "64a19a24da74cfcdfd6e8e71c4344135d0132e22";
  src = fetchgit {
    url = "https://gerrit.googlesource.com/plugins/autosubmitter.git";
    rev = "64a19a24da74cfcdfd6e8e71c4344135d0132e22";
    hash = "sha256-Tq1hS9ow0/GE9DRq1sqfaOf52rODwdlfeGjzcOED488=";
  };
  inherit depsHash;
}
