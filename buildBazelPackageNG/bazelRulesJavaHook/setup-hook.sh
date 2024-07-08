# SPDX-FileCopyrightText: 2024 The nix-gerrit Authors <git@lukegb.com>
# SPDX-License-Identifier: MIT

prePatchHooks+=(_setupLocalJavaRepo)
shellHooks+=(_setupLocalJavaRepo)

javaVersions=(11 17 21)
javaPlatforms=(
  "linux" "linux_aarch64" "linux_ppc64le" "linux_s390x"
  "macos" "macos_aarch64"
  "win" "win_arm64")

_setupLocalJavaRepo() {
	for javaVersion in ${javaVersions[@]}; do
		for javaPlatform in ${javaPlatforms[@]}; do
			bazelFlagsArray+=(
				"--override_repository=remotejdk${javaVersion}_${javaPlatform}=@local_java@"
			)
		done
	done
}
