# common Contribution Rules

`common` is a self-contained RTL foundation layer. A component under `rtl/`
may depend only on another component in this repository, never on a technology
library, SoC repository, or verification package outside this tree.

## Layout

- `rtl/base`, `rtl/stream`, `rtl/bus`, `rtl/clock`, `rtl/cdc`, and `rtl/memory`
  contain the preferred public components.
- `rtl/utils`, `rtl/clkrst`, `rtl/tech`, and `rtl/interface` retain compatible
  interfaces for existing IP. Do not remove or rename these paths without a
  release-note migration plan.
- `docs/reference` contains one generated, checked-in Markdown page for every
  declared RTL `module`, `interface`, and `package`. Update its renderer and
  regenerate the pages whenever a public declaration or its contract changes.
- `dv/unit` contains self-checking simulation tests. `formal` contains bounded
  property checks. Generated artifacts belong under `build/` only.

## RTL Rules

- Use `logic`, `always_comb`, and `always_ff`; give every sequential block an
  explicit reset policy.
- Parameter ranges are contracts. Reject invalid geometry or protocol settings
  with an `initial $fatal` where elaboration cannot enforce them.
- Handshake components use `*_valid_i`/`*_ready_o` and must define flush,
  simultaneous transfer, and reset behavior.
- Multi-bit CDC must use a handshake or asynchronous queue. `cdc_sync` is only
  for independently encoded controls.
- New RTL should be built structurally from existing common primitives whenever
  that does not weaken timing or CDC correctness.

## Required Checks

Run the following before submitting a change:

```sh
make format-check
make mk-validate
make docs-check
make license-check
make lint
make test-iverilog
make test-verilator
make synth
make formal
```

Use `make doctor` to verify local tools. `mbake` version 1.4.6 or newer applies
the project Makefile policy in `.bake.toml`. Do not commit `build/`, waves, or
tool-generated netlists. Format only tracked project SystemVerilog and Makefile
sources. Every tracked SystemVerilog file must declare an SPDX identifier or a
recognized upstream license in its first 40 lines; run `make license-check` to
enforce the policy.

`make test-verilator` also runs the class-based AXI BFM regression. Icarus
does not fully implement SystemVerilog class and virtual-interface semantics,
so the BFM test is deliberately Verilator-only; synthesizable RTL remains in
both simulator regressions.

## Third-party Material

PULP common_cells-inspired or derived code must keep the original copyright,
Solderpad Hardware License notice, SPDX tag, and an entry in `NOTICE`. Do not
reuse upstream `cc_*` component names or identifiers. Code derived from other
projects follows the same rule and must be recorded in `NOTICE`.

When third-party provenance or licensing changes, update `README.md`,
`NOTICE`, and `licenses/README.md` together. Preserve the exact source-file
SPDX identifier, including exceptions such as `Apache-2.0 WITH SHL-2.1`, and
run `make license-check` to validate public notices as well as source headers.

The active PULP source coverage is recorded in
`licenses/pulp_common_cells_manifest.tsv`. When adding or changing a mapped
component, update that manifest and run `scripts/check_pulp_manifest.sh` via
`make license-check`; do not add upstream deprecated compatibility wrappers.
