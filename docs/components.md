# Component Catalog

## Base and stream

- `bit_count`, `leading_zero_count`, `onehot_check`, and `onehot_to_index` are
  combinational bit primitives.
- `plru_victim_selector` is a power-of-two cache-way replacement tree. It
  accepts zero or one-hot touches and emits a deterministic one-hot victim.
- `secded_encode` and `secded_decode` implement parameterized extended-Hamming
  SECDED. A codeword single-bit fault is corrected, an overall-parity-bit fault
  is reported without changing data, and a double-bit fault is uncorrectable.
- `round_robin_arbiter` provides fair, transfer-driven arbitration.
- `bypass_buffer`, `stream_buffer`, `stream_selector`, `stream_router`,
  `stream_replicator`, `stream_collector`, and `stream_credit_limiter` use a
  conventional valid/ready transfer. A transfer occurs only when both signals
  are high in the same cycle. `stream_replicator` retains one accepted payload
  and target mask, so enabled outputs may complete in different cycles but
  each receives exactly one transfer. Its input is backpressured until all
  selected targets complete; `flush_i` cancels the retained item.
- `stream_discard_gate` consumes an input without presenting it downstream
  while `discard_i` is high. `stream_window_guard` limits in-flight requests;
  `retire_i` must represent a completion for a previously accepted request.
  Its runtime limit is clamped to the elaborated maximum.
- `peak_delta_counter` combines a programmable up/down counter with a separate
  high-water mark. It records the updated count on the same edge as an enabled
  increment, load, or decrement.
- `fifo` and its legacy `stream_fifo` wrapper are power-of-two synchronous
  queues. A full queue may push and pop on the same edge. Their asynchronous
  read contract maps to registers in generic Yosys synthesis; use a technology
  FIFO macro or a registered-read wrapper for large storage.
- `prefix_ones_mask`, `interval_ones_mask`, `trailing_zero_count`, and
  `index_to_onehot` complete the common combinational mask/index toolbox.
  `credit_pool`, `loop_trip_counter`, `retry_backoff`,
  `stable_level_filter`, and `sample_majority_filter` are control-plane
  primitives. `counting_bloom_filter` is non-cryptographic and may report
  false positives; counter saturation is explicit through `saturated_o`.
- `stream_elastic_register` is a one-entry elastic stage; `stream_queue` is an
  arbitrary-depth queue with optional fall-through; `latest_value_stream`
  accepts a valid-only source and retains the newest pending value. The stream
  fabric adds `stream_fair_arbiter`, `stream_crossbar`,
  `stream_shuffle_network`, and `memory_response_bridge`.
- `tag_order_queue` preserves FIFO order within each tag, `circular_store`
  offers sequential writes with bounded random reads, and
  `memory_bank_adapter_detail` splits a single request over banks while
  gathering one response from each bank.

## CDC and reset

- `cdc_sync` is for control bits or independently encoded vectors only.
- `async_reqack` is a one-entry four-phase data mailbox. It suppresses valid
  after destination acceptance, preventing duplicate delivery while request
  return-to-zero is in progress.
- `cdc_fifo` and `async_gray_queue` are Gray-pointer queues and require a
  power-of-two depth of at least two. `async_reqack`, `cdc_2phase`, and these
  queues abort in-flight transactions when either endpoint resets.
- `cdc_reset_barrier` asynchronously asserts reset and synchronizes release in
  its two supplied clock domains.
- `cdc_2phase_warm_flush` and `cdc_fifo_warm_flush` add a source-initiated,
  acknowledged warm-clear sequence around the existing CDC cells. They isolate
  both interfaces before resetting state, abort in-flight data, and expose busy
  outputs until recovery completes.
- `four_phase_mailbox` and `cdc_event_bridge` expose data and event forms of
  the existing four-phase mailbox. `clearable_two_phase_link` and
  `clearable_async_queue` accept a clear from either endpoint and treat it as
  an abort. A destination-side clear is retained by a four-phase request
  mailbox before the source-side coordinated flush begins, so a short pulse is
  not silently lost. `isochronous_handshake` and `isochronous_stream_buffer`
  require a fixed STA-constrained clock relationship and are not general CDC
  cells.

## Clock, address, and memory

- `clock_divider` changes configuration only at an output-low boundary.
- `safe_clock_mux` synchronizes an ordered selection request and remote enable
  observations before changing enables on falling edges. Both clocks must keep
  running, and selection must remain stable until handover completes.
- `clock_divider` and `clk_int_div_simple` accept new configuration only at a
  safe output-low boundary. `clk_int_even_div` retains a request received while
  high and commits the latest request at the next safe boundary.
- `address_region` and `address_map` use masked comparisons. Map ordering is
  deterministic: the lowest matching index wins.
- `axi4_addr_gen` calculates the next address within a 4 KiB AXI page. The
  caller owns 4 KiB burst validation.
- `sync_memory` has positive-logic controls. `tech_ram*` and `tech_regfile*`
  retain their historical active-low controls and are deterministic models.
  Their simulation models reject active out-of-range addresses, including for
  non-power-of-two depths; this check is excluded from synthesis.
- `clock_or_tree` combines already-safe gated clocks only. `ready_valid_if`
  is an optional monitor/source/sink interface; component RTL continues to use
  explicit ports for Icarus and Verilator compatibility.
