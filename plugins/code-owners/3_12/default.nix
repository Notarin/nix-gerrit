# SPDX-FileCopyrightText: 2024 The nix-gerrit Authors <git@lukegb.com>
# SPDX-License-Identifier: MIT

{ lib, fetchgit, buildGerritBazelPlugin }:

buildGerritBazelPlugin rec {
  name = "code-owners";
  version = "${lib.substring 0 7 (src.rev or "dirty")}";
  src = fetchgit {
    url = "https://gerrit.googlesource.com/plugins/code-owners";
    # stable-3.12 as of 2025-06-22.
    rev = "9bf37d86596a6a5d5e3202780538265d9dc1e35a";
    hash = "sha256-r299sBUZB89fB6URBKOnqHw6IWw6iITR/Gh2lGMCRzs=";
  };
  patches = [
    ./using-usernames.patch
  ];
}
