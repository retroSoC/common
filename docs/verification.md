# Verification Matrix

The default regression is intentionally split by tool capability.

- `make test-iverilog` runs self-checking synthesizable RTL tests, including
  asynchronous mailbox/FIFO reset scenarios, flow-control edges, storage, and
  clock handover behavior. It also covers stream windows, PLRU, peak counters,
  SECDED fault injection, and warm-flush CDC recovery.
- `make test-verilator` runs the same RTL suite plus `axi_bfm_tb`. The latter
  uses SystemVerilog classes and virtual interfaces, which are not fully
  supported by Icarus.
- `make formal` proves queue and arbitration invariants, stream-replicator
  pending-mask behavior, SECDED single-fault correction, PLRU one-hot victim,
  and stream-window bounds. It also runs bounded mailbox and warm-flush CDC
  checks under representative synchronized-clock models.
- `make lint`, `make synth`, `make format-check`, `make mk-validate`, and
  `make license-check` remain required delivery gates.

CDC formal checks do not model analog metastability. The design relies on the
documented synchronizer stage requirements, structural CDC primitives, and
asynchronous-clock simulation for that implementation boundary.
