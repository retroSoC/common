# Verification Matrix

The default regression is intentionally split by tool capability.

- `make test-iverilog` runs self-checking synthesizable RTL tests, including
  asynchronous mailbox/FIFO reset scenarios, flow-control edges, storage, and
  clock handover behavior. It also covers stream windows, PLRU, peak counters,
  SECDED fault injection, and warm-flush CDC recovery.
- The extended regressions cover queue fall-through/full behavior, latest-value
  overwrite semantics, crossbar lock/fair handoff, tagged FIFO order, circular
  storage bounds, mask/control filters, Bloom insertion/removal, four-phase
  event delivery, and clearable CDC recovery.
- `make test-verilator` runs the same RTL suite plus `axi_bfm_tb`. The latter
  uses SystemVerilog classes and virtual interfaces, which are not fully
  supported by Icarus.
- `make formal` proves arbitration invariants, stream-replicator pending-mask
  behavior, SECDED single-fault correction, PLRU one-hot victim, and
  stream-window bounds. It also runs 32-step bounded checks for the stream
  queue, mailbox, and warm-flush CDC under representative synchronized-clock
  models.
- `make lint`, `make synth`, `make format-check`, `make mk-validate`, and
  `make license-check` remain required delivery gates.
- `make license-check` also validates the PULP source-to-component manifest,
  per-file SPDX markers, and NOTICE entries.

CDC formal checks do not model analog metastability. The design relies on the
documented synchronizer stage requirements, structural CDC primitives, and
asynchronous-clock simulation for that implementation boundary.
