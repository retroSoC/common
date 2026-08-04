# Formal Checks

The formal targets use SymbiYosys with open-source Yosys and Bitwuzla. Most
targets use induction-based proof; `stream_queue.sby` is an explicit 32-step
bounded model check. Run all checked targets with `make formal`.

The checked properties include:

- FIFO bounds, round-robin arbitration safety, asynchronous request/acknowledge
  protocol safety, and stream replication behavior.
- SECDED encode/decode correctness for an arbitrary data word with no error or
  any single protected-bit error.
- PLRU victim one-hot validity under reset and legal replacement touches.
- Outstanding-window bounds, runtime limit behavior, and flush behavior.
- Stream-queue occupancy bounds and output stability across backpressure under
  the standard ready/valid source-stability assumption.
- A bounded, same-frequency warm-flush transaction: isolation rejects new
  traffic, pre-flush data is not released after recovery, and post-flush data
  transfers correctly.

Formal checks complement, rather than replace, the asynchronous simulation
tests. CDC metastability itself is not digitally provable and remains a
structural-review concern. The warm-flush proof models synchronized control
state and functional cancellation; it does not replace CDC structural signoff
or asynchronous-clock simulation.
