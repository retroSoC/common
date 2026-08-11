SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help
.DELETE_ON_ERROR:

IVERILOG       ?= iverilog
VVP            ?= vvp
VERILATOR      ?= verilator
YOSYS          ?= yosys
SBY            ?= sby
MBAKE          ?= mbake
VERIBLE_FORMAT ?= verible-verilog-format
VERIBLE_LINT   ?= verible-verilog-lint
BUILD_DIR      ?= build

TESTS           := bit_ops gray_code fifo stream stream_control base_ext extended_base stream_extended structures ecc arbiter address cdc cdc_advanced cdc_flush clock memory axi
VERILATOR_TESTS := $(TESTS) axi_bfm axi_components
RTL_FILES       := $(shell scripts/rtl_files.sh)
MAKE_FILES      := $(shell git ls-files --cached --others --exclude-standard | rg '(^|/)(Makefile|[^/]+\.mk)$$' | while IFS= read -r file; do test -f "$$file" && printf '%s\n' "$$file"; done)
SV_FILES        := $(shell git ls-files --cached --others --exclude-standard | rg '\.sv$$' | while IFS= read -r file; do test -f "$$file" && printf '%s\n' "$$file"; done)

.PHONY: help doctor format format-check mk-format mk-format-check mk-validate rtl-format rtl-format-check docs-check license-check lint test test-iverilog test-verilator synth formal clean

help:
	@printf '%s\n' \
	  'Targets:' \
	  '  doctor                                verify required local tools' \
	  '  format | format-check                 apply/check Makefile and RTL formatting' \
	  '  mk-format | mk-format-check           apply/check tracked Makefile formatting with mbake' \
	  '  mk-validate                           validate Makefile with GNU make via mbake' \
	  '  docs-check                            validate component-reference documentation coverage' \
	  '  rtl-format | rtl-format-check         apply/check tracked SystemVerilog formatting' \
	  '  license-check                         verify SystemVerilog license headers' \
	  '  lint                                  run Verible and Verilator lint' \
	  '  test | test-iverilog | test-verilator run the unit-test regressions' \
	  '  synth | formal                        run synthesis and formal checks' \
	  '  clean                                 remove generated build products'

doctor:
	@scripts/doctor.sh

format:
	$(MAKE) mk-format
	$(MAKE) rtl-format

format-check:
	$(MAKE) mk-format-check
	$(MAKE) rtl-format-check

mk-format:
	$(MBAKE) format --config .bake.toml $(MAKE_FILES)

mk-format-check:
	MBAKE="$(MBAKE)" scripts/check_makefile_format.sh $(MAKE_FILES)

mk-validate:
	$(MBAKE) validate --config .bake.toml Makefile

docs-check:
	bash scripts/check_component_docs.sh

rtl-format:
	$(VERIBLE_FORMAT) --flagfile=.verible-format --failsafe_success=false --inplace $(SV_FILES)

rtl-format-check:
	VERIBLE_FORMAT="$(VERIBLE_FORMAT)" scripts/check_format.sh $(SV_FILES)

license-check:
	scripts/check_license_headers.sh $(SV_FILES)
	scripts/check_pulp_manifest.sh
	bash scripts/check_license_docs.sh

lint:
	$(VERIBLE_LINT) --ruleset=none --rules_config=.verible-lint $(RTL_FILES)
	$(VERILATOR) --lint-only --timing -DSV_ASSRT_DISABLE -Wno-fatal -f flist/rtl.f --top-module fifo

test: test-iverilog

test-iverilog: $(addprefix test-iverilog-,$(TESTS))

test-iverilog-%:
	@mkdir -p $(BUILD_DIR)/iverilog
	$(IVERILOG) -g2012 -DSV_ASSRT_DISABLE -Wall -s $*_tb -f flist/rtl.f dv/unit/$*_tb.sv -o $(BUILD_DIR)/iverilog/$*_tb
	$(VVP) $(BUILD_DIR)/iverilog/$*_tb

test-verilator: $(addprefix test-verilator-,$(VERILATOR_TESTS))

