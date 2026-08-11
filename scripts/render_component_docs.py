#!/usr/bin/env python3
"""Render checked-in RTL reference pages directly from SystemVerilog declarations."""

from __future__ import annotations

import argparse
import re
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RTL_ROOT = ROOT / "rtl"
DOC_ROOT = ROOT / "docs" / "reference"
README = ROOT / "README.md"
DECL = re.compile(r"^(module|interface|package)\s+([A-Za-z_][A-Za-z0-9_]*)\b")
PARAMETER = re.compile(r"^\s*parameter\b.*\b([A-Za-z_][A-Za-z0-9_]*)\s*=")
PORT = re.compile(r"^\s*(?:input|output|inout)\s+(?:logic|wire|bit)?\s*(?:\[[^]]+\]\s*)*([A-Za-z_][A-Za-z0-9_]*)\s*,?\s*$")
START = "<!-- COMPONENT_REFERENCE:START -->"
END = "<!-- COMPONENT_REFERENCE:END -->"


@dataclass(frozen=True)
class Unit:
    kind: str
    name: str
    source: Path
    declaration: str


def parse_table(raw: str) -> dict[str, str]:
    return dict(line.split("\t", 1) for line in raw.strip().splitlines())


SUMMARIES = parse_table("""
address_map\tMasked address-map decoder with deterministic lowest-index priority.
address_range_decoder\tInclusive address-range decoder.
address_region\tMasked address-region matcher.
address_set_decoder\tDecoder for a set of independently configured address regions.
ahbl_if\tTyped AHB-Lite interface with master and slave modports.
apb4_if\tClocked APB4 interface with master and slave modports.
apb4_master_model\tSimulation APB4 master model.
apb4_pure_if\tClockless APB4 signal interface with master and slave modports.
async_gray_queue\tGray-pointer asynchronous FIFO wrapper.
async_reqack\tOne-entry four-phase asynchronous data mailbox.
axi4_addr_gen\tAXI4 next-address generator for FIXED, INCR, and legal WRAP bursts.
axi4_if\tTyped AXI4 interface with master and slave modports.
axi4_regslice\tElastic register slice for all five AXI4 channels.
axi4_stream_if\tTyped AXI4-Stream interface with source, sink, and monitor modports.
axi4_stream_regslice\tElastic AXI4-Stream register slice.
bin2gray\tCombinational binary-to-Gray code converter.
bit_count\tCombinational population-count primitive.
bypass_buffer\tCombinational valid/ready stream pass-through.
cdc_2phase\tTwo-phase asynchronous request/acknowledge transfer.
cdc_2phase_dst\tDestination-side implementation of the two-phase CDC link.
cdc_2phase_src\tSource-side implementation of the two-phase CDC link.
cdc_2phase_warm_flush\tSource-initiated warm-clear wrapper for a two-phase CDC link.
cdc_event_bridge\tPulse/event transport over an asynchronous mailbox.
cdc_event_bridge_ack\tAcknowledged asynchronous event transport.
cdc_fifo\tGray-pointer asynchronous FIFO.
cdc_fifo_dst\tDestination-side implementation of the asynchronous FIFO.
cdc_fifo_src\tSource-side implementation of the asynchronous FIFO.
cdc_fifo_warm_flush\tSource-initiated warm-clear wrapper for an asynchronous FIFO.
cdc_remote_clear_request\tRetained remote-clear request channel.
cdc_reset_barrier\tTwo-domain reset barrier with synchronized release.
cdc_sync\tMulti-flop synchronizer for a control bit or independently encoded vector.
cdc_sync_det\tSynchronized control input with edge detection.
cdc_warm_flush_controller\tAcknowledged isolate-reset-resume controller for CDC warm flush.
circular_store\tSequential circular store with bounded random reads.
clearable_async_queue\tAsynchronous queue with coordinated endpoint clear.
clearable_two_phase_link\tTwo-phase link with coordinated endpoint clear.
clk_an2\tBehavioral two-input clock AND model.
clk_buf\tBehavioral clock buffer model.
clk_icg\tBehavioral integrated clock-gate model.
clk_icg2\tBehavioral two-input integrated clock-gate model.
clk_int_div_simple\tRuntime-programmable integer divider with safe low-phase updates.
clk_int_even_div\tEven clock divider retaining requests until a safe boundary.
clk_int_even_div_static\tStatic even integer clock divider.
clk_int_odd_div_static\tStatic odd integer clock divider.
clk_mux2\tBehavioral two-input clock mux model.
clk_n\tBehavioral clock inverter model.
clk_nd2\tBehavioral two-input clock NAND model.
clk_xor2\tBehavioral two-input clock XOR model.
clock_divider\tRuntime-programmable divider that changes only at an output-low boundary.
clock_or_tree\tOR tree for clocks already proven safe to combine.
component_math_pkg\tCompile-time arithmetic helpers for parameterized components.
counting_bloom_filter\tCounting Bloom filter with explicit counter saturation.
credit_pool\tSaturating available-credit tracker for resource flow control.
dff\tPlain D flip-flop primitive.
dffer\tEnabled D flip-flop with asynchronous reset.
dfferc\tEnabled D flip-flop with configurable reset value.
dffercn\tEnabled D flip-flop with active-low configurable reset value.
dfferh\tEnabled D flip-flop with all-one reset value.
dfferm\tMasked-update D flip-flop with reset.
dffesr\tEnabled D flip-flop with synchronous reset.
dffl\tLevel-sensitive latch primitive.
dffr\tD flip-flop with asynchronous active-low reset.
dffrc\tD flip-flop with configurable reset value.
dffrh\tD flip-flop with all-one reset value.
dffsr\tD flip-flop with synchronous reset.
edge_det\tSingle-bit rising and falling edge detector.
edge_det_fe\tSingle-bit falling-edge detector.
edge_det_re\tSingle-bit rising-edge detector.
edge_det_sync\tSynchronized single-bit rising and falling edge detector.
edge_det_sync_fe\tSynchronized single-bit falling-edge detector.
edge_det_sync_re\tSynchronized single-bit rising-edge detector.
fifo\tPower-of-two synchronous FIFO with combinational head read.
four_phase_mailbox\tPublic wrapper for the four-phase asynchronous mailbox API.
gray2bin\tCombinational Gray-to-binary code converter.
hash_indicator_bank\tMulti-hash indicator-vector generator.
index_to_onehot\tBounded index-to-one-hot decoder.
interval_ones_mask\tInclusive contiguous mask generator between two bit positions.
isochronous_handshake\tHandshake for fixed-ratio, STA-constrained isochronous clocks.
isochronous_stream_buffer\tStream buffer for fixed-ratio, STA-constrained isochronous clocks.
latest_value_stream\tValid-only stream adapter retaining the newest pending value.
leading_zero_count\tCombinational leading-zero counter with all-zero indication.
lfsr_fibonacci\tFibonacci-form pseudo-random linear-feedback shift register.
lfsr_galois\tGalois-form pseudo-random linear-feedback shift register.
loop_trip_counter\tProgrammable terminal-count loop counter.
memory_bank_adapter\tPublic banked-memory request and response adapter.
memory_bank_adapter_detail\tBanked-memory request splitter and response gatherer.
memory_response_bridge\tResponse-order bridge between memory and stream interfaces.
ndffr\tResettable multi-stage synchronizer register chain.
onehot_check\tOne-hot validity checker with optional all-zero acceptance.
onehot_to_index\tOne-hot vector to index converter with validity output.
osc_pad_h\tHorizontal oscillator pad abstraction.
osc_pad_v\tVertical oscillator pad abstraction.
peak_delta_counter\tUp/down counter with retained high-water mark.
permutation_hash\tDeterministic non-cryptographic bit-mixing hash.
plru_victim_selector\tPower-of-two pseudo-LRU cache-way victim selector.
prefix_ones_mask\tLow-order prefix-ones mask generator.
ram_if\tSimple RAM request/response interface with master and slave modports.
ready_valid_if\tTyped ready/valid interface with source, sink, and monitor modports.
regfield\tMasked register-field update primitive.
retry_backoff\tPseudo-random exponential retry-delay controller.
ribp_if\tRIBP request/response interface with response-error signaling.
round_robin_arbiter\tFair transfer-driven round-robin arbiter.
rs_counter\tResettable up/down counter.
rs_delta_counter\tDelta-counting counter.
rst_sync\tAsynchronous-assert, synchronous-release reset synchronizer.
safe_clock_mux\tGlitch-safe handover mux for two continuously running clocks.
sample_majority_filter\tSliding-window N-of-M single-bit sample filter.
secded_decode\tExtended-Hamming SECDED decoder, corrector, and error classifier.
secded_encode\tExtended-Hamming SECDED encoder.
secded_layout_pkg\tShared SECDED codeword-layout helpers.
shift_reg\tParameterized sequential shift register.
signal_sink\tIntentional unused-signal terminator.
signal_tap\tNamed combinational signal pass-through for observability.
spill_register\tTwo-register spill stage for breaking ready timing paths.
stable_level_filter\tConsecutive-sample debounce and stability filter.
stream_buffer\tValid/ready stream wrapper around a spill register.
stream_collector\tCollects selected valid/ready inputs into one stream output.
stream_credit_limiter\tLimits stream acceptance by available credits.
stream_crossbar\tArbitrates and routes multiple stream inputs to multiple outputs.
stream_delay_injector\tControlled stream delay injector for verification and stress.
stream_discard_gate\tConsumes input transfers while discard is asserted.
stream_elastic_register\tOne-entry elastic valid/ready register stage.
stream_fair_arbiter\tFair round-robin arbiter for valid/ready stream inputs.
stream_fallthrough_buffer\tOne-entry fall-through valid/ready buffer.
stream_fifo\tLegacy valid/ready wrapper around the synchronous FIFO.
stream_queue\tParameterized valid/ready queue with optional fall-through.
stream_replicator\tRegistered one-item stream distributor with per-target completion.
stream_router\tRoutes one valid/ready input to a selected output.
stream_selector\tSelects one of several valid/ready inputs.
stream_shuffle_network\tDeterministic stream-lane permutation network.
stream_window_guard\tLimits outstanding stream requests with explicit retire accounting.
sync_memory\tPortable synchronous memory model with positive-logic controls.
synchronized_edge\tSynchronizes a control transition and emits a local edge indication.
tag_order_queue\tShared-pool queue preserving FIFO order within each tag.
tech_pll\tTechnology PLL abstraction.
tech_ram\tBehavioral single-port technology RAM model.
tech_ram_bm\tBehavioral byte-masked technology RAM model.
tech_regfile\tBehavioral technology register-file model.
tech_regfile_bm\tBehavioral byte-masked technology register-file model.
test_reset_synchronizer\tVerification-oriented reset synchronization helper.
trailing_zero_count\tCombinational trailing-zero counter with all-zero indication.
tri_pd_pad_h\tHorizontal pull-down pad abstraction.
tri_pd_pad_v\tVertical pull-down pad abstraction.
tri_pdu_pad_h\tHorizontal pull-down-up pad abstraction.
tri_pdu_pad_v\tVertical pull-down-up pad abstraction.
tri_pu_pad_h\tHorizontal pull-up pad abstraction.
tri_pu_pad_v\tVertical pull-up pad abstraction.
two_phase_async_queue\tQueue API built from two-phase asynchronous transfers.
valid_delay_line\tValid-only parameterized sequential delay line.
xchecker\tSimulation unknown-value checker.
""")


