# SPDX-FileCopyrightText: 2024 The nix-gerrit Authors <git@lukegb.com>
# SPDX-License-Identifier: MIT

{ stdenv
, lib
, pkgs
, coreutils
, mkShell
, writeShellApplication
}:

let
  hooks = {
    bazelRulesJavaHook = pkgs.callPackage ./bazelRulesJavaHook { };
    bazelRulesNodeJS5Hook = pkgs.callPackage ./bazelRulesNodeJS5Hook { };
  };

  builder = {
    name ? "${baseAttrs.pname}-${baseAttrs.version}"
    , bazelTargets
    , bazel ? pkgs.bazel
    , depsHash
    , extraCacheInstall ? ""
    , extraBuildSetup ? ""
    , extraBuildInstall ? ""
    , ...
    }@baseAttrs:

    let
      cleanAttrs = lib.flip removeAttrs [
        "bazelTargets" "depsHash" "extraCacheInstall" "extraBuildSetup" "extraBuildInstall"
      ];
      attrs = cleanAttrs baseAttrs;

      base = stdenv.mkDerivation (attrs // {
        nativeBuildInputs = (attrs.nativeBuildInputs or []) ++ [
          bazel
        ];

        preUnpack = ''
          if [[ ! -d $HOME ]]; then
            export HOME=$NIX_BUILD_TOP/home
            mkdir -p $HOME
          fi
          export NIXBAZEL_CACHE_ROOT=$NIX_BUILD_TOP/nixbazel-cache
          mkdir -p $NIXBAZEL_CACHE_ROOT
        '';

        bazelTargetNames = builtins.attrNames bazelTargets;
      });

      deps = base.overrideAttrs (base: {
        name = "${name}-deps";

        bazelPhase = "deps";

        buildPhase = ''
          runHook preBuild

          bazel sync --repository_cache=$NIXBAZEL_CACHE_ROOT/repository-cache $bazelFlags "''${bazelFlagsArray[@]}"
          bazel build --repository_cache=$NIXBAZEL_CACHE_ROOT/repository-cache --nobuild $bazelFlags "''${bazelFlagsArray[@]}" $bazelTargetNames

          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall

          mkdir $out
          echo "${lib.head (lib.splitVersion bazel.version)}" > $out/bazel_version
          cp -R $NIXBAZEL_CACHE_ROOT/repository-cache $out/repository-cache
          ${extraCacheInstall}

          runHook postInstall
        '';

        outputHashMode = "recursive";
        outputHash = depsHash;
      });

      build = base.overrideAttrs (base: {
        bazelPhase = "build";

        inherit deps;
        passthru = (base.passthru or {}) // {
          inherit shell;
        };

        nativeBuildInputs = (base.nativeBuildInputs or []) ++ [
          coreutils
        ];

        buildPhase = ''
          runHook preBuild

          ${extraBuildSetup}
          bazel build --repository_cache=$deps/repository-cache $bazelFlags "''${bazelFlagsArray[@]}" $bazelTargetNames

          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall

          ${builtins.concatStringsSep "\n" (lib.mapAttrsToList (target: outPath: lib.optionalString (outPath != null) ''
            TARGET_OUTPUTS="$(bazel cquery --repository_cache=$deps/repository-cache $bazelFlags "''${bazelFlagsArray[@]}" --output=files "${target}")"
            if [[ "$(echo "$TARGET_OUTPUTS" | wc -l)" -gt 1 ]]; then
              echo "Installing ${target}'s outputs ($TARGET_OUTPUTS) into ${outPath} as a directory"
              mkdir -p "${outPath}"
              cp $TARGET_OUTPUTS "${outPath}"
            else
              echo "Installing ${target}'s output ($TARGET_OUTPUTS) to ${outPath}"
              mkdir -p "${dirOf outPath}"
              cp "$TARGET_OUTPUTS" "${outPath}"
            fi
          '') bazelTargets)}
          ${extraBuildInstall}

          runHook postInstall
        '';
      });

      bazelShellLauncher = writeShellApplication {
        name = "bazel";

        runtimeInputs = [ bazel ];

        text = ''
          exec bazel "--bazelrc=$NIXBAZEL_SHELL_BAZELRC" "$@"
        '';
      };

      shell = mkShell rec {
        name = if baseAttrs ? name then "${baseAttrs.name}-shell" else "${baseAttrs.pname}-shell";

        bazelPhase = "shell";

        inputsFrom = [ build ];
        packages = [ bazelShellLauncher ];

        postHook = ''
          shellHooks+=(_finalShellSetup)
          _finalShellSetup() {
            # This is set up in postHook because we need to make sure that this shell hook happens
            # _after_ every other shell hook.

            for arg in "''${bazelFlagsArray[@]}"; do
              echo "common ''${arg}"
            done > "$NIXBAZEL_SHELL_BAZELRC"
          }
        '';

        shellHook = ''
          export NIXBAZEL_CACHE_ROOT=$NIX_BUILD_TOP/cache
          mkdir -p $NIXBAZEL_CACHE_ROOT
          export NIXBAZEL_SHELL_BAZELRC="$NIXBAZEL_CACHE_ROOT/${name}-bazelrc"
        '';
      };
    in build;
in hooks // {
  __functor = self: lib.makeOverridable builder;
}
