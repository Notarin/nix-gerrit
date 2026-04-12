#!/usr/bin/env nix-shell
# SPDX-FileCopyrightText: 2026 Yureka Lilian <yureka@cyberchaos.dev>
# SPDX-License-Identifier: MIT
#! nix-shell -i python3 -p git nurl python3.pkgs.packaging python3.pkgs.click python3.pkgs.click-log python3.pkgs.joblib python3.pkgs.platformdirs

import tempfile
import click
import click_log
import logging
import sys
import subprocess
import pathlib
import json
from packaging import version as packaging_version
from joblib import Memory
from platformdirs import user_cache_dir

DIR = pathlib.Path(__file__).parent


logger = logging.getLogger(__name__)
click_log.basic_config(logger)

memory: Memory = Memory(user_cache_dir("nix-gerrit-updater"), verbose=0)


def cache(mem, **mem_kwargs):
    def cache_(f):
        f.__module__ = "nix-gerrit-updater"
        f.__qualname__ = f.__name__
        return mem.cache(f, **mem_kwargs)
    return cache_


@cache(memory)
def get_src_hash(repo_url, tag: str):
    return subprocess.check_output(
        [
            "nurl",
            "--fetcher",
            "fetchgit",
            "--hash",
            "--arg",
            "fetchSubmodules",
            "true",
            repo_url,
            tag
        ]
    ).decode("utf-8").strip()

@cache(memory)
def get_bazel_deps_hash(repo_url, tag: str):
    src_hash = get_src_hash(repo_url, tag)
    version_info = get_bazel_version_info(repo_url, tag)
    expr = f"""
((import {DIR} {{}}).callPackage {DIR}/gerrit/common.nix {{
  version = "{tag.removeprefix("v")}";
  srcHash = "{src_hash}";
  depsHash = "";
  versionInfo = [\"{"\" \"".join(version_info)}\"];
}}).deps
    """

    return subprocess.check_output(
        [
            "nurl",
            "--expr",
            expr
        ]
    ).decode("utf-8").strip()

@cache(memory)
def get_bazel_version_info(repo_url, tag: str):
    with tempfile.TemporaryDirectory() as tmp_dir:
        subprocess.check_call(["git", "clone", repo_url, "gerrit"], cwd=tmp_dir)
        subprocess.check_call(["git", "checkout", tag], cwd=tmp_dir+"/gerrit")
        subprocess.check_call(["git", "submodule", "init"], cwd=tmp_dir+"/gerrit")
        subprocess.check_call(["git", "submodule", "update"], cwd=tmp_dir+"/gerrit")
        versions_file = subprocess.check_output(["python3", "tools/workspace_status_release.py"], cwd=tmp_dir+"/gerrit").decode("utf-8").strip()
    return sorted(versions_file.split("\n"))

class GitilesRepo:
    def __init__(self, url):
        self.url = url

    @property
    def tags(self):
        logger.info("Fetching tags...")
        cmd = ["git", "ls-remote", "--tags", "--refs", self.url]
        output = subprocess.check_output(cmd, stderr=subprocess.STDOUT, timeout=10)
        lines = output.decode("utf-8").strip().split("\n")

        tags = []
        for line in lines:
            if "\t" not in line:
                continue
            tag_ref = line.split("\t")[1]

            if not tag_ref.startswith("refs/tags/"):
                continue
            tag_name = tag_ref.removeprefix("refs/tags/")

            tags.append(tag_name)

        return tags

    def get_latest_release(self, branch: str):
        branch_major, branch_minor = packaging_version.parse(branch).release
        versions = [
            packaging_version.parse(tag.removeprefix("v"))
            for tag in self.tags
            if tag.startswith("v")
        ]

        latest = next(
            ver for ver in sorted(versions, reverse=True)
            if ver.major == branch_major and ver.minor == branch_minor
        )
        logger.info(f"Selected {latest} as latest release of {branch} branch")
        return latest

    def get_src_hash(self, tag: str):
        return get_src_hash(self.url, tag)

    def get_bazel_deps_hash(self, tag: str):
        return get_bazel_deps_hash(self.url, tag)

    def get_bazel_version_info(self, tag: str):
        return get_bazel_version_info(self.url, tag)


@click.command()
@click_log.simple_verbosity_option(logger)
@click.option('--branch', help='Branch e.g. 3.13', required=True)
@click.option('--version', default="latest", help='Version to update to e.g. 3.13.2')
def cli(branch, version):
    repo = GitilesRepo("https://gerrit.googlesource.com/gerrit")
    if version == "latest":
        version = repo.get_latest_release(branch)
    else:
        version = packaging_version.parse(version)
    tag = f"v{version}"

    new_info = {
        "version": str(version),
        "srcHash": repo.get_src_hash(tag),
        "versionInfo": repo.get_bazel_version_info(tag),
        "depsHash": repo.get_bazel_deps_hash(tag),
    }

    path = DIR / "gerrit/versions.json"
    try:
        with open(path, "r") as f:
            content = json.loads(f.read())
    except:
        content = {}

    content[f"{version.major}_{version.minor}"] = new_info

    with open(path, "w") as f:
        json.dump(content, f, indent=4, sort_keys=True)


if __name__ == "__main__":
    cli()
