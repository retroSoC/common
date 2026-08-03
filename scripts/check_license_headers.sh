#!/usr/bin/env bash
set -euo pipefail

header_lines=40

if [ "$#" -eq 0 ]; then
  printf 'usage: %s <systemverilog-source>...\n' "$0" >&2
  exit 2
fi

check_failed=0
for source_file in "$@"; do
  if ! awk -v max_lines="$header_lines" '
    FNR > max_lines {
      exit
    }
    /^[[:space:]]*(module|interface|package|class|program|checker)[[:space:]]/ {
      exit
    }
    {
      header_line = tolower($0)
      if (header_line ~ /spdx-license-identifier:|solderpad hardware license|apache license|mulan psl v2|mit license/) {
        found_license = 1
      }
    }
    END {
      exit(found_license ? 0 : 1)
    }
  ' "$source_file"; then
    printf 'missing license header in first %d lines: %s\n' "$header_lines" "$source_file" >&2
    check_failed=1
  fi
done

exit "$check_failed"
