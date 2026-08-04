#!/usr/bin/env bash
set -euo pipefail

failed=0

require_literal() {
  local file=$1
  local text=$2
  if ! rg -F -q "$text" "$file"; then
    printf 'missing third-party notice %q in %s\n' "$text" "$file" >&2
    failed=1
  fi
}

require_literal README.md "## Third-Party Notices"
require_literal README.md "PULP platform common_cells"
require_literal README.md "ETH Zurich and University of Bologna"
require_literal README.md "SHL-0.51"
require_literal README.md "Apache-2.0 WITH SHL-2.1"
require_literal README.md "EPFL, and OpenHW Group"
require_literal README.md "lowRISC OpenTitan"
require_literal README.md "Apache-2.0"
require_literal README.md "licenses/pulp_common_cells_manifest.tsv"

require_literal NOTICE "PULP platform common_cells material under SHL-0.51"
require_literal NOTICE "PULP platform common_cells signal helper material"
require_literal NOTICE "SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1"
require_literal NOTICE "Copyright: lowRISC contributors"
require_literal NOTICE "SPDX-License-Identifier: Apache-2.0"

require_literal licenses/README.md "SPDX-License-Identifier: SHL-0.51"
require_literal licenses/README.md "SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1"
require_literal licenses/README.md "SPDX-License-Identifier: Apache-2.0"

exit "$failed"
