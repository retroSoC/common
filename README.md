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
make docs-check
make test-iverilog
make test-verilator
make synth
make formal
```

`flist/rtl.f` is the ordered synthesis/simulation source list. Unit tests are
self-checking and write only below `build/`. `format-check` validates all
tracked SystemVerilog sources with Verible and tracked Makefile sources with
`mbake` using `.bake.toml`. `docs-check` verifies that every declared RTL unit
has a maintained reference page. See `docs/reference/` for the full catalog,
`docs/design.md` for contracts, and `AGENTS.md` for contribution rules.

`license-check` requires every tracked SystemVerilog source to carry an SPDX
identifier or an upstream license notice in its first 40 lines.

## Register Primitives

`rtl/utils/register.sv` keeps the existing module names as a compatibility
surface. Select the primitive by clock edge, reset style, reset value, and
enable requirement:

| Primitive family | Clock edge | Reset | Enable |
| --- | --- | --- | --- |
| `dff` | rising | none | no |
| `dffl` | rising | none | yes |
| `dffr`, `dffer` | rising | asynchronous active-low, zero | no / yes |
| `dffrh`, `dfferh` | rising | asynchronous active-low, all ones | no / yes |
| `dffrc`, `dfferc` | rising | asynchronous active-low, configurable | no / yes |
| `dffsr`, `dffesr` | rising | synchronous active-low, zero | no / yes |
| `dffsrc`, `dffesrc` | rising | synchronous active-low, configurable | no / yes |
| `ndffr`, `ndffer` | falling | asynchronous active-low, zero | no / yes |
| `dfferm` | rising | asynchronous active-low, per-array policy | per element |

Reset has priority over enable. A low enable holds the previous value. The
`dffercn` type-parameterized asynchronous-reset variant remains for existing
users; new fixed-width code should prefer `dfferc`. Register enable expresses
data retention semantics. It does not guarantee clock-gate insertion; use the
Common `clk_icg`/technology ICG wrapper at module level when clock gating is
required and verify the mapped gate-level netlist.

The repository is licensed under Mulan PSL v2 unless an individual source file
states another compatible upstream license. Third-party attributions and license
notices are recorded in `NOTICE` and `licenses/`.

## Third-Party Notices

The repository-level [Mulan PSL v2 license](LICENSE) applies unless an
individual source file declares a compatible upstream license. Per-file
copyright and SPDX notices take precedence. The following table is a concise
attribution guide; [`NOTICE`](NOTICE),
[`licenses/README.md`](licenses/README.md), and source headers are the
authoritative records.

| Material | Copyright and license | Affected scope and authoritative record |
| --- | --- | --- |
| [PULP platform common_cells](https://github.com/pulp-platform/common_cells) | ETH Zurich and University of Bologna; individual source notices identify additional authors. `SHL-0.51`. | PULP-derived RTL carrying that SPDX identifier. The complete source-to-component mapping and reference snapshot are in [`licenses/pulp_common_cells_manifest.tsv`](licenses/pulp_common_cells_manifest.tsv) and [`NOTICE`](NOTICE). |
| PULP common_cells signal helpers | ETH Zurich, University of Bologna, EPFL, and OpenHW Group. `Apache-2.0 WITH SHL-2.1`. | [`rtl/base/signal_helpers.sv`](rtl/base/signal_helpers.sv), derived from PULP `cc_read` and `cc_unread`; see its exact source header and [`NOTICE`](NOTICE). |
| [lowRISC OpenTitan](https://github.com/lowRISC/opentitan) register field material | lowRISC contributors. `Apache-2.0`. | [`rtl/utils/regfield.sv`](rtl/utils/regfield.sv); see [`NOTICE`](NOTICE). |

<!-- COMPONENT_REFERENCE:START -->

## Component Reference

Each declared RTL unit has a detailed integration page. The catalog is generated from `rtl/`; use the linked page for parameters, complete interfaces, reset/CDC constraints, and an instantiation example.

### `base`

| Component | Type | Function summary |
| --- | --- | --- |
| [`bit_count`](docs/reference/base/bit_count.md) | `module` | Combinational population-count primitive. |
| [`component_math_pkg`](docs/reference/base/component_math_pkg.md) | `package` | Compile-time arithmetic helpers for parameterized components. |
| [`counting_bloom_filter`](docs/reference/base/counting_bloom_filter.md) | `module` | Counting Bloom filter with explicit counter saturation. |
| [`credit_pool`](docs/reference/base/credit_pool.md) | `module` | Saturating available-credit tracker for resource flow control. |
| [`hash_indicator_bank`](docs/reference/base/hash_indicator_bank.md) | `module` | Multi-hash indicator-vector generator. |
| [`index_to_onehot`](docs/reference/base/index_to_onehot.md) | `module` | Bounded index-to-one-hot decoder. |
| [`interval_ones_mask`](docs/reference/base/interval_ones_mask.md) | `module` | Inclusive contiguous mask generator between two bit positions. |
| [`leading_zero_count`](docs/reference/base/leading_zero_count.md) | `module` | Combinational leading-zero counter with all-zero indication. |
| [`loop_trip_counter`](docs/reference/base/loop_trip_counter.md) | `module` | Programmable terminal-count loop counter. |
| [`onehot_check`](docs/reference/base/onehot_check.md) | `module` | One-hot validity checker with optional all-zero acceptance. |
| [`onehot_to_index`](docs/reference/base/onehot_to_index.md) | `module` | One-hot vector to index converter with validity output. |
| [`permutation_hash`](docs/reference/base/permutation_hash.md) | `module` | Deterministic non-cryptographic bit-mixing hash. |
| [`plru_victim_selector`](docs/reference/base/plru_victim_selector.md) | `module` | Power-of-two pseudo-LRU cache-way victim selector. |
| [`prefix_ones_mask`](docs/reference/base/prefix_ones_mask.md) | `module` | Low-order prefix-ones mask generator. |
| [`retry_backoff`](docs/reference/base/retry_backoff.md) | `module` | Pseudo-random exponential retry-delay controller. |
| [`sample_majority_filter`](docs/reference/base/sample_majority_filter.md) | `module` | Sliding-window N-of-M single-bit sample filter. |
| [`secded_decode`](docs/reference/base/secded_decode.md) | `module` | Extended-Hamming SECDED decoder, corrector, and error classifier. |
| [`secded_encode`](docs/reference/base/secded_encode.md) | `module` | Extended-Hamming SECDED encoder. |
| [`secded_layout_pkg`](docs/reference/base/secded_layout_pkg.md) | `package` | Shared SECDED codeword-layout helpers. |
| [`signal_sink`](docs/reference/base/signal_sink.md) | `module` | Intentional unused-signal terminator. |
| [`signal_tap`](docs/reference/base/signal_tap.md) | `module` | Named combinational signal pass-through for observability. |
| [`stable_level_filter`](docs/reference/base/stable_level_filter.md) | `module` | Consecutive-sample debounce and stability filter. |
| [`trailing_zero_count`](docs/reference/base/trailing_zero_count.md) | `module` | Combinational trailing-zero counter with all-zero indication. |

### `bus`

| Component | Type | Function summary |
| --- | --- | --- |
| [`address_map`](docs/reference/bus/address_map.md) | `module` | Masked address-map decoder with deterministic lowest-index priority. |
| [`address_range_decoder`](docs/reference/bus/address_range_decoder.md) | `module` | Inclusive address-range decoder. |
| [`address_region`](docs/reference/bus/address_region.md) | `module` | Masked address-region matcher. |
| [`address_set_decoder`](docs/reference/bus/address_set_decoder.md) | `module` | Decoder for a set of independently configured address regions. |
| [`axi4_regslice`](docs/reference/bus/axi4_regslice.md) | `module` | Elastic register slice for all five AXI4 channels. |

### `cdc`

| Component | Type | Function summary |
| --- | --- | --- |
| [`async_gray_queue`](docs/reference/cdc/async_gray_queue.md) | `module` | Gray-pointer asynchronous FIFO wrapper. |
| [`async_reqack`](docs/reference/cdc/async_reqack.md) | `module` | One-entry four-phase asynchronous data mailbox. |
| [`cdc_2phase`](docs/reference/cdc/cdc_2phase.md) | `module` | Two-phase asynchronous request/acknowledge transfer. |
| [`cdc_2phase_dst`](docs/reference/cdc/cdc_2phase_dst.md) | `module` | Destination-side implementation of the two-phase CDC link. |
| [`cdc_2phase_src`](docs/reference/cdc/cdc_2phase_src.md) | `module` | Source-side implementation of the two-phase CDC link. |
| [`cdc_2phase_warm_flush`](docs/reference/cdc/cdc_2phase_warm_flush.md) | `module` | Source-initiated warm-clear wrapper for a two-phase CDC link. |
| [`cdc_event_bridge`](docs/reference/cdc/cdc_event_bridge.md) | `module` | Pulse/event transport over an asynchronous mailbox. |
| [`cdc_event_bridge_ack`](docs/reference/cdc/cdc_event_bridge_ack.md) | `module` | Acknowledged asynchronous event transport. |
| [`cdc_fifo`](docs/reference/cdc/cdc_fifo.md) | `module` | Gray-pointer asynchronous FIFO. |
| [`cdc_fifo_dst`](docs/reference/cdc/cdc_fifo_dst.md) | `module` | Destination-side implementation of the asynchronous FIFO. |
| [`cdc_fifo_src`](docs/reference/cdc/cdc_fifo_src.md) | `module` | Source-side implementation of the asynchronous FIFO. |
| [`cdc_fifo_warm_flush`](docs/reference/cdc/cdc_fifo_warm_flush.md) | `module` | Source-initiated warm-clear wrapper for an asynchronous FIFO. |
| [`cdc_remote_clear_request`](docs/reference/cdc/cdc_remote_clear_request.md) | `module` | Retained remote-clear request channel. |
| [`cdc_reset_barrier`](docs/reference/cdc/cdc_reset_barrier.md) | `module` | Two-domain reset barrier with synchronized release. |
| [`cdc_sync`](docs/reference/cdc/cdc_sync.md) | `module` | Multi-flop synchronizer for a control bit or independently encoded vector. |
| [`cdc_sync_det`](docs/reference/cdc/cdc_sync_det.md) | `module` | Synchronized control input with edge detection. |
| [`cdc_warm_flush_controller`](docs/reference/cdc/cdc_warm_flush_controller.md) | `module` | Acknowledged isolate-reset-resume controller for CDC warm flush. |
| [`clearable_async_queue`](docs/reference/cdc/clearable_async_queue.md) | `module` | Asynchronous queue with coordinated endpoint clear. |
| [`clearable_two_phase_link`](docs/reference/cdc/clearable_two_phase_link.md) | `module` | Two-phase link with coordinated endpoint clear. |
| [`four_phase_mailbox`](docs/reference/cdc/four_phase_mailbox.md) | `module` | Public wrapper for the four-phase asynchronous mailbox API. |
| [`isochronous_handshake`](docs/reference/cdc/isochronous_handshake.md) | `module` | Handshake for fixed-ratio, STA-constrained isochronous clocks. |
| [`isochronous_stream_buffer`](docs/reference/cdc/isochronous_stream_buffer.md) | `module` | Stream buffer for fixed-ratio, STA-constrained isochronous clocks. |
| [`synchronized_edge`](docs/reference/cdc/synchronized_edge.md) | `module` | Synchronizes a control transition and emits a local edge indication. |
| [`test_reset_synchronizer`](docs/reference/cdc/test_reset_synchronizer.md) | `module` | Verification-oriented reset synchronization helper. |
| [`two_phase_async_queue`](docs/reference/cdc/two_phase_async_queue.md) | `module` | Queue API built from two-phase asynchronous transfers. |

### `clkrst`

| Component | Type | Function summary |
| --- | --- | --- |
| [`clk_int_div_simple`](docs/reference/clkrst/clk_int_div_simple.md) | `module` | Runtime-programmable integer divider with safe low-phase updates. |
| [`clk_int_even_div`](docs/reference/clkrst/clk_int_even_div.md) | `module` | Even clock divider retaining requests until a safe boundary. |
| [`clk_int_even_div_static`](docs/reference/clkrst/clk_int_even_div_static.md) | `module` | Static even integer clock divider. |
| [`clk_int_odd_div_static`](docs/reference/clkrst/clk_int_odd_div_static.md) | `module` | Static odd integer clock divider. |
| [`peak_delta_counter`](docs/reference/clkrst/peak_delta_counter.md) | `module` | Up/down counter with retained high-water mark. |
| [`rs_counter`](docs/reference/clkrst/rs_counter.md) | `module` | Resettable up/down counter. |
| [`rs_delta_counter`](docs/reference/clkrst/rs_delta_counter.md) | `module` | Delta-counting counter. |
| [`rst_sync`](docs/reference/clkrst/rst_sync.md) | `module` | Asynchronous-assert, synchronous-release reset synchronizer. |

### `clock`

| Component | Type | Function summary |
| --- | --- | --- |
| [`clock_divider`](docs/reference/clock/clock_divider.md) | `module` | Runtime-programmable divider that changes only at an output-low boundary. |
| [`clock_or_tree`](docs/reference/clock/clock_or_tree.md) | `module` | OR tree for clocks already proven safe to combine. |
| [`safe_clock_mux`](docs/reference/clock/safe_clock_mux.md) | `module` | Glitch-safe handover mux for two continuously running clocks. |

### `interface`

| Component | Type | Function summary |
| --- | --- | --- |
| [`ahbl_if`](docs/reference/interface/ahbl_if.md) | `interface` | Typed AHB-Lite interface with master and slave modports. |
| [`apb4_if`](docs/reference/interface/apb4_if.md) | `interface` | Clocked APB4 interface with master and slave modports. |
| [`apb4_pure_if`](docs/reference/interface/apb4_pure_if.md) | `interface` | Clockless APB4 signal interface with master and slave modports. |
| [`axi4_addr_gen`](docs/reference/interface/axi4_addr_gen.md) | `module` | AXI4 next-address generator for FIXED, INCR, and legal WRAP bursts. |
| [`axi4_if`](docs/reference/interface/axi4_if.md) | `interface` | Typed AXI4 interface with master and slave modports. |
| [`axi4_stream_if`](docs/reference/interface/axi4_stream_if.md) | `interface` | Typed AXI4-Stream interface with source, sink, and monitor modports. |
| [`ram_if`](docs/reference/interface/ram_if.md) | `interface` | Simple RAM request/response interface with master and slave modports. |
| [`ready_valid_if`](docs/reference/interface/ready_valid_if.md) | `interface` | Typed ready/valid interface with source, sink, and monitor modports. |
| [`ribp_if`](docs/reference/interface/ribp_if.md) | `interface` | RIBP request/response interface with response-error signaling. |

### `memory`

| Component | Type | Function summary |
| --- | --- | --- |
| [`circular_store`](docs/reference/memory/circular_store.md) | `module` | Sequential circular store with bounded random reads. |
| [`memory_bank_adapter`](docs/reference/memory/memory_bank_adapter.md) | `module` | Public banked-memory request and response adapter. |
| [`memory_bank_adapter_detail`](docs/reference/memory/memory_bank_adapter_detail.md) | `module` | Banked-memory request splitter and response gatherer. |
| [`sync_memory`](docs/reference/memory/sync_memory.md) | `module` | Portable synchronous memory model with positive-logic controls. |
| [`tag_order_queue`](docs/reference/memory/tag_order_queue.md) | `module` | Shared-pool queue preserving FIFO order within each tag. |

### `model`

| Component | Type | Function summary |
| --- | --- | --- |
| [`apb4_master_model`](docs/reference/model/apb4_master_model.md) | `module` | Simulation APB4 master model. |

### `stream`

| Component | Type | Function summary |
| --- | --- | --- |
| [`axi4_stream_regslice`](docs/reference/stream/axi4_stream_regslice.md) | `module` | Elastic AXI4-Stream register slice. |
| [`bypass_buffer`](docs/reference/stream/bypass_buffer.md) | `module` | Combinational valid/ready stream pass-through. |
| [`latest_value_stream`](docs/reference/stream/latest_value_stream.md) | `module` | Valid-only stream adapter retaining the newest pending value. |
| [`memory_response_bridge`](docs/reference/stream/memory_response_bridge.md) | `module` | Response-order bridge between memory and stream interfaces. |
| [`round_robin_arbiter`](docs/reference/stream/round_robin_arbiter.md) | `module` | Fair transfer-driven round-robin arbiter. |
| [`stream_buffer`](docs/reference/stream/stream_buffer.md) | `module` | Valid/ready stream wrapper around a spill register. |
| [`stream_collector`](docs/reference/stream/stream_collector.md) | `module` | Collects selected valid/ready inputs into one stream output. |
| [`stream_credit_limiter`](docs/reference/stream/stream_credit_limiter.md) | `module` | Limits stream acceptance by available credits. |
| [`stream_crossbar`](docs/reference/stream/stream_crossbar.md) | `module` | Arbitrates and routes multiple stream inputs to multiple outputs. |
| [`stream_delay_injector`](docs/reference/stream/stream_delay_injector.md) | `module` | Controlled stream delay injector for verification and stress. |
| [`stream_discard_gate`](docs/reference/stream/stream_discard_gate.md) | `module` | Consumes input transfers while discard is asserted. |
| [`stream_elastic_register`](docs/reference/stream/stream_elastic_register.md) | `module` | One-entry elastic valid/ready register stage. |
| [`stream_fair_arbiter`](docs/reference/stream/stream_fair_arbiter.md) | `module` | Fair round-robin arbiter for valid/ready stream inputs. |
| [`stream_fallthrough_buffer`](docs/reference/stream/stream_fallthrough_buffer.md) | `module` | One-entry fall-through valid/ready buffer. |
| [`stream_queue`](docs/reference/stream/stream_queue.md) | `module` | Parameterized valid/ready queue with optional fall-through. |
| [`stream_replicator`](docs/reference/stream/stream_replicator.md) | `module` | Registered one-item stream distributor with per-target completion. |
| [`stream_router`](docs/reference/stream/stream_router.md) | `module` | Routes one valid/ready input to a selected output. |
| [`stream_selector`](docs/reference/stream/stream_selector.md) | `module` | Selects one of several valid/ready inputs. |
| [`stream_shuffle_network`](docs/reference/stream/stream_shuffle_network.md) | `module` | Deterministic stream-lane permutation network. |
| [`stream_window_guard`](docs/reference/stream/stream_window_guard.md) | `module` | Limits outstanding stream requests with explicit retire accounting. |

### `tech`

| Component | Type | Function summary |
| --- | --- | --- |
| [`clk_an2`](docs/reference/tech/clk_an2.md) | `module` | Behavioral two-input clock AND model. |
| [`clk_buf`](docs/reference/tech/clk_buf.md) | `module` | Behavioral clock buffer model. |
| [`clk_icg`](docs/reference/tech/clk_icg.md) | `module` | Behavioral integrated clock-gate model. |
| [`clk_icg2`](docs/reference/tech/clk_icg2.md) | `module` | Behavioral two-input integrated clock-gate model. |
| [`clk_mux2`](docs/reference/tech/clk_mux2.md) | `module` | Behavioral two-input clock mux model. |
| [`clk_n`](docs/reference/tech/clk_n.md) | `module` | Behavioral clock inverter model. |
| [`clk_nd2`](docs/reference/tech/clk_nd2.md) | `module` | Behavioral two-input clock NAND model. |
| [`clk_xor2`](docs/reference/tech/clk_xor2.md) | `module` | Behavioral two-input clock XOR model. |
| [`osc_pad_h`](docs/reference/tech/osc_pad_h.md) | `module` | Horizontal oscillator pad abstraction. |
| [`osc_pad_v`](docs/reference/tech/osc_pad_v.md) | `module` | Vertical oscillator pad abstraction. |
| [`tech_pll`](docs/reference/tech/tech_pll.md) | `module` | Technology PLL abstraction. |
| [`tech_ram`](docs/reference/tech/tech_ram.md) | `module` | Behavioral single-port technology RAM model. |
| [`tech_ram_bm`](docs/reference/tech/tech_ram_bm.md) | `module` | Behavioral byte-masked technology RAM model. |
| [`tech_regfile`](docs/reference/tech/tech_regfile.md) | `module` | Behavioral technology register-file model. |
| [`tech_regfile_bm`](docs/reference/tech/tech_regfile_bm.md) | `module` | Behavioral byte-masked technology register-file model. |
| [`tri_pd_pad_h`](docs/reference/tech/tri_pd_pad_h.md) | `module` | Horizontal pull-down pad abstraction. |
| [`tri_pd_pad_v`](docs/reference/tech/tri_pd_pad_v.md) | `module` | Vertical pull-down pad abstraction. |
| [`tri_pdu_pad_h`](docs/reference/tech/tri_pdu_pad_h.md) | `module` | Horizontal pull-down-up pad abstraction. |
| [`tri_pdu_pad_v`](docs/reference/tech/tri_pdu_pad_v.md) | `module` | Vertical pull-down-up pad abstraction. |
| [`tri_pu_pad_h`](docs/reference/tech/tri_pu_pad_h.md) | `module` | Horizontal pull-up pad abstraction. |
| [`tri_pu_pad_v`](docs/reference/tech/tri_pu_pad_v.md) | `module` | Vertical pull-up pad abstraction. |

### `utils`

| Component | Type | Function summary |
| --- | --- | --- |
| [`bin2gray`](docs/reference/utils/bin2gray.md) | `module` | Combinational binary-to-Gray code converter. |
| [`dff`](docs/reference/utils/dff.md) | `module` | Plain D flip-flop primitive. |
| [`dffer`](docs/reference/utils/dffer.md) | `module` | Enabled D flip-flop with asynchronous reset. |
| [`dfferc`](docs/reference/utils/dfferc.md) | `module` | Enabled D flip-flop with configurable reset value. |
| [`dffercn`](docs/reference/utils/dffercn.md) | `module` | Enabled D flip-flop with active-low configurable reset value. |
| [`dfferh`](docs/reference/utils/dfferh.md) | `module` | Enabled D flip-flop with all-one reset value. |
| [`dfferm`](docs/reference/utils/dfferm.md) | `module` | Masked-update D flip-flop with reset. |
| [`dffesr`](docs/reference/utils/dffesr.md) | `module` | Enabled D flip-flop with synchronous reset. |
| [`dffesrc`](docs/reference/utils/dffesrc.md) | `module` | Enabled D flip-flop with synchronous reset and configurable reset value. |
| [`dffl`](docs/reference/utils/dffl.md) | `module` | Level-sensitive latch primitive. |
| [`dffr`](docs/reference/utils/dffr.md) | `module` | D flip-flop with asynchronous active-low reset. |
| [`dffrc`](docs/reference/utils/dffrc.md) | `module` | D flip-flop with configurable reset value. |
| [`dffrh`](docs/reference/utils/dffrh.md) | `module` | D flip-flop with all-one reset value. |
| [`dffsr`](docs/reference/utils/dffsr.md) | `module` | D flip-flop with synchronous reset. |
| [`dffsrc`](docs/reference/utils/dffsrc.md) | `module` | D flip-flop with synchronous reset and configurable reset value. |
| [`edge_det`](docs/reference/utils/edge_det.md) | `module` | Single-bit rising and falling edge detector. |
| [`edge_det_fe`](docs/reference/utils/edge_det_fe.md) | `module` | Single-bit falling-edge detector. |
| [`edge_det_re`](docs/reference/utils/edge_det_re.md) | `module` | Single-bit rising-edge detector. |
| [`edge_det_sync`](docs/reference/utils/edge_det_sync.md) | `module` | Synchronized single-bit rising and falling edge detector. |
| [`edge_det_sync_fe`](docs/reference/utils/edge_det_sync_fe.md) | `module` | Synchronized single-bit falling-edge detector. |
| [`edge_det_sync_re`](docs/reference/utils/edge_det_sync_re.md) | `module` | Synchronized single-bit rising-edge detector. |
| [`fifo`](docs/reference/utils/fifo.md) | `module` | Power-of-two synchronous FIFO with combinational head read. |
| [`gray2bin`](docs/reference/utils/gray2bin.md) | `module` | Combinational Gray-to-binary code converter. |
| [`lfsr_fibonacci`](docs/reference/utils/lfsr_fibonacci.md) | `module` | Fibonacci-form pseudo-random linear-feedback shift register. |
| [`lfsr_galois`](docs/reference/utils/lfsr_galois.md) | `module` | Galois-form pseudo-random linear-feedback shift register. |
| [`ndffer`](docs/reference/utils/ndffer.md) | `module` | Enabled D flip-flop with falling-edge clock and asynchronous reset. |
| [`ndffr`](docs/reference/utils/ndffr.md) | `module` | Resettable multi-stage synchronizer register chain. |
| [`regfield`](docs/reference/utils/regfield.md) | `module` | Masked register-field update primitive. |
| [`shift_reg`](docs/reference/utils/shift_reg.md) | `module` | Parameterized sequential shift register. |
| [`spill_register`](docs/reference/utils/spill_register.md) | `module` | Two-register spill stage for breaking ready timing paths. |
| [`stream_fifo`](docs/reference/utils/stream_fifo.md) | `module` | Legacy valid/ready wrapper around the synchronous FIFO. |
| [`valid_delay_line`](docs/reference/utils/valid_delay_line.md) | `module` | Valid-only parameterized sequential delay line. |
| [`xchecker`](docs/reference/utils/xchecker.md) | `module` | Simulation unknown-value checker. |

<!-- COMPONENT_REFERENCE:END -->
