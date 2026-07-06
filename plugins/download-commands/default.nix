# SPDX-FileCopyrightText: 2024 The nix-gerrit Authors <git@lukegb.com>
# SPDX-License-Identifier: MIT

{ buildGerritBazelPlugin, fetchgit, depsHash }:

buildGerritBazelPlugin rec {
  name = "download-commands";
  version = "9e1337d12deb4ae23dc9c8e4a4ab0660822cf139";
  src = fetchgit {
    url = "https://gerrit.googlesource.com/plugins/download-commands";
    rev = "9e1337d12deb4ae23dc9c8e4a4ab0660822cf139";
    hash = "sha256-8mMUwYHfek3qD9cOx4Mnisa8GKVnEP5q5SIq8TnrWto=";
  };
  inherit depsHash;
}
