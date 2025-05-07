# SPDX-FileCopyrightText: 2024 The nix-gerrit Authors <git@lukegb.com>
# SPDX-License-Identifier: MIT

{ nixpkgs ? <nixpkgs>
, pkgs ? import nixpkgs { }
, lib ? pkgs.lib
}:
let
  depsHashes = {
    "3_11" = {
      "oauth" = "sha256-F8YkLplNT+yystFnRAUJyBJxCojzS8ZX/N/ULK0sBjQ=";
      "metric-reporter-prometheus" = "sha256-R86Qk//e/gXi6yCd1+KaiuJNU30nGgB8iNH0VTAzOYE=";
    };
    "3_12" = {
      "oauth" = "sha256-7UuSmVxeGGJjXXsNN70UfXZyM3lsU28acxy8JAuzP1s=";
      "metric-reporter-prometheus" = "sha256-v3T2/aBpQpOzqyA/OkJRadHU/x0qmdXVGg+NKnG+2Pg=";
    };
  };
  mkPluginSet = { self, depsHashes, buildGerritBazelPlugin }: {
    code-owners = self.callPackage ./plugins/code-owners {
      inherit buildGerritBazelPlugin;
    };
    oauth = self.callPackage ./plugins/oauth {
      inherit buildGerritBazelPlugin;
      depsHash = depsHashes.oauth;
    };
    metrics-reporter-prometheus = self.callPackage ./plugins/metrics-reporter-prometheus {
      inherit buildGerritBazelPlugin;
      depsHash = depsHashes.metric-reporter-prometheus;
    };
  };
in
lib.makeScope pkgs.newScope (self: {
  buildBazelPackageNG = self.callPackage ./buildBazelPackageNG { };
  inherit (self.callPackage ./gerrit { }) gerrit_3_11 gerrit_3_12;

  buildGerrit311BazelPlugin = self.callPackage ./plugins/builder.nix {
    gerrit = self.gerrit_3_11;
  };
  buildGerrit312BazelPlugin = self.callPackage ./plugins/builder.nix {
    gerrit = self.gerrit_3_12;
  };

  plugins_3_11 = mkPluginSet { 
    inherit self;
    depsHashes = depsHashes."3_11";
    buildGerritBazelPlugin = self.buildGerrit311BazelPlugin;
  };
  plugins_3_12 = mkPluginSet { 
    inherit self;
    depsHashes = depsHashes."3_12";
    buildGerritBazelPlugin = self.buildGerrit312BazelPlugin;
  };

  buildGerritBazelPlugin = self.buildGerrit311BazelPlugin;
  gerrit = self.gerrit_3_11;
  plugins = self.plugins_3_11;

  ci = pkgs.linkFarm "gerrit-${self.gerrit.version}-ci" [
    { name = "gerrit"; path = self.gerrit; }
    { name = "code-owners.jar"; path = self.plugins.code-owners; }
    { name = "oauth.jar"; path = self.plugins.oauth; }
    { name = "metrics-reporter-prometheus.jar"; path = self.plugins.metrics-reporter-prometheus; }
  ];

  ci-next = pkgs.linkFarm "gerrit-${self.gerrit_3_11.version}-ci" [
    { name = "gerrit"; path = self.gerrit_3_11; }
    { name = "code-owners.jar"; path = self.plugins_3_11.code-owners; }
    { name = "oauth.jar"; path = self.plugins_3_11.oauth; }
    { name = "metrics-reporter-prometheus.jar"; path = self.plugins_3_11.metrics-reporter-prometheus; }
  ];
})
