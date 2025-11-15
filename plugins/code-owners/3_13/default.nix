# SPDX-FileCopyrightText: 2024 The nix-gerrit Authors <git@lukegb.com>
# SPDX-License-Identifier: MIT

{ lib, fetchgit, buildGerritBazelPlugin }:

buildGerritBazelPlugin rec {
  name = "code-owners";
  version = "${lib.substring 0 7 (src.rev or "dirty")}";
  src = fetchgit {
     url = "https://gerrit.googlesource.com/plugins/code-owners";
      # master as of 2025-11-15.
      rev = "6516292dec2924caeed4e7833164a096d921ca31";
      hash = "sha256-UjF3hSyY6ae+mcceOEKN778a4Tm3PPon/c3GvwlBST8=";
  };
  patches = [
    ./using-usernames.patch
  ];
}