test-verilator-%:
	@mkdir -p $(BUILD_DIR)/verilator/$*
	CCACHE_DISABLE=1 $(VERILATOR) --binary --timing -DSV_ASSRT_DISABLE -Wno-fatal -f flist/rtl.f dv/unit/$*_tb.sv --top-module $*_tb --Mdir $(BUILD_DIR)/verilator/$*
	$(BUILD_DIR)/verilator/$*/V$*_tb

test-verilator-axi_bfm:
	@mkdir -p $(BUILD_DIR)/verilator/axi_bfm
	CCACHE_DISABLE=1 $(VERILATOR) --binary --timing -DSV_ASSRT_DISABLE -Wno-fatal -f flist/rtl.f -f flist/verif.f dv/unit/axi_bfm_tb.sv --top-module axi_bfm_tb --Mdir $(BUILD_DIR)/verilator/axi_bfm
	$(BUILD_DIR)/verilator/axi_bfm/Vaxi_bfm_tb

test-verilator-axi_components:
	@mkdir -p $(BUILD_DIR)/verilator/axi_components
	CCACHE_DISABLE=1 $(VERILATOR) --binary --timing -DSV_ASSRT_DISABLE -Wno-fatal -f flist/rtl.f -f flist/axi4_components.f dv/unit/axi_components_tb.sv --top-module axi_components_tb --Mdir $(BUILD_DIR)/verilator/axi_components
	$(BUILD_DIR)/verilator/axi_components/Vaxi_components_tb

synth:
	$(YOSYS) -q -p 'read_verilog -sv rtl/utils/fifo.sv; hierarchy -top fifo; proc; opt; check; stat'
	$(YOSYS) -q -p 'read_verilog -sv rtl/base/bit_ops.sv rtl/stream/round_robin_arbiter.sv; hierarchy -top round_robin_arbiter; proc; opt; check; stat'
	$(YOSYS) -q -p 'read_verilog -sv rtl/base/ecc_secded.sv; hierarchy -top secded_decode; proc; opt; check; stat'
	$(YOSYS) -q -p 'read_verilog -sv rtl/base/mask_cells.sv; hierarchy -top interval_ones_mask; proc; opt; check; stat'
	$(YOSYS) -q -p 'read_verilog -sv rtl/base/hash_cells.sv; hierarchy -top permutation_hash; proc; opt; check; stat'
	$(YOSYS) -q -p 'read_verilog -sv rtl/bus/address_advanced.sv; hierarchy -top address_set_decoder; proc; opt; check; stat'
	$(YOSYS) -q -p 'read_verilog -sv rtl/stream/stream_advanced.sv; hierarchy -top stream_queue; proc; opt; check; stat'
	$(YOSYS) -q -p 'read_verilog -Irtl -sv -DSYNTHESIS formal/dffr_model.sv rtl/base/bit_ops.sv rtl/base/replacement.sv; hierarchy -top plru_victim_selector; proc; opt; check; stat'
	$(YOSYS) -q -p 'read_verilog -sv -DSYNTHESIS rtl/stream/stream_control.sv; hierarchy -top stream_window_guard; proc; opt; check; stat'
	$(YOSYS) -q -p 'read_verilog -Irtl -sv -DSYNTHESIS formal/dffr_model.sv rtl/cdc/cdc_sync.sv rtl/clkrst/rst_sync.sv rtl/cdc/cdc_rst_ctrlr.sv rtl/cdc/async_reqack.sv rtl/cdc/cdc_2phase.sv rtl/cdc/cdc_warm_flush.sv; hierarchy -top cdc_2phase_warm_flush; proc; opt; check; stat'

formal:
	$(SBY) -f formal/fifo.sby
	$(SBY) -f formal/arbiter.sby
	$(SBY) -f formal/async_reqack.sby
	$(SBY) -f formal/stream_replicator.sby
	$(SBY) -f formal/secded.sby
	$(SBY) -f formal/plru.sby
	$(SBY) -f formal/stream_window.sby
	$(SBY) -f formal/stream_queue.sby
	$(SBY) -f formal/cdc_warm_flush.sby

clean:
	@rm -rf $(BUILD_DIR)