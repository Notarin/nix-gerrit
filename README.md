# nix-gerrit

<!--
SPDX-FileCopyrightText: 2024 The nix-gerrit Authors <git@lukegb.com>
SPDX-License-Identifier: MIT
-->

[Lix](https://lix.systems) expressions for building [Gerrit Code
Review](https://gerritcodereview.com)

Note that this is _not_ and is _not_ intended to be a fully vanilla Gerrit
builder. This set of Gerrit expressions contains some patches that deviate from
upstream. Be warned and review carefully!

## Gerrit

Gerrit can be built with

```
nix-build -A gerrit
# or, if you're feeling flake-y:
nix build
```

## Gerrit Plugins

### OAuth

The out-of-tree [Gerrit OAuth2 plugin](https://gerrit.googlesource.com/plugins/oauth/) is available.

```
nix-build -A plugins.oauth
# or
nix build '.#plugins.oauth'
```

### Code-Owners

The out-of-tree [Gerrit Code-Owners plugin](https://gerrit.googlesource.com/plugins/code-owners/) is available.

```
nix-build -A plugins.code-owners
# or
nix build '.#plugins.code-owners'
```

## Building everything at once

Everything in the tree can be built at once using the `ci` expression:

```
nix-build -A ci
# or
nix build '.#ci'
```

## Development environment

A development shell, containing enough stuff to build Gerrit on NixOS without too much faff is available:

```
nix-shell
# note that nix develop is currently broken
```

You can then build/test/etc inside a Gerrit Git checkout:

```
cd ~/src/gerrit
bazel build //:release
java -jar bazel-bin/release.war
```
