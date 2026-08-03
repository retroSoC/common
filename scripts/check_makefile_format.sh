#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -eq 0 ]; then
  set -- Makefile
fi

temporary_dir=$(mktemp -d "${TMPDIR:-/tmp}/common-mbake.XXXXXX")
trap 'rm -rf "$temporary_dir"' EXIT

mbake_tool=${MBAKE:-mbake}
format_failed=0
for makefile in "$@"; do
  formatted_file="$temporary_dir/$makefile"
  mkdir -p "$(dirname "$formatted_file")"
  cp -- "$makefile" "$formatted_file"
  "$mbake_tool" format --config .bake.toml "$formatted_file" >/dev/null

  if ! cmp --silent "$makefile" "$formatted_file"; then
    printf 'Makefile source formatting required: %s\n' "$makefile" >&2
    diff --unified "$makefile" "$formatted_file" >&2 || true
    format_failed=1
  fi
done

exit "$format_failed"