DETAILS = {
    "axi4_regslice": (
        "Places an independent elastic spill stage on the AXI4 AW, W, B, AR, and R channels. Each channel retains its complete payload while stalled, and `flush_i` discards any locally buffered transfer.",
        "Use to break long AXI4 valid, ready, and payload timing paths without coupling the five channels or changing transaction ordering.",
        "Preserve the configured interface widths at both endpoints. Enable `BYPASS` only when empty-state combinational timing is acceptable, and assert `flush_i` only when the surrounding system is permitted to abort buffered traffic.",
    ),
    "credit_pool": ("Tracks returned (`give_i`) and consumed (`take_i`) credits. Simultaneous give/take has zero net change; full, empty, and one-from-full outputs observe the current state.", "Use for bounded request windows, queue slots, buffer credits, and response throttling.", "Do not issue unpaired gives or takes. `clear_i` is synchronous; choose `EMPTY_ON_RESET` to match resource ownership after reset."),
    "loop_trip_counter": ("Increments by `step_i` on `advance_i`. When the stored value equals `limit_i`, the next advance pulses `wrap_o` and returns the state to zero.", "Use for bounded loops, beat scheduling, table traversal, and phase sequencing.", "A nonzero step must reach the limit exactly. This is not an arbitrary modulo counter; skipping the terminal value is an error."),
    "stable_level_filter": ("Changes the output only after the sampled level differs from the current output for `STABLE_CYCLES` enabled consecutive clocks. `restart_i` accepts the current sample immediately.", "Use for debounced controls, lock indications, slow GPIO state, and reset-status qualification.", "Synchronize an asynchronous source first. Disabling the filter clears accumulated evidence; `STABLE_CYCLES=1` accepts every enabled sample."),
    "sample_majority_filter": ("Retains the most recent enabled samples and asserts when their population count reaches `ASSERT_THRESHOLD`; the default is strict majority.", "Use for noisy status pins, repeated sensor samples, redundant indications, and temporal voting.", "This is a population filter, not a synchronizer or consecutive-stability filter. Choose the threshold deliberately."),
    "retry_backoff": ("Samples a local Galois-LFSR through an expanding low-bit mask after failure. A nonzero sampled delay deasserts `ready_o` until its wait counter reaches zero; success clears the retry window.", "Use for contention retries, shared-resource collision recovery, and congestion backoff.", "Gate attempts with `ready_o`. A failure during an active wait replaces the delay, while success cancels it."),
    "async_reqack": ("Captures one source payload, transfers it through a four-phase request/acknowledge protocol, and suppresses destination valid after acceptance so return-to-zero cannot create a duplicate delivery.", "Use for low-throughput asynchronous control or data mailboxes.", "Hold source payload only through the source valid/ready handshake. Reset at either endpoint aborts an in-flight item; this is a one-entry link."),
    "cdc_reset_barrier": ("Asynchronously asserts local reset and releases it through synchronized reset chains in both supplied clock domains, preventing either side from running before the shared reset epoch is released.", "Use when two collaborating domains need a coordinated reset release before starting a CDC protocol.", "It does not transfer data or replace reset-domain signoff. Both clocks must run for reset release to complete."),
    "spill_register": ("Uses a primary register plus spill storage to retain input data during downstream stalls while decoupling the ready path. Optional bypass changes empty-state latency only.", "Use at stream timing boundaries where combinational ready propagation is too long.", "Follow valid/ready stability rules and treat `flush_i` as an abort of retained data. Check bypass timing before using it across a long path."),
    "stream_replicator": ("Captures one input payload and target mask, then presents it to every enabled target exactly once as each target becomes ready. It releases input backpressure only after all selected transfers complete.", "Use for multicast command/data distribution with independently stalling consumers.", "The mask is sampled only on input acceptance. `flush_i` aborts a retained item; downstream consumers must obey normal valid/ready semantics."),
    "secded_decode": ("Computes a Hamming syndrome and overall parity, corrects a correctable single-bit fault, reports an overall-parity-only error, and flags uncorrectable double errors without changing the codeword.", "Use on protected memory reads and protected interconnect payloads.", "Treat decoded data as invalid when `uncorrectable_o` is high and use exactly the matching encoder geometry."),
    "secded_encode": ("Places data in the shared SECDED layout, generates Hamming parity positions, and appends overall parity for single-error correction and double-error detection.", "Use before writing protected memories or sending protected link data.", "Pair only with `secded_decode` built from the same parameters and layout package."),
}


