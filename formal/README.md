# Formal Checks

The formal targets use SymbiYosys prove mode with open-source Yosys and
Bitwuzla. Run all checked targets with `make formal`.

The checked properties include:

- FIFO bounds, round-robin arbitration safety, asynchronous request/acknowledge
  protocol safety, and stream replication behavior.
- SECDED encode/decode correctness for an arbitrary data word with no error or
  any single protected-bit error.
- PLRU victim one-hot validity under reset and legal replacement touches.
- Outstanding-window bounds, runtime limit behavior, and flush behavior.
- A bounded, same-frequency warm-flush transaction: isolation rejects new
  traffic, pre-flush data is not released after recovery, and post-flush data
  transfers correctly.

Formal checks complement, rather than replace, the asynchronous simulation
tests. CDC metastability itself is not digitally provable and remains a
structural-review concern. The warm-flush proof models synchronized control
state and functional cancellation; it does not replace CDC structural signoff
or asynchronous-clock simulation.
