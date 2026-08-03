#!/usr/bin/env bash
set -euo pipefail

formatter=${VERIBLE_FORMAT:-verible-verilog-format}

for source_file in "$@"; do
  "$formatter" --flagfile=.verible-format --failsafe_success=false --verify "$source_file"
done
