#!/usr/bin/env bash
set -euo pipefail

for tool_name in iverilog vvp verilator yosys sby mbake rg verible-verilog-format verible-verilog-lint; do
  if command -v "$tool_name" >/dev/null 2>&1; then
    printf 'found: %s (%s)\n' "$tool_name" "$(command -v "$tool_name")"
  else
    printf 'missing: %s\n' "$tool_name"
    exit 1
  fi
done
