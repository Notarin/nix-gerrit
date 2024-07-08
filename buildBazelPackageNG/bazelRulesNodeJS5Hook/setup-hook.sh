# SPDX-FileCopyrightText: 2024 The nix-gerrit Authors <git@lukegb.com>
# SPDX-License-Identifier: MIT

prePatchHooks+=(_setupLocalNodeRepos)
preBuildHooks+=(_setupYarnCache)

case "$bazelPhase" in
	deps)
		postInstallHooks+=(_copyYarnCache)
		;;
	build)
		preBuildHooks+=(_linkYarnCache)
		;;
	shell)
		shellHooks+=(_setupLocalNodeRepos)
		;;
	*)
		echo "Unexpected bazelPhase '$bazelPhase' (want deps, build or shell)" >&2
		exit 1
		;;
esac


_setupLocalNodeRepos() {
	bazelFlagsArray+=(
		"--override_repository=build_bazel_rules_nodejs=@rulesNodeJS@"

		"--override_repository=nodejs_linux_amd64=@local_node@"
		"--override_repository=nodejs_linux_arm64=@local_node@"
		"--override_repository=nodejs_linux_s390x=@local_node@"
		"--override_repository=nodejs_linux_ppc64le=@local_node@"
		"--override_repository=nodejs_darwin_amd64=@local_node@"
		"--override_repository=nodejs_darwin_arm64=@local_node@"
		"--override_repository=nodejs_windows_amd64=@local_node@"
		"--override_repository=nodejs_windows_arm64=@local_node@"
		"--override_repository=nodejs=@local_node@"

		"--override_repository=yarn=@local_yarn@"
	)
}

_setupYarnCache() {
	@yarn@/bin/yarn config set cafile "@cacert@/etc/ssl/certs/ca-bundle.crt"
	@yarn@/bin/yarn config set yarn-offline-mirror "$NIXBAZEL_CACHE_ROOT/yarn-offline-mirror"
}

_copyYarnCache() {
	cp -R "$NIXBAZEL_CACHE_ROOT/yarn-offline-mirror" "$out/yarn-offline-mirror"
}

_linkYarnCache() {
	ln -sf "$deps/yarn-offline-mirror" "$NIXBAZEL_CACHE_ROOT/yarn-offline-mirror"
}
