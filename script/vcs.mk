NOVAS        := /nfs/tools/synopsys/verdi/V-2023.12-SP1-1/share/PLI/VCS/LINUX64
EXTRA        := -P ${NOVAS}/novas.tab ${NOVAS}/pli.a

SIM_TOOL     := bsub -Is vcs
SIM_BINY     := bsub -Is ./simv
VERDI_TOOL   := bsub -Is verdi
SIM_OPTIONS  := -full64 +v2k -sverilog -timescale=1ns/10ps \
                ${EXTRA} \
                -kdb \
                -debug_access+all \
                -debug_region=cell+lib \
                +error+500 \
                +vcs+flush+all \
                +lint=TFIPC-L \
                -xprop=../xprop.config \
                -work DEFAULT \
                +define+SV_ASSRT_DISABLE \

TIME_OPTION := +notimingcheck \
               +nospecify \

WAVE_CFG ?= # WAVE_ON
RUN_ARGS ?=
RUN_ARGS += +$(WAVE_CFG)
RUN_ARGS += +WAVE_NAME=$(SIM_TOP).fsdb

comp:
	@mkdir -p build
	cd build && ($(SIM_TOOL) $(SIM_OPTIONS) -top $(SIM_TOP) -l compile.log $(SRC_FILE) $(SIM_INC))

run: comp
	cd build && ($(SIM_BINY) -l run.log $(RUN_ARGS))

wave:
	cd build && ($(VERDI_TOOL) -ssf $(SIM_TOP).fsdb &)

clean :
	rm -rf build

.PHONY : wave clean