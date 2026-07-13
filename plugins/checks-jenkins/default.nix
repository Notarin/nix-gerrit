# SPDX-FileCopyrightText: 2024 The nix-gerrit Authors <git@lukegb.com>
# SPDX-License-Identifier: MIT

{ buildGerritBazelPlugin, fetchgit, depsHash }:

buildGerritBazelPlugin {
  name = "checks-jenkins";
  version = "30069f";
  src = fetchgit {
    url = "https://gerrit.googlesource.com/plugins/checks-jenkins";
    rev = "30069f6504543f167541a9ad6afafbc824f26f23";
    hash = "sha256-Xc0eVzKnBDKEmRKyv8MVq9hwiuVcpGeEWnrfDwN24kI=";
  };
  inherit depsHash;
}