def discover() -> list[Unit]:
    units: list[Unit] = []
    for source in sorted(RTL_ROOT.rglob("*.sv")):
        lines = source.read_text(encoding="utf-8").splitlines()
        for index, line in enumerate(lines):
            match = DECL.match(line)
            if match is None:
                continue
            kind, name = match.groups()
            terminator = "endpackage" if kind == "package" else "endinterface" if kind == "interface" else ");"
            declaration = [line]
            for next_line in lines[index + 1:]:
                declaration.append(next_line)
                if next_line.strip() == terminator:
                    break
            else:
                raise RuntimeError(f"unclosed declaration: {source}:{index + 1}")
            units.append(Unit(kind, name, source.relative_to(ROOT), "\n".join(declaration)))
    return units


def category(unit: Unit) -> str:
    return unit.source.parent.name


def availability(unit: Unit) -> str:
    if category(unit) == "tech":
        return "Technology model; replace in an ASIC technology flow"
    if category(unit) == "model" or unit.name == "xchecker":
        return "Simulation/verification model"
    if unit.name.startswith("test_"):
        return "Verification-oriented helper"
    return "Synthesizable RTL" if unit.kind == "module" else "SystemVerilog integration API"


def generic_detail(unit: Unit) -> tuple[str, str, str]:
    group = category(unit)
    summary = SUMMARIES[unit.name]
    if group == "cdc":
        return (f"{summary} It carries the declared control, event, or data contract through the stated synchronizer, handshake, or Gray-pointer mechanism. Endpoint reset discards in-flight data unless the page identifies an acknowledged warm-clear path.", "Use for reset release, asynchronous control/data transfer, asynchronous queues, event notification, and CDC recovery.", "Never use a simple synchronizer for arbitrary multi-bit data. Keep both endpoint clocks running after reset release and obey all ready/busy outputs.")
    if group == "stream":
        return (f"{summary} It follows the repository valid/ready rule: a payload transfers only when both signals are high in the same cycle, and a stalled valid payload remains stable.", "Use for elastic pipelines, stream routing, arbitration, backpressure, and response handling.", "Observe vector sizing, selection encoding, and flush semantics in the declaration. Do not modify a valid payload while its corresponding ready is low.")
    if group == "interface":
        return (f"{summary} It groups protocol signals and constrains endpoint direction with the declared modports; it does not implement protocol state or drive behavior itself.", "Use to connect compatible SystemVerilog RTL or class-based verification components without duplicating a port bundle.", "Connect the correct modport for each role. The connected logic remains responsible for all protocol timing and reset behavior.")
    if group == "clock" or group == "clkrst":
        return (f"{summary} It implements the declared clock/reset behavior but does not replace physical clock-tree, reset-domain, or STA signoff.", "Use in controlled clock/reset infrastructure with explicit physical-design ownership.", "Respect all clock-running and configuration-stability assumptions. Do not use generic logic as a substitute for a safe clock-control cell.")
    if group == "tech":
        return (f"{summary} It supplies portable functional behavior or a backend substitution hook, not characterized silicon timing or power behavior.", "Use for simulation, generic synthesis, FPGA prototyping, and technology-independent elaboration.", "Replace it through the target technology flow before ASIC tape-out. Treat its active-low controls and backend macros as part of the integration contract.")
    if group == "bus":
        return (f"{summary} It classifies the presented address using the configured decode rule and returns the documented selection/match result combinationally.", "Use for memory maps, peripheral selection, firewall regions, and target routing.", "Check overlaps and priority deliberately. Decode does not by itself complete or validate a bus transaction.")
    if group == "memory":
        return (f"{summary} It implements the declared storage, ordering, banking, or response contract with explicit bounds rather than silently dropping malformed transactions.", "Use for local queues, reorder structures, banked stores, and portable memory-backed blocks.", "Follow address, depth, outstanding-request, and response-order constraints exactly. Reset state does not imply initialized storage contents unless documented.")
    if group == "utils":
        return (f"{summary} Its exact parameters and ports are reproduced below from the implementation declaration.", "Use as a small reusable datapath, state, coding, delay, or verification primitive.", "Keep parameter values within RTL assertions and add required clocking, reset, or CDC protection at the caller boundary.")
    if group == "base":
        return (f"{summary} It is a self-contained base primitive with the behavior and parameter checks implemented in the linked RTL source.", "Use as a structured building block for control, encoding, ECC, hashing, masking, replacement, or observability logic.", "Honor validity/error outputs and parameter constraints. Combinational cells do not provide timing isolation or CDC protection.")
    if group == "model":
        return (f"{summary} It models the protocol action for simulation and is not a synthesizable protocol endpoint.", "Use in a SystemVerilog testbench or directed protocol smoke test.", "Include the required interface/configuration definitions and do not include this model in a silicon file list.")
    raise RuntimeError(f"unhandled category: {group}")


