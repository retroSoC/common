#!/usr/bin/env bash
set -euo pipefail

python3 scripts/render_component_docs.py --check

for page in docs/reference/*/*.md; do
  unit_name=$(basename "${page%.md}")
  for heading in "## Summary" "## Functional Behavior" "## Suitable Applications" \
                 "## Parameters" "## Interface Definition" "## Integration and Use" \
                 "## Dependencies and Verification"; do
    rg -Fqx "$heading" "$page" >/dev/null || {
      printf 'missing required heading %s in %s\n' "$heading" "$page" >&2
      exit 1
    }
  done
  rg -Fqx "# ${unit_name}" "$page" >/dev/null || {
    printf 'unexpected page title in %s\n' "$page" >&2
    exit 1
  }
  rg -F '```systemverilog' "$page" >/dev/null || {
    printf 'missing SystemVerilog content in %s\n' "$page" >&2
    exit 1
  }
done
