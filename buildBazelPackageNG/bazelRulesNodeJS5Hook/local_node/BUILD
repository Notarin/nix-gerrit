# SPDX-FileCopyrightText: 2024 The nix-gerrit Authors <git@lukegb.com>
# SPDX-License-Identifier: MIT

load("@build_bazel_rules_nodejs//nodejs:toolchain.bzl", _node_toolchain = "node_toolchain")

package(default_visibility = ["//visibility:public"])

exports_files([
    "bin/node",
    "bin/npm",
])

_node_toolchain(
    name = "node_toolchain",
    target_tool_path = "@nodejs@/bin/node",
    npm_path = "@nodejs@/bin/npm",
)

toolchain(
    name = "nodejs",
    toolchain = ":node_toolchain",
    toolchain_type = "@build_bazel_rules_nodejs//nodejs:toolchain_type",
)
