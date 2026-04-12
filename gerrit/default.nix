# SPDX-FileCopyrightText: 2024 The nix-gerrit Authors <git@lukegb.com>
# SPDX-FileCopyrightText: 2026 Yureka Lilian <yureka@cyberchaos.dev>
# SPDX-License-Identifier: MIT

{ lib, callPackage }:

let
  versions = lib.importJSON ./versions.json;
in
lib.mapAttrs' (
  version: info:
  lib.nameValuePair "gerrit_${version}" (
    callPackage ./common.nix info
  )
) versions
