# SPDX-FileCopyrightText: 2024 The nix-gerrit Authors <git@lukegb.com>
# SPDX-License-Identifier: MIT

{ nixpkgs ? <nixpkgs>
, pkgs ? import nixpkgs { }
, lib ? pkgs.lib
}:

lib.makeScope pkgs.newScope (self: {
  buildBazelPackageNG = self.callPackage ./buildBazelPackageNG { };
  gerrit = self.callPackage ./gerrit { };

  buildGerritBazelPlugin = self.callPackage ./plugins/builder.nix { };
  plugins = {
    code-owners = self.callPackage ./plugins/code-owners { };
    oauth = self.callPackage ./plugins/oauth { };
    metrics-reporter-prometheus = self.callPackage ./plugins/metrics-reporter-prometheus { };
  };

  ci = pkgs.linkFarm "gerrit-ci" [
    { name = "gerrit"; path = self.gerrit; }
    { name = "code-owners.jar"; path = self.plugins.code-owners; }
    { name = "oauth.jar"; path = self.plugins.oauth; }
    { name = "metrics-reporter-prometheus.jar"; path = self.plugins.metrics-reporter-prometheus; }
  ];
})
