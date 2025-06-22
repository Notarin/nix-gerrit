# SPDX-FileCopyrightText: 2024 The nix-gerrit Authors <git@lukegb.com>
# SPDX-License-Identifier: MIT

{ callPackage }:
{
  gerrit_3_11 = callPackage ./3_11.nix { };
  gerrit_3_12 = callPackage ./3_12.nix { };
}
