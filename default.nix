# SPDX-FileCopyrightText: 2024 The nix-gerrit Authors <git@lukegb.com>
# SPDX-License-Identifier: MIT

{ nixpkgs ? <nixpkgs>
, pkgs ? import nixpkgs { }
, lib ? pkgs.lib
}:
let
  depsHashes = {
    "3_10" = {
      "oauth" = "sha256-GukI0DN47YjRJT3WdDr+nVoj2sOJoWsmJQs4Lqhr1e8=";
      "metric-reporter-prometheus" = "sha256-eKm2RJ7KO1cSh7+27iZQubkB64Sjs7+5VCXj99JKGkI=";
    };
    "3_11" = {
      "oauth" = "sha256-Xx607OSqlRMr8mlkVhfXiqM9hWcJqx4dmpf+cm10uSA=";
      "metric-reporter-prometheus" = "sha256-CzhpAN9Jh9E6GV+/UzVnNn56bOld8evdWcpkr/eFtag=";
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
  inherit (self.callPackage ./gerrit { }) gerrit_3_10 gerrit_3_11;

  buildGerrit310BazelPlugin = self.callPackage ./plugins/builder.nix { 
    gerrit = self.gerrit_3_10;
  };
  buildGerrit311BazelPlugin = self.callPackage ./plugins/builder.nix {
    gerrit = self.gerrit_3_11;
  };

  plugins_3_10 = mkPluginSet { 
    inherit self;
    depsHashes = depsHashes."3_10";
    buildGerritBazelPlugin = self.buildGerrit310BazelPlugin;
  };
  plugins_3_11 = mkPluginSet { 
    inherit self;
    depsHashes = depsHashes."3_11";
    buildGerritBazelPlugin = self.buildGerrit311BazelPlugin;
  };

  buildGerritBazelPlugin = self.buildGerrit310BazelPlugin;
  gerrit = self.gerrit_3_10;
  plugins = self.plugins_3_10;

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
