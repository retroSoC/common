# Design Contracts

Every component documents its reset and transfer contracts in the source.
Reset assertion may be asynchronous where `rst_n_i` is used; reset release is
synchronized only by the explicit reset/CDC components. Do not treat reset
signals as ordinary data CDC paths.

CDC components require independent source and destination resets to be held
long enough for their local synchronizer chains. The producer of an
`async_reqack` payload must keep valid data stable until it receives the
handshake acknowledgement; the module enforces this internally.

All queue depths that use binary pointer truncation must be powers of two. The
implementation fails fast during simulation when an unsupported parameter set
is instantiated. Storage contents are intentionally not reset; after reset the
queue state is empty and no unread memory value is observable.

The base `fifo` intentionally presents the head word combinationally. This
keeps the legacy zero-latency interface but prevents generic tools from
inferring a synchronous block RAM. Large queue users should use their
technology FIFO macro behind a documented compatible wrapper.

`axi4_addr_gen` supports FIXED, INCR, and legal AXI WRAP lengths (2, 4, 8, or
16 beats). A malformed WRAP length falls back to INCR behavior rather than
constructing an invalid bit mask. This primitive works on page offsets only and
does not substitute for a complete AXI protocol checker.