def page_path(unit: Unit) -> Path:
    return DOC_ROOT / category(unit) / f"{unit.name}.md"


def signature(unit: Unit) -> str:
    """Return only the declaration header when an interface has an internal body."""
    if unit.kind != "interface":
        return unit.declaration
    lines = []
    for line in unit.declaration.splitlines():
        lines.append(line)
        if line.strip().endswith(");"):
            break
    return "\n".join(lines)


def names(pattern: re.Pattern[str], text: str) -> list[str]:
    result = []
    for line in text.splitlines():
        match = pattern.match(line)
        if match is not None:
            result.append(match.group(1))
    return result


def markdown_table(headers: tuple[str, ...], rows: list[tuple[str, ...]]) -> str:
    if not rows:
        return ""
    header = "| " + " | ".join(headers) + " |"
    separator = "| " + " | ".join("---" for _ in headers) + " |"
    body = ["| " + " | ".join(row) + " |" for row in rows]
    return "\n".join([header, separator, *body])


def parameter_table(unit: Unit) -> str:
    rows = []
    for line in signature(unit).splitlines():
        match = PARAMETER.match(line)
        if match is not None:
            rows.append((f"`{match.group(1)}`", f"`{line.strip().rstrip(',')}`"))
    return markdown_table(("Parameter", "Declaration"), rows)


