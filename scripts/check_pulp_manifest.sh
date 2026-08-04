#!/usr/bin/env bash
set -euo pipefail

manifest_file="licenses/pulp_common_cells_manifest.tsv"
notice_file="NOTICE"

if [[ ! -f "$manifest_file" ]]; then
  printf 'missing PULP coverage manifest: %s\n' "$manifest_file" >&2
  exit 1
fi

failed=0
declare -A seen_sources
declare -A seen_files
while IFS=$'\t' read -r upstream_commit upstream_source status common_file common_component; do
  [[ -z "$upstream_commit" || "$upstream_commit" == \#* ]] && continue
  if [[ -z "$upstream_source" || -z "$status" || -z "$common_file" || -z "$common_component" ]]; then
    printf 'malformed PULP manifest entry: %s\n' "$upstream_source" >&2
    failed=1
    continue
  fi
  if [[ -n "${seen_sources[$upstream_source]:-}" ]]; then
    printf 'duplicate upstream source in PULP manifest: %s\n' "$upstream_source" >&2
    failed=1
  fi
  seen_sources[$upstream_source]=1
  if [[ ! -f "$common_file" ]]; then
    printf 'mapped common file does not exist: %s\n' "$common_file" >&2
    failed=1
    continue
  fi
  if [[ "$status" != "covered" && "$status" != "extended" && "$status" != "new" ]]; then
    printf 'invalid PULP manifest status for %s: %s\n' "$upstream_source" "$status" >&2
    failed=1
  fi
  if [[ "$status" != "covered" ]]; then
    seen_files[$common_file]=1
  fi
done < "$manifest_file"

for common_file in "${!seen_files[@]}"; do
  if ! head -n 40 "$common_file" | rg -q 'SPDX-License-Identifier: SHL-0.51|SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1'; then
    printf 'derived file lacks compatible upstream SPDX notice: %s\n' "$common_file" >&2
    failed=1
  fi
  if ! rg -F -q "$common_file" "$notice_file"; then
    printf 'derived file missing from NOTICE: %s\n' "$common_file" >&2
    failed=1
  fi
done

exit "$failed"
