# SPDX-FileCopyrightText: 2024 The nix-gerrit Authors <git@lukegb.com>
# SPDX-License-Identifier: MIT

{ nixpkgs ? <nixpkgs>
, pkgs ? import nixpkgs { }
, lib ? pkgs.lib
}:
let
  depsHashes = { # Fake hash (for convenience): sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
    "3_12" = {
      "oauth" = "sha256-QuKpMFPp26X9tC4eqQr2P1CAfsD5IVFtqbwcoXBsD+c=";
      "readonly" = "sha256-kOYdFjMrOJkE+9Sq9Al7Ixhd8LbBJZC0ZUOvrl3n6Dk=";
      "metric-reporter-prometheus" = "sha256-2ibJ17/ESOpcwtBlJftCnW0hWbT0dfmowA72eZL43zc=";
      "download-commands" = "sha256-kOYdFjMrOJkE+9Sq9Al7Ixhd8LbBJZC0ZUOvrl3n6Dk=";
      "autosubmitter" = "sha256-kOYdFjMrOJkE+9Sq9Al7Ixhd8LbBJZC0ZUOvrl3n6Dk=";
      "checks-jenkins" = "sha256-kOYdFjMrOJkE+9Sq9Al7Ixhd8LbBJZC0ZUOvrl3n6Dk=";
      "events-log" = "sha256-EcQLAfyaaCZOevMcREc9P71I2nL+A4+fw1n+bMvhc1E=";
    };
    "3_13" = {
      "oauth" = "sha256-pikzl11Kl+bc8l3RZsH+G/6tJ/xrScC9FO6kNNJSyOI=";
      "readonly" = "sha256-nNIfYW18oI9CfMmI/HVtnOatxUhMcXYqiPWabkdpoGk=";
      "metric-reporter-prometheus" = "sha256-vN2VZOGjefwsqWsAXX1pOuRla7RrZQEBOndb/mmhfb0=";
      "download-commands" = "sha256-nNIfYW18oI9CfMmI/HVtnOatxUhMcXYqiPWabkdpoGk=";
      "autosubmitter" = "sha256-nNIfYW18oI9CfMmI/HVtnOatxUhMcXYqiPWabkdpoGk=";
      "checks-jenkins" = "sha256-nNIfYW18oI9CfMmI/HVtnOatxUhMcXYqiPWabkdpoGk=";
      "events-log" = "sha256-WRAjNcCGFFVhxbDcBFbn/f0maUC/rVhI3I87bNmqlRQ=";
    };
  };
  mkPluginSet = { self, variant, depsHashes, buildGerritBazelPlugin }: {
    code-owners = self.callPackage ./plugins/code-owners/${variant} {
      inherit buildGerritBazelPlugin;
    };
    oauth = self.callPackage ./plugins/oauth {
      inherit buildGerritBazelPlugin;
      depsHash = depsHashes.oauth;
    };
    download-commands = self.callPackage ./plugins/download-commands {
      inherit buildGerritBazelPlugin;
      depsHash = depsHashes.download-commands;
    };
    autosubmitter = self.callPackage ./plugins/autosubmitter {
      inherit buildGerritBazelPlugin;
      depsHash = depsHashes.autosubmitter;
    };
    readonly = self.callPackage ./plugins/readonly {
      inherit buildGerritBazelPlugin;
      depsHash = depsHashes.readonly;
    };
    metrics-reporter-prometheus = self.callPackage ./plugins/metrics-reporter-prometheus {
      inherit buildGerritBazelPlugin;
      depsHash = depsHashes.metric-reporter-prometheus;
    };
    checks-jenkins = self.callPackage ./plugins/checks-jenkins {
      inherit buildGerritBazelPlugin;
      depsHash = depsHashes."checks-jenkins";
    };
    events-log = self.callPackage ./plugins/events-log {
      inherit buildGerritBazelPlugin;
      depsHash = depsHashes."events-log";
    };
  };
in
lib.makeScope pkgs.newScope (self: {
  buildBazelPackageNG = self.callPackage ./buildBazelPackageNG { };
  inherit (self.callPackage ./gerrit { }) gerrit_3_12 gerrit_3_13;

  buildGerrit312BazelPlugin = self.callPackage ./plugins/builder.nix {
    gerrit = self.gerrit_3_12;
  };
  buildGerrit313BazelPlugin = self.callPackage ./plugins/builder.nix {
    gerrit = self.gerrit_3_13;
  };

  plugins_3_12 = mkPluginSet { 
    inherit self;
    depsHashes = depsHashes."3_12";
    variant = "3_12";
    buildGerritBazelPlugin = self.buildGerrit312BazelPlugin;
  };
  plugins_3_13 = mkPluginSet { 
    inherit self;
    depsHashes = depsHashes."3_13";
    variant = "3_13";
    buildGerritBazelPlugin = self.buildGerrit313BazelPlugin;
  };

  buildGerritBazelPlugin = self.buildGerrit312BazelPlugin;
  gerrit = self.gerrit_3_12;
  plugins = self.plugins_3_12;

  ci = pkgs.linkFarm "gerrit-${self.gerrit.version}-ci" [
    { name = "gerrit"; path = self.gerrit; }
    { name = "code-owners.jar"; path = self.plugins.code-owners; }
    { name = "oauth.jar"; path = self.plugins.oauth; }
    { name = "readonly.jar"; path = self.plugins.readonly; }
    { name = "metrics-reporter-prometheus.jar"; path = self.plugins.metrics-reporter-prometheus; }
  ];

  ci-next = pkgs.linkFarm "gerrit-${self.gerrit_3_13.version}-ci" [
    { name = "gerrit"; path = self.gerrit_3_13; }
    { name = "code-owners.jar"; path = self.plugins_3_13.code-owners; }
    { name = "oauth.jar"; path = self.plugins_3_13.oauth; }
    { name = "metrics-reporter-prometheus.jar"; path = self.plugins_3_13.metrics-reporter-prometheus; }
  ];
})
