# Third-party Licenses

Most PULP platform common_cells-derived files are marked
`SPDX-License-Identifier: SHL-0.51` and retain the Solderpad Hardware License
notice. The authoritative SHL-0.51 text is available at
<http://solderpad.org/licenses/SHL-0.51>.

`rtl/base/signal_helpers.sv` is a PULP-derived exception. Its source header
names ETH Zurich, University of Bologna, EPFL, and OpenHW Group and declares
`SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1`; its exact header governs
that file.

`rtl/utils/regfield.sv` derives from lowRISC OpenTitan material, retains the
lowRISC contributors copyright notice, and declares
`SPDX-License-Identifier: Apache-2.0`.

Attribution, origin, and affected-file records are listed in the repository
[`NOTICE`](../NOTICE) file.

`pulp_common_cells_manifest.tsv` is the auditable source-to-component mapping
for imported design concepts. `make license-check` verifies that every
non-equivalent mapping retains a compatible SPDX notice and is listed in
`NOTICE`.

The repository-level [`LICENSE`](../LICENSE) remains Mulan PSL v2. Per-file
notices take precedence for material received under a compatible upstream
license.