def port_table(unit: Unit) -> str:
    rows = []
    for line in signature(unit).splitlines():
        match = PORT.match(line)
        if match is not None:
            direction = line.strip().split(None, 1)[0]
            rows.append((f"`{match.group(1)}`", f"`{direction}`", f"`{line.strip().rstrip(',')}`"))
    return markdown_table(("Signal", "Direction", "Declaration"), rows)


def use_example(unit: Unit) -> str:
    if unit.kind == "package":
        return f"```systemverilog\nimport {unit.name}::*;\n// Use exported types, constants, or functions here.\n```"
    header = signature(unit)
    parameters = names(PARAMETER, header)
    parameter_text = ""
    if parameters:
        parameter_text = " #(\n" + ",\n".join(
            f"    .{name}({name})" for name in parameters
        ) + "\n)"
    if unit.kind == "interface":
        ports = names(PORT, header)
        connection_text = ", ".join(f".{name}({name})" for name in ports)
        return f"```systemverilog\n{unit.name}{parameter_text} {unit.name}_i({connection_text});\n// Example: consumer u_consumer (.bus_i({unit.name}_i.slave));\n```"
    ports = names(PORT, header)
    connection_text = ",\n".join(f"    .{name}({name})" for name in ports)
    return f"```systemverilog\n{unit.name}{parameter_text} u_{unit.name} (\n{connection_text}\n);\n```"


