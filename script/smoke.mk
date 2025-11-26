SIM_INC ?=
SIM_INC += +incdir+${ROOT_PATH}/../common/rtl
SIM_INC += +incdir+${ROOT_PATH}/../common/rtl/interface

SRC_FILE ?=
SRC_FILE += $(ROOT_PATH)/../common/rtl/utils/register.sv
SRC_FILE += $(ROOT_PATH)/../common/rtl/interface/apb4_if.sv
SRC_FILE += $(ROOT_PATH)/../common/rtl/verif/helper.sv
SRC_FILE += $(ROOT_PATH)/../common/rtl/verif/test_base.sv
SRC_FILE += $(ROOT_PATH)/../common/rtl/verif/apb4_master.sv