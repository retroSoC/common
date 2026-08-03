# Component Catalog

## Base and stream

- `bit_count`, `leading_zero_count`, `onehot_check`, and `onehot_to_index` are
  combinational bit primitives.
- `round_robin_arbiter` provides fair, transfer-driven arbitration.
- `bypass_buffer`, `stream_buffer`, `stream_selector`, `stream_router`,
  `stream_replicator`, `stream_collector`, and `stream_credit_limiter` use a
  conventional valid/ready transfer. A transfer occurs only when both signals
  are high in the same cycle.
- `fifo` and its legacy `stream_fifo` wrapper are power-of-two synchronous
  queues. A full queue may push and pop on the same edge. Their asynchronous
  read contract maps to registers in generic Yosys synthesis; use a technology
  FIFO macro or a registered-read wrapper for large storage.

## CDC and reset

- `cdc_sync` is for control bits or independently encoded vectors only.
- `async_reqack` is a one-entry four-phase data mailbox.
- `cdc_fifo` and `async_gray_queue` are Gray-pointer queues and require a
  power-of-two depth of at least two.
- `cdc_reset_barrier` asynchronously asserts reset and synchronizes release in
  its two supplied clock domains.

## Clock, address, and memory

- `clock_divider` changes configuration only at an output-low boundary.
- `safe_clock_mux` changes enables on falling edges to avoid truncating high
  pulses; both clocks must be running when selection changes.
- `address_region` and `address_map` use masked comparisons. Map ordering is
  deterministic: the lowest matching index wins.
- `axi4_addr_gen` calculates the next address within a 4 KiB AXI page. The
  caller owns 4 KiB burst validation.
- `sync_memory` has positive-logic controls. `tech_ram*` and `tech_regfile*`
  retain their historical active-low controls and are deterministic models.
