# SPDX-FileCopyrightText: 2024 The nix-gerrit Authors <git@lukegb.com>
# SPDX-License-Identifier: MIT

{ buildGerritBazelPlugin, fetchgit }:

buildGerritBazelPlugin rec {
  name = "code-owners";
  version = "fb04a18";
  src = fetchgit {
    url = "https://gerrit.googlesource.com/plugins/code-owners";
    rev = "fb04a189c603bf473f3c8413a14b4c10641944c2";
    hash = "sha256-tMKSR5NgJcYY7tmOjzl7GQJPzvBb0PuUf2DMjaGtIoI=";
  };
  patches = [
    # ./using-usernames.patch
  ];
}
