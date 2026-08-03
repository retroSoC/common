# Design Contracts

Every component documents its reset and transfer contracts in the source.
Reset assertion may be asynchronous where `rst_n_i` is used; reset release is
synchronized only by the explicit reset/CDC components. Do not treat reset
signals as ordinary data CDC paths.

CDC components require source and destination resets to be held long enough
for their local synchronizer chains. `async_reqack`, `cdc_2phase`, and
`cdc_fifo` treat reset of either endpoint as a link flush: an in-flight item
is discarded and is not guaranteed to reach the other side. Both source clocks
must run after reset release for their local link resets to deassert.

The source of an `async_reqack` transfer need only hold data stable through its
own valid/ready handshake. The mailbox stores that data internally until the
destination accepts it exactly once; it then completes the four-phase return
to zero without reasserting destination valid.

All queue depths that use binary pointer truncation must be powers of two. The
implementation fails fast during simulation when an unsupported parameter set
is instantiated. Storage contents are intentionally not reset; after reset the
queue state is empty and no unread memory value is observable.

The base `fifo` intentionally presents the head word combinationally. This
keeps the legacy zero-latency interface but prevents generic tools from
inferring a synchronous block RAM. Large queue users should use their
technology FIFO macro behind a documented compatible wrapper.

`stream_replicator` is a registered, one-item distributor. It samples payload
and `enable_i` on the input handshake, then delivers that item exactly once to
each enabled target as targets become ready. `flush_i` cancels a retained item.
This semantics requires its `clk_i`, `rst_n_i`, and `flush_i` ports; callers of
the former combinational broadcaster must migrate to the registered interface.

`axi4_addr_gen` supports FIXED, INCR, and legal AXI WRAP lengths (2, 4, 8, or
16 beats). A malformed WRAP length falls back to INCR behavior rather than
constructing an invalid bit mask. This primitive works on page offsets only and
does not substitute for a complete AXI protocol checker.