def render_page(unit: Unit) -> str:
    detail, scenarios, integration = DETAILS.get(unit.name, generic_detail(unit))
    source_link = f"../../../{unit.source.as_posix()}"
    parameter_note = "The declaration below is canonical; retain the RTL-enforced parameter range." if "parameter" in unit.declaration else "This unit has no configurable parameters."
    if unit.kind == "package":
        parameter_note = "The package declaration below is canonical for exported types, constants, and functions."
    parameters = parameter_table(unit)
    ports = port_table(unit)
    parameter_section = f"{parameter_note}\n\n{parameters}" if parameters else parameter_note
    port_section = f"\n\n### Port Summary\n\n{ports}" if ports else ""
    return f"""# {unit.name}

| Property | Value |
| --- | --- |
| Kind | `{unit.kind}` |
| RTL source | [`{unit.source.as_posix()}`]({source_link}) |
| Availability | {availability(unit)} |

## Summary

{SUMMARIES[unit.name]}

## Functional Behavior

{detail}

## Suitable Applications

{scenarios}

## Parameters

{parameter_section}

## Interface Definition

```systemverilog
{unit.declaration}
```
{port_section}

## Integration and Use

{integration}

{use_example(unit)}

## Dependencies and Verification

The linked RTL source is the implementation authority and contains local assertions for unsupported
parameter combinations. See [`docs/design.md`](../../design.md) for repository-wide CDC, reset,
stream, and storage contracts, and [`docs/verification.md`](../../verification.md) for the
verification matrix.
"""


