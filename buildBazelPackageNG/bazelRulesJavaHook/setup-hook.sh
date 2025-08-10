# SPDX-FileCopyrightText: 2024 The nix-gerrit Authors <git@lukegb.com>
# SPDX-License-Identifier: MIT

prePatchHooks+=(_setupLocalJavaRepo _setupIPv6Only)
shellHooks+=(_setupLocalJavaRepo _setupIPv6Only)

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

_setupIPv6Only() {
	bazelGlobalFlagsArray+=(
		--host_jvm_args=-Djava.net.preferIPv6Addresses=system
	)
}
