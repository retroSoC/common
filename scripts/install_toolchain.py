#!/usr/bin/env python3
"""Install checksum-verified CI toolchain archives."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import posixpath
import re
import shutil
import tarfile
import tempfile
import time
import urllib.request
from pathlib import Path, PurePosixPath
from typing import Any


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def validate_relative_path(label: str, value: str) -> None:
    path = PurePosixPath(value)
    if path.is_absolute() or ".." in path.parts:
        raise ValueError(f"{label} must be a relative path")


def load_lock(path: Path) -> dict[str, Any]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise ValueError(f"cannot read toolchain lock {path}: {error}") from error

    if data.get("schema_version") != 1:
        raise ValueError("toolchain lock schema_version must be 1")
    toolchains = data.get("toolchains")
    if not isinstance(toolchains, dict) or not toolchains:
        raise ValueError("toolchain lock must define at least one platform")

    fields = ("version", "url", "sha256", "archive", "path")
    for platform, tools in toolchains.items():
        if not isinstance(platform, str) or not platform:
            raise ValueError("toolchain platform must be a non-empty string")
        if not isinstance(tools, dict) or not tools:
            raise ValueError(f"toolchain platform is empty: {platform}")
        for name, spec in tools.items():
            if not isinstance(spec, dict):
                raise ValueError(f"toolchain {platform}/{name} must be an object")
            missing = [field for field in fields if not isinstance(spec.get(field), str) or not spec[field]]
            if missing:
                raise ValueError(f"toolchain {platform}/{name} missing: {', '.join(missing)}")
            if not spec["url"].startswith("https://"):
                raise ValueError(f"toolchain {platform}/{name} URL must use HTTPS")
            if not re.fullmatch(r"[0-9a-f]{64}", spec["sha256"]):
                raise ValueError(f"toolchain {platform}/{name} SHA-256 is invalid")
            validate_relative_path(f"toolchain {platform}/{name} archive", spec["archive"])
            validate_relative_path(f"toolchain {platform}/{name} path", spec["path"])
    return data


def download(url: str, destination: Path, expected_sha256: str) -> None:
    if destination.is_file() and sha256(destination) == expected_sha256:
        print(f"verified archive: {destination}")
        return

    destination.parent.mkdir(parents=True, exist_ok=True)
    last_error: Exception | None = None
    for attempt in range(1, 4):
        with tempfile.NamedTemporaryFile(prefix=f".{destination.name}.", dir=destination.parent, delete=False) as stream:
            temporary = Path(stream.name)
        try:
            request = urllib.request.Request(url, headers={"User-Agent": "common-ci/1"})
            with urllib.request.urlopen(request, timeout=120) as response, temporary.open("wb") as output:
                shutil.copyfileobj(response, output)
            actual_sha256 = sha256(temporary)
            if actual_sha256 != expected_sha256:
                raise ValueError(f"checksum mismatch for {url}: {actual_sha256}")
            os.replace(temporary, destination)
            print(f"downloaded archive: {destination}")
            return
        except Exception as error:
            last_error = error
            temporary.unlink(missing_ok=True)
            if attempt < 3:
                time.sleep(attempt)
    raise RuntimeError(f"failed to download {url}: {last_error}")


def safe_extract(archive: Path, destination: Path) -> None:
    with tarfile.open(archive, "r:*") as bundle:
        for member in bundle.getmembers():
            member_path = PurePosixPath(member.name)
            if member_path.is_absolute() or ".." in member_path.parts:
                raise ValueError(f"unsafe archive member path: {member.name}")
            if member.ischr() or member.isblk() or member.isfifo():
                raise ValueError(f"unsupported archive member type: {member.name}")
            if member.issym() or member.islnk():
                link = PurePosixPath(member.linkname)
                target = member_path.parent / link if member.issym() else link
                normalized = PurePosixPath(posixpath.normpath(str(target)))
                if link.is_absolute() or normalized.is_absolute() or normalized.parts[:1] == ("..",):
                    raise ValueError(f"unsafe archive link: {member.name} -> {member.linkname}")
        bundle.extractall(destination)


def install(name: str, spec: dict[str, str], cache: Path) -> Path:
    archive = cache / "downloads" / spec["archive"]
    download(spec["url"], archive, spec["sha256"])

    destination = cache / "toolchains" / f"{name}-{spec['version']}"
    marker = destination / ".complete"
    installed_path = destination / spec["path"]
    if marker.is_file() and marker.read_text(encoding="utf-8").strip() == spec["sha256"] and installed_path.is_dir():
        return installed_path

    destination.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix=f".{destination.name}.", dir=destination.parent) as temporary:
        extracted = Path(temporary) / "content"
        extracted.mkdir()
        safe_extract(archive, extracted)
        if not (extracted / spec["path"]).is_dir():
            raise ValueError(f"toolchain archive does not contain {spec['path']}: {archive}")
        (extracted / ".complete").write_text(spec["sha256"] + "\n", encoding="utf-8")
        if destination.exists():
            shutil.rmtree(destination)
        os.replace(extracted, destination)
    return installed_path


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--lock", type=Path, default=Path("config/toolchains.lock.json"))
    parser.add_argument("--platform", default="ubuntu-22.04")
    parser.add_argument("--cache", type=Path)
    parser.add_argument("--tool", action="append")
    parser.add_argument("--github-path", type=Path)
    parser.add_argument("--validate", action="store_true")
    args = parser.parse_args()

    lock = load_lock(args.lock)
    if args.validate:
        print(f"valid toolchain lock: {args.lock}")
        return 0
    if args.cache is None or not args.tool:
        parser.error("--cache and at least one --tool are required unless --validate is used")

    try:
        available = lock["toolchains"][args.platform]
    except KeyError as error:
        raise SystemExit(f"unsupported toolchain platform: {args.platform}") from error

    paths: list[Path] = []
    for name in args.tool:
        try:
            spec = available[name]
        except KeyError as error:
            raise SystemExit(f"toolchain is not locked for {args.platform}: {name}") from error
        path = install(name, spec, args.cache.resolve())
        paths.append(path)
        print(f"{name} {spec['version']}: {path}")

    if args.github_path:
        args.github_path.parent.mkdir(parents=True, exist_ok=True)
        with args.github_path.open("a", encoding="utf-8") as stream:
            for path in paths:
                stream.write(f"{path.resolve()}\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
