# Verification Matrix

The default regression is intentionally split by tool capability.

- `make test-iverilog` runs self-checking synthesizable RTL tests, including
  asynchronous mailbox/FIFO reset scenarios, flow-control edges, storage, and
  clock handover behavior.
- `make test-verilator` runs the same RTL suite plus `axi_bfm_tb`. The latter
  uses SystemVerilog classes and virtual interfaces, which are not fully
  supported by Icarus.
- `make formal` proves queue and arbitration invariants and stream-replicator
  pending-mask behavior; it also runs a bounded mailbox no-duplicate check
  under a representative synchronized-clock model.
- `make lint`, `make synth`, `make format-check`, `make mk-validate`, and
  `make license-check` remain required delivery gates.

CDC formal checks do not model analog metastability. The design relies on the
documented synchronizer stage requirements, structural CDC primitives, and
asynchronous-clock simulation for that implementation boundary.
