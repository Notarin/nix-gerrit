# SPDX-FileCopyrightText: 2024 The nix-gerrit Authors <git@lukegb.com>
# SPDX-License-Identifier: MIT

{ makeSetupHook }:

makeSetupHook {
  name = "rules_java_bazel_hook";
  substitutions = {
    local_java = ./local_java;
  };
} ./setup-hook.sh
