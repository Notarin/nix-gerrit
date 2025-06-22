# SPDX-FileCopyrightText: 2024 The nix-gerrit Authors <git@lukegb.com>
# SPDX-License-Identifier: MIT

{ lib, fetchgit, buildGerritBazelPlugin }:

buildGerritBazelPlugin rec {
  name = "code-owners";
  version = "${lib.substring 0 7 (src.rev or "dirty")}";
  src = fetchgit {
     url = "https://gerrit.googlesource.com/plugins/code-owners";
      # stable-3.11 as of 2025-06-22.
      rev = "323341dd81d8197ee4acd012a6611085009b66b5";
      hash = "sha256-46TEuQQTifUCJjWzu6D3sxWY83xZ2eLbzT96TRGnjuo=";
  };
  patches = [
    ./using-usernames.patch
  ];
}
