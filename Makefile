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

TESTS      := bit_ops gray_code fifo stream arbiter address cdc clock memory axi
RTL_FILES  := $(shell scripts/rtl_files.sh)
MAKE_FILES := $(shell git ls-files --cached --others --exclude-standard | rg '(^|/)(Makefile|[^/]+\.mk)$$')
SV_FILES   := $(shell git ls-files --cached --others --exclude-standard | rg '\.sv$$')

.PHONY: help doctor format format-check mk-format mk-format-check mk-validate rtl-format rtl-format-check license-check lint test test-iverilog test-verilator synth formal clean

help:
	@printf '%s\n' \
	  'Targets:' \
	  '  doctor                                verify required local tools' \
	  '  format | format-check                 apply/check Makefile and RTL formatting' \
	  '  mk-format | mk-format-check           apply/check tracked Makefile formatting with mbake' \
	  '  mk-validate                           validate Makefile with GNU make via mbake' \
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

rtl-format:
	$(VERIBLE_FORMAT) --flagfile=.verible-format --failsafe_success=false --inplace $(SV_FILES)

rtl-format-check:
	VERIBLE_FORMAT="$(VERIBLE_FORMAT)" scripts/check_format.sh $(SV_FILES)

license-check:
	scripts/check_license_headers.sh $(SV_FILES)

lint:
	$(VERIBLE_LINT) --ruleset=none --rules_config=.verible-lint $(RTL_FILES)
	$(VERILATOR) --lint-only --timing -DSV_ASSRT_DISABLE -Wno-fatal -f flist/rtl.f --top-module fifo

test: test-iverilog

test-iverilog: $(addprefix test-iverilog-,$(TESTS))

test-iverilog-%:
	@mkdir -p $(BUILD_DIR)/iverilog
	$(IVERILOG) -g2012 -DSV_ASSRT_DISABLE -Wall -s $*_tb -f flist/rtl.f dv/unit/$*_tb.sv -o $(BUILD_DIR)/iverilog/$*_tb
	$(VVP) $(BUILD_DIR)/iverilog/$*_tb

test-verilator: $(addprefix test-verilator-,$(TESTS))

test-verilator-%:
	@mkdir -p $(BUILD_DIR)/verilator/$*
	CCACHE_DISABLE=1 $(VERILATOR) --binary --timing -DSV_ASSRT_DISABLE -Wno-fatal -f flist/rtl.f dv/unit/$*_tb.sv --top-module $*_tb --Mdir $(BUILD_DIR)/verilator/$*
	$(BUILD_DIR)/verilator/$*/V$*_tb

synth:
	$(YOSYS) -q -p 'read_verilog -sv rtl/utils/fifo.sv; hierarchy -top fifo; proc; opt; check; stat'
	$(YOSYS) -q -p 'read_verilog -sv rtl/base/bit_ops.sv rtl/stream/round_robin_arbiter.sv; hierarchy -top round_robin_arbiter; proc; opt; check; stat'

formal:
	$(SBY) -f formal/fifo.sby
	$(SBY) -f formal/arbiter.sby

clean:
	@rm -rf $(BUILD_DIR)