def render_catalog(units: list[Unit]) -> str:
    grouped: dict[str, list[Unit]] = {}
    for unit in units:
        grouped.setdefault(category(unit), []).append(unit)
    lines = ["## Component Reference", "", "Each declared RTL unit has a detailed integration page. The catalog is generated from `rtl/`; use the linked page for parameters, complete interfaces, reset/CDC constraints, and an instantiation example.", ""]
    for group in sorted(grouped):
        lines.extend([f"### `{group}`", "", "| Component | Type | Function summary |", "| --- | --- | --- |"])
        for unit in sorted(grouped[group], key=lambda value: value.name):
            target = page_path(unit).relative_to(ROOT).as_posix()
            lines.append(f"| [`{unit.name}`]({target}) | `{unit.kind}` | {SUMMARIES[unit.name]} |")
        lines.append("")
    return "\n".join(lines)


def replace_catalog(readme: str, catalog: str) -> str:
    start = readme.index(START) + len(START)
    end = readme.index(END)
    return readme[:start] + "\n\n" + catalog + "\n" + readme[end:]


def render_index(units: list[Unit]) -> str:
    grouped: dict[str, list[Unit]] = {}
    for unit in units:
        grouped.setdefault(category(unit), []).append(unit)
    lines = ["# RTL Reference", "", "One checked-in page exists for every declared SystemVerilog `module`, `interface`, and `package` under `rtl/`. The pages mirror RTL categories and reproduce the canonical source declaration.", "", "After changing a declaration or its integration contract, run `python3 scripts/render_component_docs.py` and then `make docs-check`. The latter rejects stale pages, missing coverage, malformed required sections, and a stale README catalog.", "", "`rtl/verif` contains class-based verification support rather than RTL declarations. `rtl/clkrst/clk_frac_div.sv` is a compatibility source with no declaration because fractional division is intentionally not provided.", "", "## Categories", ""]
    for group in sorted(grouped):
        links = ", ".join(f"[`{unit.name}`]({group}/{unit.name}.md)" for unit in sorted(grouped[group], key=lambda value: value.name))
        lines.append(f"- `{group}`: {links}")
    return "\n".join(lines) + "\n"


def expected_outputs(units: list[Unit]) -> dict[Path, str]:
    outputs = {page_path(unit): render_page(unit) for unit in units}
    outputs[DOC_ROOT / "README.md"] = render_index(units)
    outputs[README] = replace_catalog(README.read_text(encoding="utf-8"), render_catalog(units))
    return outputs


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="report stale generated pages instead of rewriting them")
    args = parser.parse_args()
    units = discover()
    if len(units) != 150:
        raise RuntimeError(f"expected 150 declarations, found {len(units)}")
    missing = sorted(set(unit.name for unit in units) - set(SUMMARIES))
    extras = sorted(set(SUMMARIES) - set(unit.name for unit in units))
    if missing or extras:
        raise RuntimeError(f"summary coverage mismatch: missing={missing}, stale={extras}")
    outputs = expected_outputs(units)
    if args.check:
        stale = [str(path.relative_to(ROOT)) for path, text in outputs.items() if not path.is_file() or path.read_text(encoding="utf-8") != text]
        if stale:
            raise SystemExit("component reference is stale:\n" + "\n".join(stale))
        return
    for path, text in outputs.items():
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")


if __name__ == "__main__":
    main()
