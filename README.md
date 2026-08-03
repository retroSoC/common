# common RTL foundation

`common` is a self-contained SystemVerilog component layer for SoC IP. It
provides clock/reset, CDC, stream, storage, address, register, and technology
model primitives without requiring a parent SoC repository.

The preferred public directories are `rtl/base`, `rtl/stream`, `rtl/bus`,
`rtl/clock`, `rtl/cdc`, and `rtl/memory`. Existing interfaces remain at their
legacy paths for current users in the IP workspace.

## Quick start

```sh
make doctor
make license-check
make format-check
make test-iverilog
make test-verilator
make synth
make formal
```

`flist/rtl.f` is the ordered synthesis/simulation source list. Unit tests are
self-checking and write only below `build/`. `format-check` validates all
tracked SystemVerilog sources with Verible and tracked Makefile sources with
`mbake` using `.bake.toml`. See
`docs/components.md` for the public catalog, `docs/design.md` for contracts,
and `AGENTS.md` for contribution rules.

`license-check` requires every tracked SystemVerilog source to carry an SPDX
identifier or an upstream license notice in its first 40 lines.

The repository is licensed under Mulan PSL v2 unless an individual source file
states another compatible upstream license. Third-party attributions and license
notices are recorded in `NOTICE` and `licenses/`.
