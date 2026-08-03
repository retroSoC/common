#!/usr/bin/env bash
set -euo pipefail
find rtl/base rtl/bus rtl/cdc rtl/clock rtl/interface rtl/memory rtl/stream rtl/tech rtl/utils rtl/clkrst -name '*.sv' -type f | sort
