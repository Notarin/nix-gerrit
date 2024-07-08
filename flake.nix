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
    in pkgSet // { default = pkgSet.gerrit; });
    devShells = forAllSystems (system: {
      default = import ./shell.nix { pkgs = nixpkgs.legacyPackages."${system}"; };
    });
  };
}
