# SPDX-FileCopyrightText: 2024 The nix-gerrit Authors <git@lukegb.com>
# SPDX-License-Identifier: MIT

{
  description = "Gerrit, a code-review service for Git";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    systems = [ "x86_64-linux" "aarch64-linux" ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    packages = forAllSystems (system: let
      pkgSet = import ./default.nix { pkgs = nixpkgs.legacyPackages."${system}"; };
    in {
      default = pkgSet.gerrit;
      inherit (pkgSet) gerrit gerrit_3_12 gerrit_3_13;
      inherit (pkgSet.plugins) oauth code-owners metrics-reporter-prometheus readonly download-commands autosubmitter;
      inherit (pkgSet) plugins_3_12 plugins_3_13;
    });

    hydraJobs = forAllSystems (system: let
      pkgSet = import ./default.nix { pkgs = nixpkgs.legacyPackages."${system}"; };
    in {
      inherit (pkgSet) ci ci-next;
    });

    devShells = forAllSystems (system: {
      default = import ./shell.nix { pkgs = nixpkgs.legacyPackages."${system}"; };
    });

    overlays.default = final: prev: {
      gerritPkgs = import ./default.nix { pkgs = final; };
      gerrit = final.gerritPkgs.gerrit;
      gerritPlugins = final.gerritPkgs.plugins;
    };
  };
}
